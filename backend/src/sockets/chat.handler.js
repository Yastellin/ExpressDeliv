import { query }        from '../config/database.js';
import { createLogger } from '../config/winston.js';

const logger = createLogger('chat');

// ── Vérification accès livraison ──────────────────────────
// Seuls le client propriétaire et le livreur affecté peuvent chatter
const verifyAccess = async (livraisonId, userId) => {
  console.log('🔍 [verifyAccess] livraisonId:', livraisonId, 'userId:', userId);
  try {
    const result = await query(
      `SELECT l.id
       FROM livraisons l
       JOIN commandes c ON c.id = l.commande_id
       WHERE l.id = $1
         AND l.statut = 'EN_COURS'
         AND (l.livreur_id = $2 OR c.client_id = $2)`,
      [livraisonId, userId]
    );
    console.log('🔍 [verifyAccess] rowCount:', result.rowCount);
    return result.rowCount > 0;
  } catch (err) {
    console.error('[verifyAccess] Erreur SQL:', err);
    throw err;
  }
};

// ── Persistance du message ────────────────────────────────
const persistMessage = async (livraisonId, expediteurId, contenu) => {
  const result = await query(
    `INSERT INTO discussions_chat
       (livraison_id, expediteur_id, contenu)
     VALUES ($1, $2, $3)
     RETURNING id, envoye_at`,
    [livraisonId, expediteurId, contenu]
  );
  return result.rows[0];
};

// ── Chargement de l'historique ────────────────────────────
const loadHistory = async (livraisonId) => {
  const result = await query(
    `SELECT
       dc.id,
       dc.contenu,
       dc.lu,
       dc.envoye_at,
       u.id   AS expediteur_id,
       u.nom  AS expediteur_nom,
       u.prenom AS expediteur_prenom
     FROM discussions_chat dc
     JOIN utilisateurs u ON u.id = dc.expediteur_id
     WHERE dc.livraison_id = $1
     ORDER BY dc.envoye_at ASC
     LIMIT 100`,
    [livraisonId]
  );
  return result.rows;
};

// ── Marquer les messages comme lus ───────────────────────
const markAsRead = async (livraisonId, userId) => {
  await query(
    `UPDATE discussions_chat
     SET lu = true
     WHERE livraison_id = $1
       AND expediteur_id != $2
       AND lu = false`,
    [livraisonId, userId]
  );
};

// ── Handler principal ─────────────────────────────────────
export const registerChatHandlers = (io, socket) => {

  // ── chat:join — rejoindre le chat d'une livraison ─────
  // Payload : { livraison_id: string }
  // Retourne l'historique des 100 derniers messages
socket.on('chat:join', async ({ livraison_id }) => {
  try {
    if (!livraison_id) return;

    console.log('📩 [chat:join] livraison_id:', livraison_id, 'userId:', socket.data.userId);

    // Vérification accès
    const hasAccess = await verifyAccess(livraison_id, socket.data.userId);
    console.log('🔍 [chat:join] hasAccess:', hasAccess);

    if (!hasAccess) {
      return socket.emit('chat:error', {
        message: 'Accès refusé à ce chat',
      });
    }

    // Rejoindre la room chat (partagée avec la room GPS)
    const room = `livraison_${livraison_id}`;
    socket.join(room);

    // Charger et envoyer l'historique uniquement à ce socket
    const history = await loadHistory(livraison_id);
    socket.emit('chat:history', { livraison_id, messages: history });

    // Marquer les messages reçus comme lus
    await markAsRead(livraison_id, socket.data.userId);

    logger.debug('Chat rejoint', {
      userId: socket.data.userId,
      livraison_id,
    });

  } catch (err) {
    console.error('[chat:join] Erreur:', err);
    logger.error('Erreur chat:join', { error: err.message });
    socket.emit('chat:error', { message: 'Erreur serveur' });
  }
});

  // ── chat:message — envoyer un message ─────────────────
  socket.on('chat:message', async ({ livraison_id, contenu }) => {
    try {
      // Validations
      if (!livraison_id || !contenu?.trim()) {
        return socket.emit('chat:error', {
          message: 'livraison_id et contenu sont requis',
        });
      }
      if (contenu.length > 500) {
        return socket.emit('chat:error', {
          message: 'Message trop long (500 caractères max)',
        });
      }

      // Vérification accès
      const hasAccess = await verifyAccess(livraison_id, socket.data.userId);
      if (!hasAccess) {
        return socket.emit('chat:error', {
          message: 'Accès refusé',
        });
      }

      // Persistance
      const saved = await persistMessage(
        livraison_id,
        socket.data.userId,
        contenu.trim()
      );

      // ✅ Récupérer le nom et prénom de l'expéditeur
      const userResult = await query(
        `SELECT nom, prenom FROM utilisateurs WHERE id = $1`,
        [socket.data.userId]
      );
      const expediteur = userResult.rows[0] || { nom: '', prenom: '' };

      // Payload complet (incluant nom et prénom)
      const payload = {
        id:              saved.id,
        livraison_id,
        contenu:         contenu.trim(),
        expediteur_id:   socket.data.userId,
        expediteur_nom:  expediteur.nom,
        expediteur_prenom: expediteur.prenom,
        envoye_at:       saved.envoye_at,
      };

      // Diffusion à toute la room (émetteur inclus)
      const room = `livraison_${livraison_id}`;
      io.to(room).emit('chat:message', payload);

      logger.debug('Message chat envoyé', {
        livraisonId: livraison_id,
        expediteurId: socket.data.userId,
      });

    } catch (err) {
      logger.error('Erreur chat:message', { error: err.message });
      socket.emit('chat:error', { message: 'Erreur envoi message' });
    }
  });

  // ── chat:read — marquer les messages comme lus ────────
  // Payload : { livraison_id: string }
  socket.on('chat:read', async ({ livraison_id }) => {
    if (!livraison_id) return;
    try {
      await markAsRead(livraison_id, socket.data.userId);
      // Notifie l'autre partie que ses messages ont été lus
      socket.to(`livraison_${livraison_id}`).emit('chat:read_ack', {
        livraison_id,
        lu_par: socket.data.userId,
      });
    } catch (err) {
      logger.error('Erreur chat:read', { error: err.message });
    }
  });
};