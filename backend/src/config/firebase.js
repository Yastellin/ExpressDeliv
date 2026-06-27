import admin from 'firebase-admin';
import { createLogger } from './winston.js';

const logger = createLogger('firebase');

// ── Initialisation unique (guard contre double init) ──────
let firebaseApp;

const initFirebase = () => {
  if (firebaseApp) return firebaseApp;

  // En mode test : on n'initialise pas Firebase
  if (process.env.NODE_ENV === 'test') {
    logger.info('Firebase désactivé en mode test');
    return null;
  }

  // Vérification des variables d'environnement obligatoires
  const required = [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_CLIENT_EMAIL',
    'FIREBASE_PRIVATE_KEY',
  ];
  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    logger.warn(
      `Firebase non configuré — variables manquantes : ${missing.join(', ')}. ` +
      'Les notifications push seront désactivées.'
    );
    return null;
  }

  try {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId:   process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        // Le \n est encodé en chaîne dans le .env Windows
        privateKey:  process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      }),
    });
    logger.info(`Firebase initialisé — projet : ${process.env.FIREBASE_PROJECT_ID}`);
    return firebaseApp;
  } catch (err) {
    logger.error('Erreur initialisation Firebase', { error: err.message });
    return null;
  }
};

// ── FCMService : méthodes d'envoi de notifications ────────
export const FCMService = {

  /**
   * Envoie une notification à UN appareil
   * @param {string} token     - Token FCM de l'appareil
   * @param {string} title     - Titre de la notification
   * @param {string} body      - Corps du message
   * @param {object} data      - Données supplémentaires (optionnel)
   */
  send: async (token, title, body, data = {}) => {
    const app = initFirebase();
    if (!app) return null;

    try {
      const message = {
        token,
        notification: { title, body },
        data:         Object.fromEntries(
          Object.entries(data).map(([k, v]) => [k, String(v)])
        ),
        android: { priority: 'high' },
        apns:    { payload: { aps: { sound: 'default' } } },
      };

      const response = await admin.messaging().send(message);
      logger.debug('Notification envoyée', { title, messageId: response });
      return response;
    } catch (err) {
      logger.error('Erreur envoi notification FCM', {
        token: token.substring(0, 20) + '...',
        error: err.message,
      });
      return null;   // non bloquant : l'app continue si FCM échoue
    }
  },

  /**
   * Envoie une notification à PLUSIEURS appareils (max 500)
   * @param {string[]} tokens  - Liste de tokens FCM
   * @param {string}   title
   * @param {string}   body
   * @param {object}   data
   */
  sendMultiple: async (tokens, title, body, data = {}) => {
    const app = initFirebase();
    if (!app || !tokens.length) return null;

    try {
      const message = {
        notification: { title, body },
        data:         Object.fromEntries(
          Object.entries(data).map(([k, v]) => [k, String(v)])
        ),
        android: { priority: 'high' },
        apns:    { payload: { aps: { sound: 'default' } } },
        tokens,    // sendEachForMulticast attend ce champ
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      logger.debug('Notifications multiples envoyées', {
        total:   tokens.length,
        success: response.successCount,
        failure: response.failureCount,
      });
      return response;
    } catch (err) {
      logger.error('Erreur envoi notifications multiples', { error: err.message });
      return null;
    }
  },
};

export default initFirebase;