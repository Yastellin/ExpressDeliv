import * as LivraisonsService from './livraisons.service.js';

const getMeta = (req) => ({
  ip:        req.ip,
  userAgent: req.headers['user-agent'],
});

// ══════════════════════════════════════════════════════════
// POST /livraisons — Affecter un livreur (ADMIN+)
// ══════════════════════════════════════════════════════════
export const createLivraison = async (req, res, next) => {
  try {
    const { commande_id, livreur_id } = req.body;
    const livraison = await LivraisonsService.createLivraison(
      commande_id, livreur_id, req.user.id, getMeta(req)
    );
    res.status(201).json({
      success: true,
      message: 'Livreur affecté avec succès',
      data:    livraison,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /livraisons/mes-missions — Missions du livreur connecté
// ══════════════════════════════════════════════════════════
export const getMesMissions = async (req, res, next) => {
  try {
    const { page, limit, statut } = req.query;
    const result = await LivraisonsService.listLivraisons(
      { page: parseInt(page) || 1, limit: parseInt(limit) || 20, statut },
      req.user
    );
    res.status(200).json({
      success: true,
      data:    result.livraisons,
      pagination: {
        page: result.page, limit: result.limit,
        total: result.total, totalPages: result.totalPages,
      },
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// PATCH /livraisons/:id/accepter
// ══════════════════════════════════════════════════════════
export const accepterLivraison = async (req, res, next) => {
  try {
    const updated = await LivraisonsService.accepterLivraison(
      req.params.id, req.user.id, getMeta(req)
    );
    res.status(200).json({
      success: true,
      message: 'Mission acceptée',
      data:    updated,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// PATCH /livraisons/:id/refuser
// ══════════════════════════════════════════════════════════
export const refuserLivraison = async (req, res, next) => {
  try {
    const updated = await LivraisonsService.refuserLivraison(
      req.params.id, req.user.id, getMeta(req)
    );
    res.status(200).json({
      success: true,
      message: 'Mission refusée',
      data:    updated,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// POST /livraisons/:id/preuve
// ══════════════════════════════════════════════════════════
export const soumettrePreuve = async (req, res, next) => {
  try {
    const preuve = await LivraisonsService.soumettrePreuve(
      req.params.id, req.user.id, req.body, getMeta(req)
    );
    res.status(201).json({
      success: true,
      message: 'Preuve enregistrée — livraison clôturée',
      data:    preuve,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /livraisons — Liste paginée
// ══════════════════════════════════════════════════════════
export const listLivraisons = async (req, res, next) => {
  try {
    const { page, limit, statut, livreur_id } = req.validatedQuery;
    const result = await LivraisonsService.listLivraisons(
      { page: parseInt(page) || 1, limit: parseInt(limit) || 20, statut, livreur_id },
      req.user
    );
    res.status(200).json({
      success: true,
      data:    result.livraisons,
      pagination: {
        page: result.page, limit: result.limit,
        total: result.total, totalPages: result.totalPages,
      },
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /livraisons/:id — Détail
// ══════════════════════════════════════════════════════════
export const getLivraison = async (req, res, next) => {
  try {
    const livraison = await LivraisonsService.getLivraison(req.params.id, req.user);
    res.status(200).json({ success: true, data: livraison });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /livraisons/:id/positions — Historique GPS
// ══════════════════════════════════════════════════════════
export const getPositions = async (req, res, next) => {
  try {
    const positions = await LivraisonsService.getPositions(req.params.id, req.user);
    res.status(200).json({ success: true, data: positions });
  } catch (err) { next(err); }
};