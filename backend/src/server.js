import 'dotenv/config';
import http           from 'http';
import app            from './app.js';
import { testConnection } from './config/database.js';
import initFirebase   from './config/firebase.js';
import { initSocket } from './sockets/socket.init.js';
import { createLogger } from './config/winston.js';

const logger = createLogger('server');
const PORT   = parseInt(process.env.PORT) || 3000;

// ── Création du serveur HTTP ──────────────────────────────
// On crée le serveur HTTP manuellement (pas app.listen)
// pour pouvoir y attacher Socket.io sur le même port
const httpServer = http.createServer(app);

// ── Initialisation Socket.io ──────────────────────────────
initSocket(httpServer);

// ── Démarrage ─────────────────────────────────────────────
const start = async () => {
  try {
    // 1. Test connexion PostgreSQL
    await testConnection();

    // 2. Initialisation Firebase (non bloquant si .env absent)
    initFirebase();

    // 3. Démarrage du serveur HTTP + Socket.io
    httpServer.listen(PORT, () => {
      logger.info(`✓ Serveur démarré sur http://localhost:${PORT}`);
      logger.info(`✓ Swagger disponible sur http://localhost:${PORT}/api/docs`);
      logger.info(`✓ Environnement : ${process.env.NODE_ENV}`);
    });

  } catch (err) {
    logger.error('Échec du démarrage du serveur', { error: err.message });
    process.exit(1);
  }
};

// ── Arrêt propre (SIGTERM / SIGINT) ──────────────────────
// Utile en production et pour les tests Jest
const shutdown = (signal) => {
  logger.info(`Signal ${signal} reçu — arrêt propre du serveur`);
  httpServer.close(() => {
    logger.info('Serveur HTTP fermé');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT',  () => shutdown('SIGINT'));

// ── Erreurs non interceptées ──────────────────────────────
process.on('unhandledRejection', (reason) => {
  logger.error('unhandledRejection', { reason });
});
process.on('uncaughtException', (err) => {
  logger.error('uncaughtException', { error: err.message, stack: err.stack });
  process.exit(1);
});

start();