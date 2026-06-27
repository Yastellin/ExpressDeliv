import * as LivraisonsRepository from './livraisons.repository.js';
import * as CommandesRepository  from '../commandes/commandes.repository.js';
import { AppError, ErrorCodes }        from '../../middlewares/errorHandler.js';
import { createAuditLog, AuditActions } from '../../middlewares/auditLogger.js';
import { FCMService }                   from '../../config/firebase.js';
import { getIO }                        from '../../sockets/socket.init.js';
import { createLogger }                 from '../../config/winston.js';
import { query }                        from '../../config/database.js';

const logger = createLogger('livraisonsService');

// ── Helper : tokens FCM d'un utilisateur ──────────────────
const getFCMTokens = async (userId) => {
  const result = await query(
    `SELECT token_fcm FROM jetons_appareils
     WHERE utilisateur_id = $1 AND actif = true`,
    [userId]
  );
  return result.rows.map((r) => r.token_fcm);
};

// ── Helper : émet un événement Socket.io sur la room ──────
const emitToRoom = (livraisonId, event, data) => {
  try {
    getIO().to(`livraison_${livraisonId}`).emit(event, data);
  } catch {
    // Socket.io non initialisé en mode test — silencieux
  }
};

// ══════════════════════════════════════════════════════════
// createLivraison() — Affectation d'un livreur (ADMIN+)
// ══════════════════════════════════════════════════════════
export const createLivraison = async (commandeId, livreurId, adminId, meta = {}) => {
  // 1. Vérifier que la commande existe et est en attente
  const commande = await CommandesRepository.findById(commandeId);
  if (!commande) {
    throw new AppError('Commande introuvable', 404, ErrorCodes.NOT_FOUND);
  }
  if (!['EN_ATTENTE', 'CONFIRMEE'].includes(commande.statut)) {
    throw new AppError(
      `Impossible d'affecter une commande en statut ${commande.statut}`,
      400, ErrorCodes.INVALID_STATUS
    );
  }

  // 2. Créer la livraison (transaction ACID)
  const livraison = await LivraisonsRepository.createLivraison(commandeId, livreurId);

  // 3. Audit
  await createAuditLog({
    utilisateurId:  adminId,
    action:         AuditActions.LIVRAISON_CREATED,
    tableCible:     'livraisons',
    entiteId:       livraison.id,
    nouvelleValeur: { commandeId, livreurId },
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  // 4. Notification FCM au livreur
  const livreurTokens = await getFCMTokens(livreurId);
  if (livreurTokens.length) {
    FCMService.sendMultiple(
      livreurTokens,
      'Nouvelle mission 🚴',
      `Une livraison vous a été affectée : ${commande.adresse_livraison}`,
      { livraison_id: livraison.id, type: 'LIVRAISON_AFFECTEE' }
    ).catch(() => {});
  }

  logger.info('Livraison créée', { livraisonId: livraison.id, livreurId, commandeId });
  return livraison;
};

// ══════════════════════════════════════════════════════════
// accepterLivraison() — Livreur accepte la mission
// ══════════════════════════════════════════════════════════
export const accepterLivraison = async (id, livreurId, meta = {}) => {
  const livraison = await LivraisonsRepository.findById(id);

  if (!livraison) {
    throw new AppError('Livraison introuvable', 404, ErrorCodes.NOT_FOUND);
  }
  if (livraison.livreur_id !== livreurId) {
    throw new AppError('Cette livraison ne vous est pas affectée', 403, ErrorCodes.FORBIDDEN);
  }
  if (livraison.statut !== 'AFFECTEE') {
    throw new AppError(
      `Impossible d'accepter une livraison en statut ${livraison.statut}`,
      400, ErrorCodes.INVALID_STATUS
    );
  }

  const updated = await LivraisonsRepository.updateStatut(id, 'EN_COURS');

  // Socket.io : notifier la room
  emitToRoom(id, 'livraison:statut', { livraison_id: id, statut: 'EN_COURS' });

  // FCM au client
  const clientTokens = await getFCMTokens(livraison.client_id);
  if (clientTokens.length) {
    FCMService.sendMultiple(
      clientTokens,
      'Livraison en cours 🚴',
      `${livraison.livreur_prenom} est en route pour votre livraison.`,
      { livraison_id: id, type: 'LIVRAISON_EN_COURS' }
    ).catch(() => {});
  }

  await createAuditLog({
    utilisateurId: livreurId, action: AuditActions.LIVRAISON_ACCEPTED,
    tableCible: 'livraisons', entiteId: id,
    nouvelleValeur: { statut: 'EN_COURS' },
    adresseIp: meta.ip, userAgent: meta.userAgent,
  });

  logger.info('Livraison acceptée', { livraisonId: id, livreurId });
  return updated;
};

// ══════════════════════════════════════════════════════════
// refuserLivraison() — Livreur refuse la mission
// ══════════════════════════════════════════════════════════
export const refuserLivraison = async (id, livreurId, meta = {}) => {
  const livraison = await LivraisonsRepository.findById(id);

  if (!livraison) {
    throw new AppError('Livraison introuvable', 404, ErrorCodes.NOT_FOUND);
  }
  if (livraison.livreur_id !== livreurId) {
    throw new AppError('Cette livraison ne vous est pas affectée', 403, ErrorCodes.FORBIDDEN);
  }
  if (livraison.statut !== 'AFFECTEE') {
    throw new AppError(
      `Impossible de refuser une livraison en statut ${livraison.statut}`,
      400, ErrorCodes.INVALID_STATUS
    );
  }

  const updated = await LivraisonsRepository.updateStatut(id, 'ECHOUEE');

  await createAuditLog({
    utilisateurId: livreurId, action: AuditActions.LIVRAISON_REFUSED,
    tableCible: 'livraisons', entiteId: id,
    nouvelleValeur: { statut: 'ECHOUEE' },
    adresseIp: meta.ip, userAgent: meta.userAgent,
  });

  logger.info('Livraison refusée', { livraisonId: id, livreurId });
  return updated;
};

// ══════════════════════════════════════════════════════════
// soumettrePreuve() — Preuve de livraison (LIVREUR)
// ══════════════════════════════════════════════════════════
export const soumettrePreuve = async (id, livreurId, preuveData, meta = {}) => {
  const livraison = await LivraisonsRepository.findById(id);

  if (!livraison) {
    throw new AppError('Livraison introuvable', 404, ErrorCodes.NOT_FOUND);
  }
  if (livraison.livreur_id !== livreurId) {
    throw new AppError('Cette livraison ne vous est pas affectée', 403, ErrorCodes.FORBIDDEN);
  }
  if (livraison.statut !== 'EN_COURS') {
    throw new AppError(
      'La livraison doit être EN_COURS pour soumettre une preuve',
      400, ErrorCodes.INVALID_STATUS
    );
  }

  const preuve = await LivraisonsRepository.savePreuve(
    id,
    preuveData.type,
    preuveData.donnee_preuve
  );

  // Socket.io : fermer la room
  emitToRoom(id, 'livraison:terminee', { livraison_id: id, statut: 'LIVREE' });

  // FCM au client
  const clientTokens = await getFCMTokens(livraison.client_id);
  if (clientTokens.length) {
    FCMService.sendMultiple(
      clientTokens,
      'Colis livré ✅',
      'Votre colis a été livré avec succès !',
      { livraison_id: id, type: 'LIVRAISON_TERMINEE' }
    ).catch(() => {});
  }

  await createAuditLog({
    utilisateurId: livreurId, action: AuditActions.PREUVE_SUBMITTED,
    tableCible: 'preuves_livraison', entiteId: id,
    nouvelleValeur: { type: preuveData.type },
    adresseIp: meta.ip, userAgent: meta.userAgent,
  });

  logger.info('Preuve soumise — livraison clôturée', { livraisonId: id, livreurId });
  return preuve;
};

// ══════════════════════════════════════════════════════════
// getLivraison() — Détail avec contrôle d'accès
// ══════════════════════════════════════════════════════════
export const getLivraison = async (id, requestingUser) => {
  const livraison = await LivraisonsRepository.findById(id);
  if (!livraison) {
    throw new AppError('Livraison introuvable', 404, ErrorCodes.NOT_FOUND);
  }

  // CLIENT ne voit que ses livraisons
  if (requestingUser.role === 'CLIENT' && livraison.client_id !== requestingUser.id) {
    throw new AppError('Accès refusé', 403, ErrorCodes.FORBIDDEN);
  }
  // LIVREUR ne voit que ses missions
  if (requestingUser.role === 'LIVREUR' && livraison.livreur_id !== requestingUser.id) {
    throw new AppError('Accès refusé', 403, ErrorCodes.FORBIDDEN);
  }

  return livraison;
};

// ══════════════════════════════════════════════════════════
// listLivraisons() — Liste selon le rôle
// ══════════════════════════════════════════════════════════
export const listLivraisons = async (filters, requestingUser) => {
  if (requestingUser.role === 'LIVREUR') {
    filters.livreurId = requestingUser.id;
  }
  return await LivraisonsRepository.findAll(filters);
};

// ══════════════════════════════════════════════════════════
// getPositions() — Historique GPS
// ══════════════════════════════════════════════════════════
export const getPositions = async (id, requestingUser) => {
  const livraison = await LivraisonsRepository.findById(id);
  if (!livraison) {
    throw new AppError('Livraison introuvable', 404, ErrorCodes.NOT_FOUND);
  }
  if (
    requestingUser.role === 'CLIENT' &&
    livraison.client_id !== requestingUser.id
  ) {
    throw new AppError('Accès refusé', 403, ErrorCodes.FORBIDDEN);
  }
  return await LivraisonsRepository.getPositions(id);
};