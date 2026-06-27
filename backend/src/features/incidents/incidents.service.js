import * as IncidentsRepository  from './incidents.repository.js';
import * as LivraisonsRepository from '../livraisons/livraisons.repository.js';
import { AppError, ErrorCodes }        from '../../middlewares/errorHandler.js';
import { createAuditLog, AuditActions } from '../../middlewares/auditLogger.js';
import { FCMService }                   from '../../config/firebase.js';
import { createLogger }                 from '../../config/winston.js';
import { query }                        from '../../config/database.js';

const logger = createLogger('incidentsService');

const getFCMTokens = async (userId) => {
  const result = await query(
    `SELECT token_fcm FROM jetons_appareils
     WHERE utilisateur_id = $1 AND actif = true`,
    [userId]
  );
  return result.rows.map((r) => r.token_fcm);
};

// ══════════════════════════════════════════════════════════
// createIncident() — Déclaration d'un incident (LIVREUR)
// ══════════════════════════════════════════════════════════
export const createIncident = async (livreurId, incidentData, meta = {}) => {
  const { livraison_id, type, description } = incidentData;

  // 1. Vérifier que la livraison existe et appartient au livreur
  const livraison = await LivraisonsRepository.findById(livraison_id);
  if (!livraison) {
    throw new AppError('Livraison introuvable', 404, ErrorCodes.NOT_FOUND);
  }
  if (livraison.livreur_id !== livreurId) {
    throw new AppError('Cette livraison ne vous est pas affectée', 403, ErrorCodes.FORBIDDEN);
  }
  if (livraison.statut !== 'EN_COURS') {
    throw new AppError(
      'Un incident ne peut être déclaré que sur une livraison EN_COURS',
      400, ErrorCodes.INVALID_STATUS
    );
  }
  // Bloque si déjà 3 tentatives (contrainte DB CHECK aussi en place)
  if (livraison.tentatives >= 3) {
    throw new AppError(
      'Nombre maximum de tentatives atteint pour cette livraison',
      400, ErrorCodes.INVALID_STATUS
    );
  }

  // 2. Créer l'incident (transaction ACID — incrémente tentatives)
  const incident = await IncidentsRepository.createIncident(livraison_id, type, description);

  // 3. Marquer la livraison comme ECHOUEE → commande EN_ATTENTE (réaffectation)
  await LivraisonsRepository.updateStatut(livraison_id, 'ECHOUEE');

  // 4. Audit
  await createAuditLog({
    utilisateurId:  livreurId,
    action:         AuditActions.INCIDENT_DECLARED,
    tableCible:     'echecs_livraison',
    entiteId:       incident.id,
    nouvelleValeur: { type, livraison_id },
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  // 5. Notification FCM au client
  const clientTokens = await getFCMTokens(livraison.client_id);
  if (clientTokens.length) {
    const messages = {
      CLIENT_ABSENT:        "Le livreur n'a pas pu vous joindre.",
      ADRESSE_INTROUVABLE:  "L'adresse de livraison n'a pas pu être localisée.",
      PANNE_VEHICULE:       'Le livreur a rencontré un problème technique.',
      ACCIDENT:             'Un incident est survenu durant la livraison.',
      AUTRE:                'Un problème est survenu durant la livraison.',
    };
    FCMService.sendMultiple(
      clientTokens,
      'Problème de livraison ⚠️',
      messages[type] || messages.AUTRE,
      { livraison_id, type: 'INCIDENT_DECLARED' }
    ).catch(() => {});
  }

  logger.info('Incident déclaré', { incidentId: incident.id, livraisonId: livraison_id, type });
  return incident;
};

// ══════════════════════════════════════════════════════════
// listIncidents() — Liste selon le rôle
// ══════════════════════════════════════════════════════════
export const listIncidents = async (filters, requestingUser) => {
  if (requestingUser.role === 'LIVREUR') {
    filters.livreurId = requestingUser.id;
  }
  return await IncidentsRepository.findAll(filters);
};

// ══════════════════════════════════════════════════════════
// resoudreIncident() — Résolution (ADMIN+)
// ══════════════════════════════════════════════════════════
export const resoudreIncident = async (id, adminId, meta = {}) => {
  const incident = await IncidentsRepository.findById(id);
  if (!incident) {
    throw new AppError('Incident introuvable', 404, ErrorCodes.NOT_FOUND);
  }
  if (incident.resolu) {
    throw new AppError('Cet incident est déjà résolu', 400, ErrorCodes.VALIDATION_ERROR);
  }

  const updated = await IncidentsRepository.resoudreIncident(id, adminId);

  await createAuditLog({
    utilisateurId:  adminId,
    action:         AuditActions.INCIDENT_RESOLVED,
    tableCible:     'echecs_livraison',
    entiteId:       id,
    nouvelleValeur: { resolu: true },
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  logger.info('Incident résolu', { incidentId: id, adminId });
  return updated;
};