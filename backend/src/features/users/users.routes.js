import { Router } from 'express';

import { authenticate }             from '../../middlewares/auth.middleware.js';
import { isAdmin, isSuperAdmin,
          isAuthenticated }          from '../../middlewares/rbac.middleware.js';
import { validate,
          updateProfileSchema,
          updateStatutSchema,
          updateRoleSchema,
          createUserSchema,
          listUsersSchema }          from './users.validator.js';
import {
  getMyProfile,
  updateMyProfile,
  createUser,
  listUsers,
  getUserById,
  updateStatut,
  updateRole,
  getActiveLivreurs,
} from './users.controller.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: Gestion des utilisateurs
 */

// ── Validation des query params pour la liste ─────────────
const validateQuery = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.query, {
    abortEarly:   false,
    stripUnknown: true,
    allowUnknown: false,
  });
  if (error) return next(error);
  req.validatedQuery = value;
  next();
};

// ════════════════════════════════════════════════════════
// ROUTES UTILISATEUR CONNECTÉ (tous rôles)
// ════════════════════════════════════════════════════════

router.get(
  '/me',
  authenticate,
  isAuthenticated,
  getMyProfile
);

router.put(
  '/me',
  authenticate,
  isAuthenticated,
  validate(updateProfileSchema),
  updateMyProfile
);

router.post(
  '/',
  authenticate,
  isAdmin,
  validate(createUserSchema),
  createUser
);

// ══════════════════════════════════════════════════════════
// ROUTES ADMIN+ — Gestion des utilisateurs
// ══════════════════════════════════════════════════

router.get(
  '/',
  authenticate,
  isAdmin,
  validateQuery(listUsersSchema),
  listUsers
);

router.get(
  '/livreurs',
  authenticate,
  isAdmin,
  getActiveLivreurs
);

router.get(
  '/:id',
  authenticate,
  isAdmin,
  getUserById
);

router.patch(
  '/:id/statut',
  authenticate,
  isAdmin,
  validate(updateStatutSchema),
  updateStatut
);

// ════════════════════════════════════════════════════════
// ROUTES SUPER_ADMIN — Gestion des rôles
// ════════════════════════════════════════════════════════

router.patch(
  '/:id/role',
  authenticate,
  isSuperAdmin,
  validate(updateRoleSchema),
  updateRole
);

export default router;