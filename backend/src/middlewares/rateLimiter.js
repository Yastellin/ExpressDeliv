import rateLimit from 'express-rate-limit';
import { createLogger } from '../config/winston.js';

const logger = createLogger('rateLimiter');

// ── Handler commun : log + réponse uniforme ───────────────
const onLimitReached = (req, res) => {
  logger.warn('Rate limit dépassé', {
    ip:     req.ip,
    url:    req.originalUrl,
    method: req.method,
    userId: req.user?.id ?? 'anonyme',
  });

  res.status(429).json({
    success: false,
    error: {
      code:    'RATE_LIMIT_EXCEEDED',
      message: 'Trop de requêtes. Veuillez patienter avant de réessayer.',
    },
  });
};

// ── 1. Limiteur AUTH — très strict ────────────────────────
// Routes : POST /auth/login, POST /auth/register
// 10 tentatives par IP toutes les 15 minutes
// Protège contre le brute-force sur les mots de passe
export const authLimiter = rateLimit({
  windowMs:         15 * 60 * 1000,   // 15 minutes
  max:              10,
  standardHeaders:  true,             // RateLimit-* headers
  legacyHeaders:    false,
  skipSuccessfulRequests: true,       // ne compte que les échecs
  handler:          onLimitReached,
});

// ── 2. Limiteur API général ───────────────────────────────
// Toutes les routes API authentifiées
// 100 requêtes par IP toutes les 15 minutes
export const apiLimiter = rateLimit({
  windowMs:        15 * 60 * 1000,
  max:             100,
  standardHeaders: true,
  legacyHeaders:   false,
  handler:         onLimitReached,
});

// ── 3. Limiteur GPS — souple ──────────────────────────────
// Route : POST /livraisons/:id/gps (HTTP fallback)
// Le GPS envoie une position toutes les 5s via Socket.io
// Ce limiteur couvre uniquement le fallback HTTP
// 300 requêtes par IP toutes les 5 minutes
export const gpsLimiter = rateLimit({
  windowMs:        5 * 60 * 1000,
  max:             300,
  standardHeaders: true,
  legacyHeaders:   false,
  handler:         onLimitReached,
});

// ── 4. Limiteur upload — preuve de livraison ──────────────
// Route : POST /livraisons/:id/preuve
// Limité à 20 uploads par heure par IP
export const uploadLimiter = rateLimit({
  windowMs:        60 * 60 * 1000,   // 1 heure
  max:             20,
  standardHeaders: true,
  legacyHeaders:   false,
  handler:         onLimitReached,
});