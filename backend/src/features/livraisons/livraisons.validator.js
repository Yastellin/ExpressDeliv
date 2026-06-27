import Joi from 'joi';
import { validate } from '../auth/auth.validator.js';

// ── Schéma : création d'une livraison (ADMIN+) ────────────
export const createLivraisonSchema = Joi.object({
  commande_id: Joi.string().uuid().required()
    .messages({ 'any.required': "L'ID de la commande est requis" }),

  livreur_id: Joi.string().uuid().required()
    .messages({ 'any.required': "L'ID du livreur est requis" }),
});

// ── Schéma : preuve de livraison (LIVREUR) ────────────────
export const preuveSchema = Joi.object({
  type: Joi.string()
    .valid('SIGNATURE', 'CODE_PIN', 'PHOTO')
    .required()
    .messages({
      'any.only':    'Type invalide. Valeurs : SIGNATURE, CODE_PIN, PHOTO',
      'any.required': 'Le type de preuve est requis',
    }),

  // Base64 pour SIGNATURE et PHOTO, PIN numérique pour CODE_PIN
  donnee_preuve: Joi.string().required()
    .messages({ 'any.required': 'La donnée de preuve est requise' }),
}).custom((value, helpers) => {
  // Validation spécifique CODE_PIN : 4 à 8 chiffres
  if (value.type === 'CODE_PIN' && !/^\d{4,8}$/.test(value.donnee_preuve)) {
    return helpers.error('any.invalid', {
      message: 'Le code PIN doit contenir entre 4 et 8 chiffres',
    });
  }
  // Validation basique base64 pour SIGNATURE et PHOTO
  if (
    ['SIGNATURE', 'PHOTO'].includes(value.type) &&
    value.donnee_preuve.length < 100
  ) {
    return helpers.error('any.invalid', {
      message: 'Données de signature/photo invalides',
    });
  }
  return value;
});

// ── Schéma : filtres liste livraisons ─────────────────────
export const listLivraisonsSchema = Joi.object({
  page:   Joi.number().integer().min(1).default(1),
  limit:  Joi.number().integer().min(1).max(100).default(20),
  statut: Joi.string()
    .valid('AFFECTEE', 'EN_COURS', 'LIVREE', 'ECHOUEE', 'ANNULEE')
    .optional(),
  livreur_id: Joi.string().uuid().optional(),
});

export { validate };