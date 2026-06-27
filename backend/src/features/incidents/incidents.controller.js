import * as IncidentsService from './incidents.service.js';

const getMeta = (req) => ({
  ip:        req.ip,
  userAgent: req.headers['user-agent'],
});

// ══════════════════════════════════════════════════════════
// POST /incidents — Déclarer un incident (LIVREUR)
// ══════════════════════════════════════════════════════════
export const createIncident = async (req, res, next) => {
  try {
    const incident = await IncidentsService.createIncident(
      req.user.id,
      req.body,
      getMeta(req)
    );
    res.status(201).json({
      success: true,
      message: 'Incident déclaré avec succès',
      data:    incident,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /incidents — Liste paginée
// ══════════════════════════════════════════════════════════
export const listIncidents = async (req, res, next) => {
  try {
    const { page, limit, type, resolu } = req.query;
    const result = await IncidentsService.listIncidents(
      {
        page:   parseInt(page)  || 1,
        limit:  parseInt(limit) || 20,
        type,
        resolu: resolu !== undefined ? resolu === 'true' : undefined,
      },
      req.user
    );
    res.status(200).json({
      success: true,
      data:    result.incidents,
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
// PATCH /incidents/:id/resoudre — Résolution (ADMIN+)
// ══════════════════════════════════════════════════════════
export const resoudreIncident = async (req, res, next) => {
  try {
    const updated = await IncidentsService.resoudreIncident(
      req.params.id,
      req.user.id,
      getMeta(req)
    );
    res.status(200).json({
      success: true,
      message: 'Incident résolu',
      data:    updated,
    });
  } catch (err) { next(err); }
};