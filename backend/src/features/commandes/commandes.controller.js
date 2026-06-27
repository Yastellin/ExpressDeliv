import * as CommandesService from './commandes.service.js';

// ── Helper meta ───────────────────────────────────────────
const getMeta = (req) => ({
  ip:        req.ip,
  userAgent: req.headers['user-agent'],
});

// ══════════════════════════════════════════════════════════
// POST /commandes
// Création d'une nouvelle commande (CLIENT)
// ══════════════════════════════════════════════════════════
export const createCommande = async (req, res, next) => {
  try {
    const commande = await CommandesService.createCommande(
      req.user.id,
      req.body,
      getMeta(req)
    );
    res.status(201).json({
      success: true,
      message: 'Commande créée avec succès',
      data:    commande,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /commandes
// Liste paginée — CLIENT voit ses commandes, ADMIN voit tout
// ══════════════════════════════════════════════════════════
export const listCommandes = async (req, res, next) => {
  try {
    // ✅ Lecture depuis req.validatedQuery (si présent)
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