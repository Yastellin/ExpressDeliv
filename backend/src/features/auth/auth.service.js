import bcrypt from 'bcryptjs';
import jwt    from 'jsonwebtoken';

import {
  findUserByEmail,
  findUserById,
  createUser,
  saveRefreshToken,
  findValidRefreshToken,
  revokeRefreshToken,
  revokeAllUserTokens,
} from './auth.repository.js';

import { AppError, ErrorCodes } from '../../middlewares/errorHandler.js';
import { createAuditLog, AuditActions } from '../../middlewares/auditLogger.js';
import { createLogger } from '../../config/winston.js';

const logger = createLogger('authService');

// ── Helpers JWT ───────────────────────────────────────────
const generateAccessToken = (user) =>
  jwt.sign(
    { id: user.id, role: user.role_nom ?? user.role, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '15m' }
  );

const generateRefreshToken = (user) =>
  jwt.sign(
    { id: user.id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
  );

// Calcule la date d'expiration du refresh token pour la DB
const getRefreshTokenExpiry = () => {
  const days = parseInt(
    (process.env.JWT_REFRESH_EXPIRES_IN || '7d').replace('d', '')
  );
  const expiry = new Date();
  expiry.setDate(expiry.getDate() + days);
  return expiry;
};

// ══════════════════════════════════════════════════════════
// register() — Inscription d'un nouveau client
// ══════════════════════════════════════════════════════════
export const register = async (userData, meta = {}) => {
  // ✅ On récupère le champ 'role' avec une valeur par défaut 'CLIENT'
  const { nom, prenom, email, telephone, password, adresse_defaut, role = 'CLIENT' } = userData;

  // 1. Vérifier que l'email n'existe pas déjà
  const existing = await findUserByEmail(email);
  if (existing) {
    throw new AppError(
      'Un compte avec cet email existe déjà',
      409,
      ErrorCodes.ALREADY_EXISTS
    );
  }

  // 2. Hacher le mot de passe (salt rounds: 12)
  const passwordHash = await bcrypt.hash(password, 12);

  // 3. Créer l'utilisateur en base → on passe le rôle
  const user = await createUser({
    nom, prenom, email, telephone,
    passwordHash,
    adresseDefaut: adresse_defaut,
    role,
  });

  // 4. Générer les tokens
  const accessToken  = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  // 5. Sauvegarder le refresh token
  await saveRefreshToken(user.id, refreshToken, getRefreshTokenExpiry());

  // 6. Audit — on utilise le rôle réel
  await createAuditLog({
    utilisateurId:  user.id,
    action:         AuditActions.REGISTER,
    tableCible:     'utilisateurs',
    entiteId:       user.id,
    nouvelleValeur: { email, nom, prenom, role }, // ✅ rôle réel
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  logger.info('Nouvel utilisateur inscrit', { userId: user.id, email, role });

  return { user, accessToken, refreshToken };
};

// ══════════════════════════════════════════════════════════
// login() — Connexion
// ══════════════════════════════════════════════════════════
export const login = async (email, password, meta = {}) => {
  // 1. Trouver l'utilisateur (avec password_hash)
  const user = await findUserByEmail(email);

  // Message générique volontaire : ne pas révéler si l'email existe
  if (!user) {
    throw new AppError(
      'Email ou mot de passe incorrect',
      401,
      ErrorCodes.UNAUTHORIZED
    );
  }

  // 2. Vérifier le statut du compte
  if (user.statut !== 'ACTIF') {
    throw new AppError(
      "Votre compte est suspendu ou inactif. Contactez l'administrateur.",
      403,
      ErrorCodes.FORBIDDEN
    );
  }

  // 3. Vérifier le mot de passe
  const isPasswordValid = await bcrypt.compare(password, user.password_hash);
  if (!isPasswordValid) {
    throw new AppError(
      'Email ou mot de passe incorrect',
      401,
      ErrorCodes.UNAUTHORIZED
    );
  }

  // 4. Générer les tokens
  const accessToken  = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  // 5. Sauvegarder le refresh token
  await saveRefreshToken(user.id, refreshToken, getRefreshTokenExpiry());

  // 6. Audit
  await createAuditLog({
    utilisateurId: user.id,
    action:        AuditActions.LOGIN,
    tableCible:    'utilisateurs',
    entiteId:      user.id,
    adresseIp:     meta.ip,
    userAgent:     meta.userAgent,
  });

  logger.info('Utilisateur connecté', { userId: user.id, role: user.role_nom });

  return { user, accessToken, refreshToken };
};

// ══════════════════════════════════════════════════════════
// refresh() — Renouvellement du access token
// ══════════════════════════════════════════════════════════
export const refresh = async (refreshToken) => {
  // 1. Vérifier la signature JWT du refresh token
  let decoded;
  try {
    decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError(
      'Refresh token invalide ou expiré',
      401,
      ErrorCodes.TOKEN_INVALID
    );
  }

  // 2. Vérifier que le token existe en base et n'est pas révoqué
  const storedToken = await findValidRefreshToken(refreshToken);
  if (!storedToken) {
    throw new AppError(
      'Session expirée, veuillez vous reconnecter',
      401,
      ErrorCodes.TOKEN_INVALID
    );
  }

  // 3. Récupérer l'utilisateur à jour
  const user = await findUserById(decoded.id);
  if (!user || user.statut !== 'ACTIF') {
    throw new AppError(
      'Compte introuvable ou inactif',
      401,
      ErrorCodes.UNAUTHORIZED
    );
  }

  // 4. Générer un nouveau access token
  const newAccessToken = generateAccessToken(user);

  logger.debug('Access token renouvelé', { userId: user.id });

  return { accessToken: newAccessToken };
};

// ══════════════════════════════════════════════════════════
// logout() — Déconnexion
// ══════════════════════════════════════════════════════════
export const logout = async (refreshToken, userId, meta = {}) => {
  // Révoque uniquement ce refresh token
  await revokeRefreshToken(refreshToken);

  await createAuditLog({
    utilisateurId: userId,
    action:        AuditActions.LOGOUT,
    tableCible:    'refresh_tokens',
    adresseIp:     meta.ip,
    userAgent:     meta.userAgent,
  });

  logger.info('Utilisateur déconnecté', { userId });
};