import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import path from 'path';
import { fileURLToPath } from 'url';

// Compatibilité __dirname avec ES Modules sur Windows
const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);
const LOG_DIR    = path.join(__dirname, '../..', 'logs');

// ── Format console : colorisé + lisible en développement ──
const consoleFormat = winston.format.combine(
  winston.format.colorize({ all: true }),
  winston.format.timestamp({ format: 'HH:mm:ss' }),
  winston.format.printf(({ timestamp, level, message, service, ...meta }) => {
    const svc  = service ? `[${service}] ` : '';
    const extra = Object.keys(meta).length
      ? ' ' + JSON.stringify(meta)
      : '';
    return `${timestamp} ${level} ${svc}${message}${extra}`;
  })
);

// ── Format fichier : JSON structuré pour analyse ──────────
const fileFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

// ── Transport : rotation journalière des fichiers ─────────
const makeRotateTransport = (level, filename) =>
  new DailyRotateFile({
    level,
    dirname:        LOG_DIR,
    filename:       `${filename}-%DATE%.log`,
    datePattern:    'YYYY-MM-DD',
    zippedArchive:  true,
    maxSize:        '20m',
    maxFiles:       '14d',   // garde 14 jours
    format:         fileFormat,
  });

// ── Loggers nommés par service ────────────────────────────
const loggers = {};

export const createLogger = (service) => {
  if (loggers[service]) return loggers[service];

  const isDev = process.env.NODE_ENV !== 'production';

  loggers[service] = winston.createLogger({
    level:            isDev ? 'debug' : 'info',
    defaultMeta:      { service },
    transports: [
      // Console uniquement hors tests
      ...(process.env.NODE_ENV !== 'test'
        ? [new winston.transports.Console({ format: consoleFormat })]
        : []
      ),
      // Fichiers rotatifs
      makeRotateTransport('info',  'combined'),
      makeRotateTransport('error', 'error'),
    ],
  });

  loggers[service].exceptions.handle(
    makeRotateTransport('error', 'exceptions')
  );

  return loggers[service];
};

// ── Logger par défaut (import direct sans service) ────────
export default createLogger('app');