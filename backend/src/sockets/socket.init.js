import { Server }       from 'socket.io';
import jwt             from 'jsonwebtoken';
import { createLogger } from '../config/winston.js';
import { registerGpsHandlers }  from './gps.handler.js';
import { registerChatHandlers } from './chat.handler.js';

const logger = createLogger('socket');

// ── Instance Socket.io exportée ───────────────────────────
// Permet aux services d'émettre des événements depuis n'importe où
// ex: io.to('livraison_123').emit('livraison:statut', data)
let io;
export const getIO = () => {
  if (!io) throw new Error('Socket.io non initialisé');
  return io;
};

// ── Initialisation ────────────────────────────────────────
export const initSocket = (httpServer) => {
  io = new Server(httpServer, {
    cors: {
      origin:  process.env.CORS_ORIGIN || '*',
      methods: ['GET', 'POST'],
    },
    // Ping toutes les 25s, déconnecte après 60s sans réponse
    pingInterval: 25000,
    pingTimeout:  60000,
  });

  // ── Middleware JWT Socket.io ────────────────────────────
  // Le client Flutter envoie le token dans handshake.auth :
  // socket = io(url, { auth: { token: accessToken } })
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token
                || socket.handshake.headers?.authorization?.split(' ')[1];

    if (!token) {
      logger.warn('Connexion socket refusée — token manquant', {
        socketId: socket.id,
        ip: socket.handshake.address,
      });
      return next(new Error('TOKEN_MISSING'));
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      // Injecte les données utilisateur dans le socket
      socket.data.userId = decoded.id;
      socket.data.role   = decoded.role;
      socket.data.email  = decoded.email;
      next();
    } catch (err) {
      logger.warn('Connexion socket refusée — token invalide', {
        socketId: socket.id,
        error: err.message,
      });
      next(new Error('TOKEN_INVALID'));
    }
  });

  // ── Connexion établie ───────────────────────────────────
  io.on('connection', (socket) => {
    logger.info('Nouvelle connexion socket', {
      socketId: socket.id,
      userId:   socket.data.userId,
      role:     socket.data.role,
    });

    // Branchement des handlers métier
    registerGpsHandlers(io, socket);
    registerChatHandlers(io, socket);

    // Rejoindre une room personnelle (pour cibler un user précis)
    socket.join(`user_${socket.data.userId}`);

    // Déconnexion
    socket.on('disconnect', (reason) => {
      logger.info('Déconnexion socket', {
        socketId: socket.id,
        userId:   socket.data.userId,
        reason,
      });
    });
  });

  logger.info('Socket.io initialisé');
  return io;
};