import * as CommandesService from './commandes.service.js';
import { findById as findUserById } from '../users/users.repository.js';
import { AppError, ErrorCodes } from '../../middlewares/errorHandler.js';

// ── Helper meta ───────────────────────────────────────────
const getMeta = (req) => ({
  ip:        req.ip,
  userAgent: req.headers['user-agent'],
  role:      req.user?.role, // Ajout du rôle pour le service
});

// ══════════════════════════════════════════════════════════
// POST /commandes
// Création d'une commande – ADMIN peut spécifier client_id
// ══════════════════════════════════════════════════════════
export const createCommande = async (req, res, next) => {
  try {
    console.log('[createCommande] req.body :', req.body);
    console.log('📥[createCommande] req.user :', req.user);
    const user = req.user; // { id, role, ... }
    const { client_id, ...commandeData } = req.body;

    // 1. Déterminer le clientId
    let clientId = user.id;

    if (['ADMIN', 'SUPER_ADMIN'].includes(user.role)) {
      // ADMIN doit fournir un client_id
      if (!client_id) {
        throw new AppError(
          'Pour un admin, le champ client_id est requis',
          400,
          ErrorCodes.VALIDATION_ERROR
        );
      }
      // Vérifier que ce client existe
      const client = await findUserById(client_id);
      if (!client) {
        throw new AppError('Client introuvable', 404, ErrorCodes.NOT_FOUND);
      }
      clientId = client_id;
    } else {
      // Un client ne peut pas forcer un autre client_id
      if (client_id && client_id !== user.id) {
        throw new AppError(
          'Vous ne pouvez pas créer une commande pour un autre client',
          403,
          ErrorCodes.FORBIDDEN
        );
      }
    }

    // 2. Appeler le service avec le clientId déterminé
    const commande = await CommandesService.createCommande(
      clientId,
      req.body, // On passe tout le body (incluant client_id)
      getMeta(req)
    );

    res.status(201).json({
      success: true,
      message: 'Commande créée avec succès',
      data:    commande,
    });
  } catch (err) { 
    next(err); 
  }
};

// ... le reste des fonctions (listCommandes, getCommande, annulerCommande) restent inchangés
// ══════════════════════════════════════════════════════════
// GET /commandes
// Liste paginée — CLIENT voit ses commandes, ADMIN voit tout
// ══════════════════════════════════════════════════════════
export const listCommandes = async (req, res, next) => {
  try {
    // Utiliser req.validatedQuery s'il existe, sinon req.query (fallback)
    const query = req.validatedQuery || req.query;
    const { page, limit, statut, client_id, date_from, date_to } = query;
    const result = await CommandesService.listCommandes(
      {
        page:      parseInt(page)  || 1,
        limit:     parseInt(limit) || 20,
        statut,
        client_id,
        date_from,
        date_to,
      },
      req.user
    );
    res.status(200).json({
      success: true,
      data:    result.commandes,
      pagination: {
        page:       result.page,
        limit:      result.limit,
        total:      result.total,
        totalPages: result.totalPages,
      },
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /commandes/:id
// Détail d'une commande avec colis et livraison
// ══════════════════════════════════════════════════════════
export const getCommande = async (req, res, next) => {
  try {
    const commande = await CommandesService.getCommande(
      req.params.id,
      req.user
    );
    res.status(200).json({
      success: true,
      data:    commande,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// PATCH /commandes/:id/annuler
// Annulation d'une commande
// ══════════════════════════════════════════════════════════
export const annulerCommande = async (req, res, next) => {
  try {
    const updated = await CommandesService.annulerCommande(
      req.params.id,
      req.user,
      getMeta(req)
    );
    res.status(200).json({
      success: true,
      message: 'Commande annulée avec succès',
      data:    updated,
    });
  } catch (err) { next(err); }
};