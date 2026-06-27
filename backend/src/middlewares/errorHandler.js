import { createLogger } from '../config/winston.js';

const logger = createLogger('errorHandler');

// ── Classe d'erreur applicative personnalisée ─────────────
// Usage : throw new AppError('Message', 404)
// Tous les services et controllers utilisent cette classe
export class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode  = statusCode;
    this.code        = code;
    this.isOperational = true;   // erreur métier connue, pas un bug
    Error.captureStackTrace(this, this.constructor);
  }
}

// ── Codes d'erreur standardisés ───────────────────────────
export const ErrorCodes = {
  // Auth
  UNAUTHORIZED:        'UNAUTHORIZED',
  FORBIDDEN:           'FORBIDDEN',
  TOKEN_EXPIRED:       'TOKEN_EXPIRED',
  TOKEN_INVALID:       'TOKEN_INVALID',
  // Ressources
  NOT_FOUND:           'NOT_FOUND',
  ALREADY_EXISTS:      'ALREADY_EXISTS',
  // Validation
  VALIDATION_ERROR:    'VALIDATION_ERROR',
  // Métier
  INVALID_STATUS:      'INVALID_STATUS',
  INSUFFICIENT_RIGHTS: 'INSUFFICIENT_RIGHTS',
  // Serveur
  INTERNAL_ERROR:      'INTERNAL_ERROR',
  DB_ERROR:            'DB_ERROR',
};

// ── Format de réponse d'erreur uniforme ───────────────────
// Toutes les erreurs retournent exactement ce format :
// { success: false, error: { code, message, details? } }
const formatError = (code, message, details = null) => ({
  success: false,
  error: {
    code,
    message,
    ...(details && { details }),
  },
});

// ── Middleware principal (4 paramètres = gestionnaire d'erreur Express) ──
// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  const isDev = process.env.NODE_ENV === 'development';

  // ── 1. Erreur de validation Joi ───────────────────────────
  if (err.isJoi || err.name === 'ValidationError') {
    const details = err.details?.map((d) => ({
      field:   d.path.join('.'),
      message: d.message.replace(/['"]/g, ''),
    }));
    return res.status(422).json(
      formatError(ErrorCodes.VALIDATION_ERROR, 'Données invalides', details)
    );
  }

  // ── 2. Erreur JWT ─────────────────────────────────────────
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json(
      formatError(ErrorCodes.TOKEN_EXPIRED, 'Session expirée, veuillez vous reconnecter')
    );
  }
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json(
      formatError(ErrorCodes.TOKEN_INVALID, 'Token invalide')
    );
  }

  // ── 3. Erreur PostgreSQL ──────────────────────────────────
  if (err.code === '23505') {   // unique_violation
    return res.status(409).json(
      formatError(ErrorCodes.ALREADY_EXISTS, 'Cette ressource existe déjà')
    );
  }
  if (err.code === '23503') {   // foreign_key_violation
    return res.status(400).json(
      formatError(ErrorCodes.VALIDATION_ERROR, 'Référence invalide dans les données')
    );
  }

  // ── 4. Erreur applicative métier (AppError) ───────────────
  if (err.isOperational) {
    logger.warn('Erreur métier', {
      code:    err.code,
      message: err.message,
      url:     req.originalUrl,
      method:  req.method,
    });
    return res.status(err.statusCode).json(
      formatError(err.code, err.message)
    );
  }

  // ── 5. Erreur inattendue (bug) ────────────────────────────
  logger.error('Erreur serveur inattendue', {
    message: err.message,
    stack:   err.stack,
    url:     req.originalUrl,
    method:  req.method,
    userId:  req.user?.id,
  });

  return res.status(500).json(
    formatError(
      ErrorCodes.INTERNAL_ERROR,
      isDev ? err.message : 'Une erreur interne est survenue',
      isDev ? { stack: err.stack } : null
    )
  );
};

// ── Middleware 404 : route non trouvée ────────────────────
export const notFoundHandler = (req, res) => {
  res.status(404).json(
    formatError(ErrorCodes.NOT_FOUND, `Route ${req.method} ${req.originalUrl} introuvable`)
  );
};

export default errorHandler;