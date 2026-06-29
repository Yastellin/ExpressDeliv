import { Router } from 'express';

import { authenticate }      from '../../middlewares/auth.middleware.js';
import { isClient, isAdmin,
          isAuthenticated }   from '../../middlewares/rbac.middleware.js';
import { validate,
          createCommandeSchema,
          listCommandesSchema } from './commandes.validator.js';
import {
  createCommande,
  listCommandes,
  getCommande,
  annulerCommande,
} from './commandes.controller.js';

const router = Router();

// ── Validation query params ───────────────────────────────
const validateQuery = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.query, {
    abortEarly: false, stripUnknown: true,
  });
  if (error) return next(error);
  req.validatedQuery = value;   // ✅ Nouvelle propriété
  next();
};

/**
 * @swagger
 * tags:
 *   name: Commandes
 *   description: Gestion des commandes
 */

router.post(
  '/',
  authenticate,
  isAuthenticated,
  validate(createCommandeSchema),
  createCommande
);

router.get(
  '/',
  authenticate,
  isAuthenticated,
  validateQuery(listCommandesSchema),
  listCommandes
);

router.get(
  '/:id',
  authenticate,
  isAuthenticated,
  getCommande
);

router.patch(
  '/:id/annuler',
  authenticate,
  isAuthenticated,
  annulerCommande
);

export default router;