import pg from 'pg';
import { createLogger } from './winston.js';

const { Pool } = pg;
const logger = createLogger('database');

// ── Singleton Pool ───────────────────────────────────────
let pool;

const getPool = () => {
  if (!pool) {
    pool = new Pool({
      host:     process.env.DB_HOST     || 'localhost',
      port:     parseInt(process.env.DB_PORT || '5432'),
      database: process.env.DB_NAME     || 'expressdeliv_db',
      user:     process.env.DB_USER     || 'postgres',
      password: process.env.DB_PASSWORD || 'YastellinB',
      max:                10,   // connexions max dans le pool
      idleTimeoutMillis:  30000,
      connectionTimeoutMillis: 5000,
    });

    pool.on('connect', () => {
      logger.info('Nouvelle connexion PostgreSQL établie');
    });

    pool.on('error', (err) => {
      logger.error('Erreur pool PostgreSQL', { error: err.message });
    });
  }
  return pool;
};

// ── query() : usage standard (SELECT, INSERT simple…) ────
export const query = async (text, params) => {
  const start = Date.now();
  try {
    const result = await getPool().query(text, params);
    const duration = Date.now() - start;
    logger.debug('Query exécutée', {
      text: text.substring(0, 80),
      duration: `${duration}ms`,
      rows: result.rowCount,
    });
    return result;
  } catch (err) {
    logger.error('Erreur query PostgreSQL', {
      text: text.substring(0, 80),
      error: err.message,
    });
    throw err;
  }
};

// ── getClient() : pour les transactions ACID manuelles ───
// Usage : const client = await getClient();
//         await client.query('BEGIN');
//         ... opérations ...
//         await client.query('COMMIT');
//         client.release();
export const getClient = async () => {
  const client = await getPool().connect();
  const originalRelease = client.release.bind(client);

  // Timeout de sécurité : libère le client si oublié > 10s
  const timeout = setTimeout(() => {
    logger.warn('Client PostgreSQL non libéré après 10s — libération forcée');
    originalRelease();
  }, 10000);

  client.release = () => {
    clearTimeout(timeout);
    originalRelease();
  };

  return client;
};

// ── testConnection() : appelé au démarrage du serveur ────
export const testConnection = async () => {
  const client = await getPool().connect();
  try {
    const res = await client.query('SELECT NOW() AS now');
    logger.info(`PostgreSQL connecté — serveur: ${res.rows[0].now}`);
  } finally {
    client.release();
  }
};