import Joi from 'joi';
import { validate } from '../auth/auth.validator.js';

// ── Schéma : mise à jour profil (PATCH /users/me) ─────────
// Tous les champs sont optionnels — on ne met à jour que ce qui est envoyé
export const updateProfileSchema = Joi.object({
  nom: Joi.string()
    .min(2).max(100)
    .pattern(/^[a-zA-ZÀ-ÿ\s\-']+$/)
    .optional()
    .messages({ 'string.pattern.base': 'Le nom ne doit contenir que des lettres' }),

  prenom: Joi.string()
    .min(2).max(100)
    .pattern(/^[a-zA-ZÀ-ÿ\s\-']+$/)
    .optional()
    .messages({ 'string.pattern.base': 'Le prénom ne doit contenir que des lettres' }),

  telephone: Joi.string()
    .pattern(/^[0-9+\s\-]{8,20}$/)
    .optional()
    .messages({ 'string.pattern.base': 'Numéro de téléphone invalide' }),

  adresse_defaut: Joi.string()
    .max(500)
    .allow('', null)
    .optional(),

  zone_geographique: Joi.string()
    .max(100)
    .allow('', null)
    .optional(),
}).min(1)  // Au moins un champ requis
  .messages({ 'object.min': 'Au moins un champ doit être fourni' });

// ── Schéma : changement de statut (PATCH /users/:id/statut) ─
// Réservé ADMIN+
export const updateStatutSchema = Joi.object({
  statut: Joi.string()
    .valid('ACTIF', 'INACTIF', 'SUSPENDU')
    .required()
    .messages({
      'any.only':    'Statut invalide. Valeurs acceptées : ACTIF, INACTIF, SUSPENDU',
      'any.required': 'Le statut est requis',
    }),
});

// ── Schéma : changement de rôle (PATCH /users/:id/role) ──
// Réservé SUPER_ADMIN uniquement
export const updateRoleSchema = Joi.object({
  role: Joi.string()
    .valid('CLIENT', 'LIVREUR', 'ADMIN', 'SUPER_ADMIN')
    .required()
    .messages({
      'any.only':    'Rôle invalide',
      'any.required': 'Le rôle est requis',
    }),
});

// ── Schéma : pagination liste utilisateurs ────────────────
export const listUsersSchema = Joi.object({
  page:   Joi.number().integer().min(1).default(1),
  limit:  Joi.number().integer().min(1).max(100).default(20),
  role:   Joi.string().valid('CLIENT', 'LIVREUR', 'ADMIN', 'SUPER_ADMIN').optional(),
  statut: Joi.string().valid('ACTIF', 'INACTIF', 'SUSPENDU').optional(),
  search: Joi.string().max(100).optional(),
});

// Re-export du middleware validate pour usage dans routes
export { validate };