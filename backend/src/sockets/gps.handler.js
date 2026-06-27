import { query }        from '../config/database.js';
import { createLogger } from '../config/winston.js';

const logger = createLogger('gps');

// ── Validation des coordonnées GPS ────────────────────────
const isValidCoords = (lat, lng) =>
  typeof lat === 'number' &&
  typeof lng === 'number' &&
  lat >= -90  && lat <= 90 &&
  lng >= -180 && lng <= 180;

// ── Vérification ownership livraison ─────────────────────
// S'assure que le livreur qui émet est bien celui affecté
const verifyLivraisonOwnership = async (livraisonId, livreurId) => {
  const result = await query(
    `SELECT id FROM livraisons
     WHERE id = $1
       AND livreur_id = $2
       AND statut = 'EN_COURS'`,
    [livraisonId, livreurId]
  );
  return result.rowCount > 0;
};

// ── Enregistrement position en base ──────────────────────
const persistPosition = async (livraisonId, lat, lng, precisionM) => {
  await query(
    `INSERT INTO historique_positions_gps
       (livraison_id, latitude, longitude, precision_m)
     VALUES ($1, $2, $3, $4)`,
    [livraisonId, lat, lng, precisionM ?? null]
  );
};

// ── Handler principal ─────────────────────────────────────
// Appelé depuis socket.init.js pour chaque nouvelle connexion
export const registerGpsHandlers = (io, socket) => {

  // ── gps:join — rejoindre la room d'une livraison ──────
  // Émis par : CLIENT (pour suivre) + LIVREUR (pour émettre)
  // Payload  : { livraison_id: string }
  socket.on('gps:join', async ({ livraison_id }) => {
    if (!livraison_id) return;

    const room = `livraison_${livraison_id}`;
    socket.join(room);

    logger.debug('Socket a rejoint la room GPS', {
      socketId:    socket.id,
      userId:      socket.data.userId,
      role:        socket.data.role,
      livraison_id,
    });

    socket.emit('gps:joined', { livraison_id, room });
  });

  // ── gps:update — livreur émet sa position ─────────────
  // Émis par : LIVREUR toutes les 5 secondes
  // Payload  : { livraison_id, lat, lng, precision_metres? }
  socket.on('gps:update', async (data) => {
    try {
      // 1. Seul un LIVREUR peut émettre sa position
      if (socket.data.role !== 'LIVREUR') {
        return socket.emit('gps:error', { message: 'Non autorisé' });
      }

      const { livraison_id, lat, lng, precision_metres } = data;

      // 2. Validation des coordonnées
      if (!livraison_id || !isValidCoords(lat, lng)) {
        return socket.emit('gps:error', {
          message: 'Coordonnées ou livraison_id invalides',
        });
      }

      // 3. Vérification que ce livreur est bien affecté à cette livraison
      const isOwner = await verifyLivraisonOwnership(
        livraison_id,
        socket.data.userId
      );
      if (!isOwner) {
        return socket.emit('gps:error', {
          message: 'Livraison introuvable ou non active',
        });
      }

      // 4. Persistance en base (non bloquante pour la diffusion)
      persistPosition(livraison_id, lat, lng, precision_metres)
        .catch((err) =>
          logger.error('Erreur persistance GPS', { error: err.message })
        );

      // 5. Diffusion à tous les membres de la Room sauf l'émetteur
      const room    = `livraison_${livraison_id}`;
      const payload = {
        livraison_id,
        lat,
        lng,
        precision_metres: precision_metres ?? null,
        timestamp: new Date().toISOString(),
      };

      socket.to(room).emit('gps:position', payload);

      logger.debug('Position GPS diffusée', {
        livraisonId: livraison_id,
        lat, lng,
        room,
      });

    } catch (err) {
      logger.error('Erreur handler gps:update', { error: err.message });
      socket.emit('gps:error', { message: 'Erreur serveur GPS' });
    }
  });

  // ── gps:leave — quitter la room d'une livraison ───────
  // Émis par : CLIENT ou LIVREUR à la fin du suivi
  // Payload  : { livraison_id: string }
  socket.on('gps:leave', ({ livraison_id }) => {
    if (!livraison_id) return;
    const room = `livraison_${livraison_id}`;
    socket.leave(room);
    logger.debug('Socket a quitté la room GPS', {
      socketId: socket.id,
      livraison_id,
    });
  });
};