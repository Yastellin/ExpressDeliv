import express       from 'express';
import cors          from 'cors';
import helmet        from 'helmet';
import 'dotenv/config';

import { apiLimiter }                    from './middlewares/rateLimiter.js';
import errorHandler, { notFoundHandler } from './middlewares/errorHandler.js';
import { createLogger }                  from './config/winston.js';

// ── Import des routes par feature ────────────────────────
// Chaque feature expose son propre router
import authRoutes          from './features/auth/auth.routes.js';
import userRoutes          from './features/users/users.routes.js';
import commandeRoutes      from './features/commandes/commandes.routes.js';
import livraisonRoutes     from './features/livraisons/livraisons.routes.js';
import incidentRoutes      from './features/incidents/incidents.routes.js';
import notificationRoutes  from './features/notifications/notifications.routes.js';
import statsRoutes         from './features/stats/stats.routes.js';

// ── Swagger ───────────────────────────────────────────────
import swaggerUi   from 'swagger-ui-express';
import swaggerSpec from '../swagger.js';

const logger = createLogger('app');
const app    = express();

// ════════════════════════════════════════════════════════
// MIDDLEWARES GLOBAUX
// ════════════════════════════════════════════════════════

// Sécurité HTTP headers
app.use(helmet());

// CORS
app.use(cors({
  origin:      process.env.CORS_ORIGIN || '*',
  methods:     ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Parsing JSON + URL-encoded
app.use(express.json({ limit: '10mb' }));         // 10mb pour les photos base64
app.use(express.urlencoded({ extended: true }));

// Log de chaque requête entrante
app.use((req, _res, next) => {
  logger.debug(`→ ${req.method} ${req.originalUrl}`);
  next();
});

// Rate limiting global sur toutes les routes /api
app.use('/api', apiLimiter);

// ════════════════════════════════════════════════════════
// ROUTES
// ════════════════════════════════════════════════════════
const API = '/api/v1';

app.use(`${API}/auth`,          authRoutes);
app.use(`${API}/users`,         userRoutes);
app.use(`${API}/commandes`,     commandeRoutes);
app.use(`${API}/livraisons`,    livraisonRoutes);
app.use(`${API}/incidents`,     incidentRoutes);
app.use(`${API}/notifications`, notificationRoutes);
app.use(`${API}/stats`,         statsRoutes);

// Documentation Swagger
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Health check
app.get('/health', (_req, res) => {
  res.json({ success: true, message: 'EXPRESSDELIV API opérationnelle', version: '1.0.0' });
});

// ════════════════════════════════════════════════════════
// GESTION DES ERREURS (toujours en dernier)
// ════════════════════════════════════════════════════════
app.use(notFoundHandler);   // 404 — route inconnue
app.use(errorHandler);      // 500 — erreurs applicatives

export default app;