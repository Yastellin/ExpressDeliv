import * as CommandesRepository from './commandes.repository.js';
import { AppError, ErrorCodes }        from '../../middlewares/errorHandler.js';
import { createAuditLog, AuditActions } from '../../middlewares/auditLogger.js';
import { FCMService }                   from '../../config/firebase.js';
import { createLogger }                 from '../../config/winston.js';
import { query }                        from '../../config/database.js';

const logger = createLogger('commandesService');

// ── Helper : récupère les tokens FCM d'un utilisateur ─────
const getUserFCMTokens = async (userId) => {
  const result = await query(
    `SELECT token_fcm FROM jetons_appareils
     WHERE utilisateur_id = $1 AND actif = true`,
    [userId]
  );
  return result.rows.map((r) => r.token_fcm);
};

// ══════════════════════════════════════════════════════════
// createCommande() — Création d'une nouvelle commande
// ══════════════════════════════════════════════════════════
export const createCommande = async (clientId, commandeData, meta = {}) => {
  // 1. Créer la commande + colis en base (transaction ACID)
  
  const commande = await CommandesRepository.createCommande(clientId, commandeData);

  // 2. Audit
  await createAuditLog({
    utilisateurId:  clientId,
    action:         AuditActions.COMMANDE_CREATED,
    tableCible:     'commandes',
    entiteId:       commande.id,
    nouvelleValeur: {
      adresse_livraison: commande.adresse_livraison,
      montant_total:     commande.montant_total,
      nb_colis:          commande.colis.length,
    },
    adresseIp:  meta.ip,
    userAgent:  meta.userAgent,
  });

  // 3. Notification FCM au client (confirmation commande)
  const tokens = await getUserFCMTokens(clientId);
  if (tokens.length) {
    FCMService.sendMultiple(
      tokens,
      'Commande confirmée ✓',
      `Votre commande de ${commande.colis.length} colis a été enregistrée.`,
      { commande_id: commande.id, type: 'COMMANDE_CREATED' }
    ).catch(() => {});   // non bloquant
  }

  logger.info('Commande créée', {
    commandeId: commande.id,
    clientId,
    montant:    commande.montant_total,
    nbColis:    commande.colis.length,
  });

  return commande;
};

// ══════════════════════════════════════════════════════════
// getCommande() — Détail d'une commande
// ══════════════════════════════════════════════════════════
export const getCommande = async (id, requestingUser) => {
  const commande = await CommandesRepository.findById(id);

  if (!commande) {
    throw new AppError(
      'Commande introuvable',
      404,
      ErrorCodes.NOT_FOUND
    );
  }

  // Un CLIENT ne peut voir que ses propres commandes
  if (
    requestingUser.role === 'CLIENT' &&
    commande.client_id !== requestingUser.id
  ) {
    throw new AppError(
      'Accès refusé à cette commande',
      403,
      ErrorCodes.FORBIDDEN
    );
  }

  return commande;
};

// ══════════════════════════════════════════════════════════
// listCommandes() — Liste paginée selon le rôle
// ══════════════════════════════════════════════════════════
export const listCommandes = async (filters, requestingUser) => {
  // CLIENT voit uniquement ses commandes
  if (requestingUser.role === 'CLIENT') {
    filters.clientId = requestingUser.id;
  }
  // ADMIN peut filtrer par client_id s'il le souhaite
  else if (filters.client_id) {
    filters.clientId = filters.client_id;
  }

  return await CommandesRepository.findAll(filters);
};

// ══════════════════════════════════════════════════════════
// annulerCommande() — Annulation (CLIENT ou ADMIN)
// ══════════════════════════════════════════════════════════
export const annulerCommande = async (id, requestingUser, meta = {}) => {
  const commande = await CommandesRepository.findById(id);

  if (!commande) {
    throw new AppError(
      'Commande introuvable',
      404,
      ErrorCodes.NOT_FOUND
    );
  }

  // CLIENT ne peut annuler que ses propres commandes
  if (
    requestingUser.role === 'CLIENT' &&
    commande.client_id !== requestingUser.id
  ) {
    throw new AppError(
      'Accès refusé',
      403,
      ErrorCodes.FORBIDDEN
    );
  }

  // Annulation impossible si déjà EN_COURS, LIVREE ou ANNULEE
  const annulables = ['EN_ATTENTE', 'CONFIRMEE'];
  if (!annulables.includes(commande.statut)) {
    throw new AppError(
      `Impossible d'annuler une commande en statut ${commande.statut}`,
      400,
      ErrorCodes.INVALID_STATUS
    );
  }

  const updated = await CommandesRepository.updateStatut(id, 'ANNULEE');

  // Audit
  await createAuditLog({
    utilisateurId:  requestingUser.id,
    action:         AuditActions.COMMANDE_CANCELLED,
    tableCible:     'commandes',
    entiteId:       id,
    ancienneValeur: { statut: commande.statut },
    nouvelleValeur: { statut: 'ANNULEE' },
    adresseIp:      meta.ip,
    userAgent:      meta.userAgent,
  });

  // Notification FCM au client
  const tokens = await getUserFCMTokens(commande.client_id);
  if (tokens.length) {
    FCMService.sendMultiple(
      tokens,
      'Commande annulée',
      'Votre commande a été annulée avec succès.',
      { commande_id: id, type: 'COMMANDE_CANCELLED' }
    ).catch(() => {});
  }

  logger.info('Commande annulée', { commandeId: id, by: requestingUser.id });
  return updated;
};