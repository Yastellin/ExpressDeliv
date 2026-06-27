import { Router } from 'express';
import Joi        from 'joi';

import { authenticate } from '../../middlewares/auth.middleware.js';
import { isAdmin }      from '../../middlewares/rbac.middleware.js';
import {
  getDashboardStats,
  getLivraisonsParJour,
  getTopLivreurs,
  getIncidentsParType,
} from './stats.repository.js';

const router = Router();

// ── Schéma validation query params ───────────────────────
const dashboardSchema = Joi.object({
  periode: Joi.string().valid('1d', '7d', '30d', '90d').default('7d'),
});

const graphSchema = Joi.object({
  jours: Joi.number().integer().min(1).max(90).default(7),
});

const topSchema = Joi.object({
  limit: Joi.number().integer().min(1).max(20).default(5),
});

/**
 * @swagger
 * tags:
 *   name: Stats
 *   description: Statistiques et KPIs du dashboard admin
 */

/**
 * @swagger
 * /stats/dashboard:
 *   get:
 *     summary: KPIs principaux (commandes, livraisons, incidents, users)
 *     tags: [Stats]
 *     parameters:
 *       - in: query
 *         name: periode
 *         schema:
 *           type: string
 *           enum: [1d, 7d, 30d, 90d]
 *           default: 7d
 *     responses:
 *       200:
 *         description: Statistiques retournées
 */
router.get('/dashboard', authenticate, isAdmin, async (req, res, next) => {
  try {
    const { error, value } = dashboardSchema.validate(req.query, {
      stripUnknown: true,
    });
    if (error) return next(error);

    const stats = await getDashboardStats(value.periode);
    res.status(200).json({
      success: true,
      data:    stats,
    });
  } catch (err) { next(err); }
});

/**
 * @swagger
 * /stats/livraisons/graphique:
 *   get:
 *     summary: Évolution journalière des livraisons (pour graphique)
 *     tags: [Stats]
 *     parameters:
 *       - in: query
 *         name: jours
 *         schema: { type: integer, default: 7 }
 *     responses:
 *       200:
 *         description: Données journalières
 */
router.get('/livraisons/graphique', authenticate, isAdmin, async (req, res, next) => {
  try {
    const { error, value } = graphSchema.validate(req.query, {
      stripUnknown: true,
    });
    if (error) return next(error);

    const data = await getLivraisonsParJour(value.jours);
    res.status(200).json({
      success: true,
      data,
    });
  } catch (err) { next(err); }
});

/**
 * @swagger
 * /stats/livreurs/top:
 *   get:
 *     summary: Classement des meilleurs livreurs
 *     tags: [Stats]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 5 }
 *     responses:
 *       200:
 *         description: Top livreurs
 */
router.get('/livreurs/top', authenticate, isAdmin, async (req, res, next) => {
  try {
    const { error, value } = topSchema.validate(req.query, {
      stripUnknown: true,
    });
    if (error) return next(error);

    const data = await getTopLivreurs(value.limit);
    res.status(200).json({
      success: true,
      data,
    });
  } catch (err) { next(err); }
});

/**
 * @swagger
 * /stats/incidents/types:
 *   get:
 *     summary: Répartition des incidents par type (camembert)
 *     tags: [Stats]
 *     responses:
 *       200:
 *         description: Répartition retournée
 */
router.get('/incidents/types', authenticate, isAdmin, async (req, res, next) => {
  try {
    const data = await getIncidentsParType();
    res.status(200).json({
      success: true,
      data,
    });
  } catch (err) { next(err); }
});

export default router;