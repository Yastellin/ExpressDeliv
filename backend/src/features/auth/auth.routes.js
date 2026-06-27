import { Router } from 'express';

import { authLimiter }    from '../../middlewares/rateLimiter.js';
import { authenticate }   from '../../middlewares/auth.middleware.js';
import { validate,
          registerSchema,
          loginSchema,
          refreshSchema }  from './auth.validator.js';
import {
  registerController,
  loginController,
  refreshController,
  logoutController,
  meController,
} from './auth.controller.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentification et gestion des sessions
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Inscription d'un nouveau client
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [nom, prenom, email, telephone, password]
 *             properties:
 *               nom:        { type: string, example: Rakoto }
 *               prenom:     { type: string, example: Jean }
 *               email:      { type: string, example: jean@example.com }
 *               telephone:  { type: string, example: "0340000000" }
 *               password:   { type: string, example: motdepasse1 }
 *     responses:
 *       201:
 *         description: Inscription réussie
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SuccessResponse'
 *       409:
 *         description: Email déjà utilisé
 *       422:
 *         description: Données invalides
 */
router.post(
  '/register',
  authLimiter,
  validate(registerSchema),
  registerController
);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Connexion d'un utilisateur
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email:    { type: string, example: jean@example.com }
 *               password: { type: string, example: motdepasse1 }
 *     responses:
 *       200:
 *         description: Connexion réussie — retourne accessToken + refreshToken
 *       401:
 *         description: Email ou mot de passe incorrect
 */
router.post(
  '/login',
  authLimiter,
  validate(loginSchema),
  loginController
);

/**
 * @swagger
 * /auth/refresh:
 *   post:
 *     summary: Renouveler le access token
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [refreshToken]
 *             properties:
 *               refreshToken: { type: string }
 *     responses:
 *       200:
 *         description: Nouveau access token retourné
 *       401:
 *         description: Refresh token invalide ou expiré
 */
router.post(
  '/refresh',
  validate(refreshSchema),
  refreshController
);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Déconnexion — révoque le refresh token
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [refreshToken]
 *             properties:
 *               refreshToken: { type: string }
 *     responses:
 *       200:
 *         description: Déconnexion réussie
 *       401:
 *         description: Non authentifié
 */
router.post(
  '/logout',
  authenticate,
  logoutController
);

/**
 * @swagger
 * /auth/me:
 *   get:
 *     summary: Profil de l'utilisateur connecté
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profil retourné
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Utilisateur'
 *       401:
 *         description: Non authentifié
 */
router.get(
  '/me',
  authenticate,
  meController
);

export default router;