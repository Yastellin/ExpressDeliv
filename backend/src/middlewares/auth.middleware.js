import jwt from 'jsonwebtoken';
import { AppError, ErrorCodes } from './errorHandler.js';
import { createLogger } from '../config/winston.js';

const logger = createLogger('auth');

// ── Middleware d'authentification JWT ─────────────────────
// Vérifie le header Authorization: Bearer <token>
// Injecte req.user = { id, role, email } si valide
const authenticate = (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError(
        "Token d'authentification manquant",
        401,
        ErrorCodes.UNAUTHORIZED
      );
    }

    const token = authHeader.split(' ')[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Injecte les infos utilisateur dans la requête
    req.user = {
      id:    decoded.id,
      role:  decoded.role,
      email: decoded.email,
    };

    logger.debug('Utilisateur authentifié', {
      userId: req.user.id,
      role:   req.user.role,
      url:    req.originalUrl,
    });

    next();
  } catch (err) {
    next(err);   // JWT errors interceptées par errorHandler
  }
};

// ── Middleware optionnel ──────────────────────────────────
// Utilisé sur les routes publiques qui PEUVENT recevoir un token
// (ex: catalogue produits : enrichi si connecté, accessible sinon)
const optionalAuthenticate = (req, res, next) => {
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    req.user = null;
    return next();
  }

  try {
    const token   = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.id, role: decoded.role, email: decoded.email };
  } catch {
    req.user = null;   // token invalide ignoré silencieusement
  }

  next();
};

export { authenticate, optionalAuthenticate };