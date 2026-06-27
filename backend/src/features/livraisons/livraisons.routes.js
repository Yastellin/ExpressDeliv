import { Router } from 'express';

import { authenticate }       from '../../middlewares/auth.middleware.js';
import { isLivreur, isAdmin,
          isAuthenticated }    from '../../middlewares/rbac.middleware.js';
import { uploadLimiter }     from '../../middlewares/rateLimiter.js';
import { validate,
          createLivraisonSchema,
          preuveSchema,
          listLivraisonsSchema } from './livraisons.validator.js';
import {
  createLivraison,
  getMesMissions,
  accepterLivraison,
  refuserLivraison,
  soumettrePreuve,
  listLivraisons,
  getLivraison,
  getPositions,
} from './livraisons.controller.js';

const router = Router();

const validateQuery = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.query, {
    abortEarly: false, stripUnknown: true,
  });
  if (error) return next(error);
  req.validatedQuery = value; 
  next();
};

/**
 * @swagger
 * tags:
 *   name: Livraisons
 *   description: Gestion des livraisons et missions
 */

router.post(
  '/',
  authenticate,
  isAdmin,
  validate(createLivraisonSchema),
  createLivraison
);

router.get(
  '/mes-missions',
  authenticate,
  isLivreur,
  getMesMissions
);

router.get(
  '/',
  authenticate,
  isAuthenticated,
  validateQuery(listLivraisonsSchema),
  listLivraisons
);

router.get(
  '/:id',
  authenticate,
  isAuthenticated,
  getLivraison
);

router.get(
  '/:id/positions',
  authenticate,
  isAuthenticated,
  getPositions
);

router.patch(
  '/:id/accepter',
  authenticate,
  isLivreur,
  accepterLivraison
);

router.patch(
  '/:id/refuser',
  authenticate,
  isLivreur,
  refuserLivraison
);

router.post(
  '/:id/preuve',
  authenticate,
  isLivreur,
  uploadLimiter,
  validate(preuveSchema),
  soumettrePreuve
);

export default router;