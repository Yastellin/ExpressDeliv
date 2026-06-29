import * as UsersRepository from './users.repository.js';
import { findUserByEmail, createUser as createUserRepository } from '../auth/auth.repository.js';
import bcrypt from 'bcryptjs';
import { AppError, ErrorCodes }        from '../../middlewares/errorHandler.js';
import { createAuditLog, AuditActions } from '../../middlewares/auditLogger.js';
import { createLogger }                 from '../../config/winston.js';

const logger = createLogger('usersService');

// ══════════════════════════════════════════════════════════
// getProfile() — Récupère le profil d'un utilisateur par ID
// ══════════════════════════════════════════════════════════
export const getProfile = async (id) => {
  const user = await UsersRepository.findById(id);
  if (!user) {
    throw new AppError(
      'Utilisateur introuvable',
      404,
      ErrorCodes.NOT_FOUND
    );
  }
  return user;
};

export const createUser = async (userData, adminId, meta = {}) => {
  const { nom, prenom, email, telephone, password, role, adresse_defaut } = userData;

  const existing = await findUserByEmail(email);
  if (existing) {
    throw new AppError(
      'Un compte avec cet email existe déjà',
      409,
      ErrorCodes.ALREADY_EXISTS
    );
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await createUserRepository({
    nom,
    prenom,
    email,
    telephone,
    passwordHash,
    adresseDefaut: adresse_defaut,
    role,
  });

  await createAuditLog({
    utilisateurId:  adminId,
    action:         AuditActions.USER_CREATED,
    tableCible:     'utilisateurs',
    entiteId:       user.id,
    nouvelleValeur: { email, nom, prenom, role },
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  logger.info('Utilisateur créé par un admin', { userId: user.id, role, adminId });
  return user;
};

// ══════════════════════════════════════════════════════════
// updateProfile() — Mise à jour du profil utilisateur
// ══════════════════════════════════════════════════
export const updateProfile = async (id, fields, meta = {}) => {
  // Vérifier que l'utilisateur existe
  const existing = await UsersRepository.findById(id);
  if (!existing) {
    throw new AppError(
      'Utilisateur introuvable',
      404,
      ErrorCodes.NOT_FOUND
    );
  }

  const updated = await UsersRepository.updateProfile(id, fields);
  if (!updated) {
    throw new AppError(
      'Aucun champ valide à mettre à jour',
      400,
      ErrorCodes.VALIDATION_ERROR
    );
  }

  // Audit : trace ancienne et nouvelle valeur
  await createAuditLog({
    utilisateurId:  id,
    action:         AuditActions.USER_UPDATED,
    tableCible:     'utilisateurs',
    entiteId:       id,
    ancienneValeur: {
      nom:       existing.nom,
      prenom:    existing.prenom,
      telephone: existing.telephone,
    },
    nouvelleValeur: fields,
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  logger.info('Profil mis à jour', { userId: id });
  return updated;
};

// ══════════════════════════════════════════════════════════
// listUsers() — Liste paginée (ADMIN+)
// ══════════════════════════════════════════════════════════
export const listUsers = async (filters) => {
  return await UsersRepository.findAll(filters);
};

// ══════════════════════════════════════════════════════════
// getUserById() — Détail d'un utilisateur (ADMIN+)
// ══════════════════════════════════════════════════════════
export const getUserById = async (id) => {
  const user = await UsersRepository.findById(id);
  if (!user) {
    throw new AppError(
      'Utilisateur introuvable',
      404,
      ErrorCodes.NOT_FOUND
    );
  }
  return user;
};

// ══════════════════════════════════════════════════════════
// updateStatut() — Activation/suspension (ADMIN+)
// ══════════════════════════════════════════════════════════
export const updateStatut = async (targetId, newStatut, adminId, meta = {}) => {
  // Vérifier que la cible existe
  const existing = await UsersRepository.findById(targetId);
  if (!existing) {
    throw new AppError(
      'Utilisateur introuvable',
      404,
      ErrorCodes.NOT_FOUND
    );
  }

  // Empêcher l'admin de se suspendre lui-même
  if (targetId === adminId) {
    throw new AppError(
      'Vous ne pouvez pas modifier votre propre statut',
      403,
      ErrorCodes.FORBIDDEN
    );
  }

  // Inutile de mettre à jour si statut identique
  if (existing.statut === newStatut) {
    throw new AppError(
      `L'utilisateur est déjà en statut ${newStatut}`,
      400,
      ErrorCodes.VALIDATION_ERROR
    );
  }

  const updated = await UsersRepository.updateStatut(targetId, newStatut);

  await createAuditLog({
    utilisateurId:  adminId,
    action:         AuditActions.USER_STATUS_CHANGED,
    tableCible:     'utilisateurs',
    entiteId:       targetId,
    ancienneValeur: { statut: existing.statut },
    nouvelleValeur: { statut: newStatut },
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  logger.info('Statut utilisateur modifié', {
    targetId,
    oldStatut: existing.statut,
    newStatut,
    adminId,
  });

  return updated;
};

// ══════════════════════════════════════════════════════════
// updateRole() — Changement de rôle (SUPER_ADMIN)
// ══════════════════════════════════════════════════════════
export const updateRole = async (targetId, newRole, superAdminId, meta = {}) => {
  const existing = await UsersRepository.findById(targetId);
  if (!existing) {
    throw new AppError(
      'Utilisateur introuvable',
      404,
      ErrorCodes.NOT_FOUND
    );
  }

  // Empêcher de se changer son propre rôle
  if (targetId === superAdminId) {
    throw new AppError(
      'Vous ne pouvez pas modifier votre propre rôle',
      403,
      ErrorCodes.FORBIDDEN
    );
  }

  if (existing.role_nom === newRole) {
    throw new AppError(
      `L'utilisateur possède déjà le rôle ${newRole}`,
      400,
      ErrorCodes.VALIDATION_ERROR
    );
  }

  const updated = await UsersRepository.updateRole(targetId, newRole);

  await createAuditLog({
    utilisateurId:  superAdminId,
    action:         AuditActions.USER_ROLE_CHANGED,
    tableCible:     'utilisateurs',
    entiteId:       targetId,
    ancienneValeur: { role: existing.role_nom },
    nouvelleValeur: { role: newRole },
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  logger.info('Rôle utilisateur modifié', {
    targetId,
    oldRole: existing.role_nom,
    newRole,
    superAdminId,
  });

  return updated;
};

// ══════════════════════════════════════════════════════════
// getActiveLivreurs() — Liste des livreurs disponibles
// ══════════════════════════════════════════════════════════
export const getActiveLivreurs = async (zone = null) => {
  return await UsersRepository.findActiveLivreurs(zone);
};