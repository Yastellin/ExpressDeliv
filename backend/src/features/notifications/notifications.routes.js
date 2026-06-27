import { Router } from 'express';

import { authenticate }                  from '../../middlewares/auth.middleware.js';
import { isAuthenticated }               from '../../middlewares/rbac.middleware.js';
import { validate, registerTokenSchema } from './notifications.validator.js';
import { registerToken, unregisterToken } from './notifications.controller.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Notifications
 *   description: Gestion des tokens FCM
 */

router.post(
  '/token',
  authenticate,
  isAuthenticated,
  validate(registerTokenSchema),
  registerToken
);

router.delete(
  '/token',
  authenticate,
  isAuthenticated,
  unregisterToken
);

export default router;