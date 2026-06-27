import Joi from 'joi';
import { validate } from '../auth/auth.validator.js';

// ── Schéma : déclaration d'un incident (LIVREUR) ──────────
export const createIncidentSchema = Joi.object({
  livraison_id: Joi.string().uuid().required()
    .messages({ 'any.required': "L'ID de la livraison est requis" }),

  type: Joi.string()
    .valid('CLIENT_ABSENT', 'ADRESSE_INTROUVABLE', 'PANNE_VEHICULE', 'ACCIDENT', 'AUTRE')
    .required()
    .messages({
      'any.only':    "Type d'incident invalide",
      'any.required': "Le type d'incident est requis",
    }),

  description: Joi.string().min(10).max(1000).required()
    .messages({
      'string.min':    'La description doit contenir au moins 10 caractères',
      'any.required': 'La description est requise',
    }),
});

// ── Schéma : filtres liste incidents ──────────────────────
export const listIncidentsSchema = Joi.object({
  page:   Joi.number().integer().min(1).default(1),
  limit:  Joi.number().integer().min(1).max(100).default(20),
  type:   Joi.string()
    .valid('CLIENT_ABSENT', 'ADRESSE_INTROUVABLE', 'PANNE_VEHICULE', 'ACCIDENT', 'AUTRE')
    .optional(),
  resolu: Joi.boolean().optional(),
});

export { validate };