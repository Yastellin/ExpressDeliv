import Joi from 'joi';
import { validate } from '../auth/auth.validator.js';

// ── Schéma : un colis ─────────────────────────────────────
const colisSchema = Joi.object({
  description:   Joi.string().min(2).max(255).required()
                   .messages({ 'any.required': 'La description du colis est requise' }),

  poids:         Joi.number().positive().max(500).optional()
                   .messages({ 'number.positive': 'Le poids doit être positif' }),

  prix_unitaire: Joi.number().min(0).required()
                   .messages({ 'any.required': 'Le prix unitaire est requis' }),

  fragile:       Joi.boolean().default(false),

  dimensions:    Joi.object({
    longueur: Joi.number().positive().optional(),
    largeur:  Joi.number().positive().optional(),
    hauteur:  Joi.number().positive().optional(),
  }).optional(),
});

// ── Schéma : création de commande ─────────────────────────
export const createCommandeSchema = Joi.object({
  adresse_livraison: Joi.string().min(5).max(500).required()
    .messages({ 'any.required': "L'adresse de livraison est requise" }),

  expediteur_nom: Joi.string().min(2).max(100).required()
    .messages({ 'any.required': 'Le nom de l\'expéditeur est requis' }),
  expediteur_prenom: Joi.string().min(2).max(100).required()
    .messages({ 'any.required': 'Le prénom de l\'expéditeur est requis' }),
  expediteur_telephone: Joi.string().min(8).max(20).required()
    .messages({ 'any.required': 'Le téléphone de l\'expéditeur est requis' }),

  adresse_livraison_lat: Joi.number().min(-90).max(90).optional(),
  adresse_livraison_lng: Joi.number().min(-180).max(180).optional(),
  notes: Joi.string().max(500).allow('', null).optional(),

  // ✅ NOUVEAU : champ optionnel pour l'admin
  client_id: Joi.string().uuid().optional(),

  colis: Joi.array()
    .items(colisSchema)
    .min(1)
    .max(20)
    .required()
    .messages({
      'array.min':    'La commande doit contenir au moins 1 colis',
      'array.max':    'La commande ne peut pas contenir plus de 20 colis',
      'any.required': 'La liste des colis est requise',
    }),
});

// ── Schéma : filtres liste commandes ──────────────────────
export const listCommandesSchema = Joi.object({
  page:   Joi.number().integer().min(1).default(1),
  limit:  Joi.number().integer().min(1).max(100).default(20),
  statut: Joi.string()
    .valid('EN_ATTENTE', 'CONFIRMEE', 'EN_COURS', 'LIVREE', 'ANNULEE')
    .optional(),
  client_id: Joi.string().uuid().optional(),
  date_from: Joi.date().iso().optional(),
  date_to:   Joi.date().iso().min(Joi.ref('date_from')).optional()
    .messages({ 'date.min': 'date_to doit être après date_from' }),
});

export { validate };