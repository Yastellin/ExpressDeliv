import Joi from 'joi';
import { validate } from '../auth/auth.validator.js';

// ── Schéma : enregistrement token FCM ─────────────────────
export const registerTokenSchema = Joi.object({
  token_fcm: Joi.string().min(10).required()
    .messages({
      'string.min':    'Token FCM invalide',
      'any.required': 'Le token FCM est requis',
    }),

  plateforme: Joi.string()
    .valid('ANDROID', 'IOS')
    .required()
    .messages({
      'any.only':    'Plateforme invalide. Valeurs acceptées : ANDROID, IOS',
      'any.required': 'La plateforme est requise',
    }),
});

export { validate };