import { Router } from 'express';

import { authenticate }     from '../../middlewares/auth.middleware.js';
import { isLivreur, isAdmin,
          isAuthenticated }  from '../../middlewares/rbac.middleware.js';
import { validate,
          createIncidentSchema,
          listIncidentsSchema } from './incidents.validator.js';
import {
  createIncident,
  listIncidents,
  resoudreIncident,
} from './incidents.controller.js';

const router = Router();

const validateQuery = (schema) => (req, res, next) => {
  const { error, value } = schema.validate(req.query, {
    abortEarly: false, stripUnknown: true,
  });
  if (error) return next(error);
  req.query = value;
  next();
};

/**
 * @swagger
 * tags:
 *   name: Incidents
 *   description: Gestion des incidents de livraison
 */

router.post(
  '/',
  authenticate,
  isLivreur,
  validate(createIncidentSchema),
  createIncident
);

router.get(
  '/',
  authenticate,
  isAuthenticated,
  validateQuery(listIncidentsSchema),
  listIncidents
);

router.patch(
  '/:id/resoudre',
  authenticate,
  isAdmin,
  resoudreIncident
);

export default router;