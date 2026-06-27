import { query } from '../config/database.js';
import { createLogger } from '../config/winston.js';

const logger = createLogger('audit');

// ── Actions auditables définies ───────────────────────────
export const AuditActions = {
  // Auth
  LOGIN:                  'AUTH_LOGIN',
  LOGOUT:                 'AUTH_LOGOUT',
  REGISTER:               'AUTH_REGISTER',
  // Utilisateurs
  USER_UPDATED:           'USER_UPDATED',
  USER_STATUS_CHANGED:    'USER_STATUS_CHANGED',
  USER_ROLE_CHANGED:      'USER_ROLE_CHANGED',
  // Commandes
  COMMANDE_CREATED:       'COMMANDE_CREATED',
  COMMANDE_CANCELLED:     'COMMANDE_CANCELLED',
  // Livraisons
  LIVRAISON_CREATED:      'LIVRAISON_CREATED',
  LIVRAISON_ACCEPTED:     'LIVRAISON_ACCEPTED',
  LIVRAISON_REFUSED:      'LIVRAISON_REFUSED',
  LIVRAISON_COMPLETED:    'LIVRAISON_COMPLETED',
  LIVRAISON_REASSIGNED:   'LIVRAISON_REASSIGNED',
  // Incidents
  INCIDENT_DECLARED:      'INCIDENT_DECLARED',
  INCIDENT_RESOLVED:      'INCIDENT_RESOLVED',
  // Preuves
  PREUVE_SUBMITTED:       'PREUVE_SUBMITTED',
};

// ── Fonction principale d'enregistrement ──────────────────
// Appelée directement depuis les services après une action critique
// Non bloquante : une erreur d'audit ne fait pas échouer la requête
export const createAuditLog = async ({
  utilisateurId,
  action,
  tableCible    = null,
  entiteId      = null,
  ancienneValeur = null,
  nouvelleValeur = null,
  adresseIp     = null,
  userAgent     = null,
}) => {
  try {
    await query(
      `INSERT INTO historique_audits
         (utilisateur_id, action, table_cible, entite_id,
          ancienne_valeur, nouvelle_valeur, adresse_ip, user_agent)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        utilisateurId,
        action,
        tableCible,
        entiteId,
        ancienneValeur ? JSON.stringify(ancienneValeur) : null,
        nouvelleValeur ? JSON.stringify(nouvelleValeur) : null,
        adresseIp,
        userAgent,
      ]
    );
  } catch (err) {
    // Non bloquant : on logue l'échec mais on ne fait pas échouer la requête
    logger.error('Échec enregistrement audit', {
      action,
      utilisateurId,
      error: err.message,
    });
  }
};

// ── Middleware Express pour audit automatique ─────────────
// Usage sur une route :
//   router.post('/', authenticate, audit('COMMANDE_CREATED', 'commandes'), controller)
//
// Intercepte la réponse après son envoi pour enregistrer
// l'audit uniquement si la requête a réussi (2xx)
const audit = (action, tableCible = null) => {
  return (req, res, next) => {
    // Surcharge res.json pour intercepter la réponse
    const originalJson = res.json.bind(res);

    res.json = function (body) {
      // Enregistre l'audit seulement si succès (status 2xx)
      if (res.statusCode >= 200 && res.statusCode < 300) {
        createAuditLog({
          utilisateurId:  req.user?.id ?? null,
          action,
          tableCible,
          entiteId:       body?.data?.id ?? req.params?.id ?? null,
          nouvelleValeur: body?.data ?? null,
          adresseIp:      req.ip,
          userAgent:      req.headers['user-agent'],
        }).catch(() => {});   // silencieux
      }
      return originalJson(body);
    };

    next();
  };
};

export default audit;