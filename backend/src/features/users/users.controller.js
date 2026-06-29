import * as UsersService from './users.service.js';
import { toUserDTO } from '../auth/auth.dto.js';

// ── Helper meta ───────────────────────────────────────────
const getMeta = (req) => ({
  ip:        req.ip,
  userAgent: req.headers['user-agent'],
});

// ══════════════════════════════════════════════════════════
// GET /users/me — Profil de l'utilisateur connecté
// ══════════════════════════════════════════════════════════
export const getMyProfile = async (req, res, next) => {
  try {
    const user = await UsersService.getProfile(req.user.id);
    res.status(200).json({
      success: true,
      data:    toUserDTO(user),
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// PUT /users/me — Mise à jour du profil
// ══════════════════════════════════════════════════════════
export const updateMyProfile = async (req, res, next) => {
  try {
    const updated = await UsersService.updateProfile(
      req.user.id,
      req.body,
      getMeta(req)
    );
    res.status(200).json({
      success: true,
      message: 'Profil mis à jour avec succès',
      data:    toUserDTO({ ...updated, role_nom: req.user.role }),
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// POST /users — Création d'un utilisateur (ADMIN+)
// ══════════════════════════════════════════════════════════
export const createUser = async (req, res, next) => {
  try {
    const user = await UsersService.createUser(req.body, req.user.id, getMeta(req));
    res.status(201).json({
      success: true,
      message: 'Utilisateur créé avec succès',
      data:    toUserDTO(user),
    });
  } catch (err) { next(err); }
};

export const listUsers = async (req, res, next) => {
  try {
    const { page, limit, role, statut, search } = req.validatedQuery;
    const result = await UsersService.listUsers({
      page:   parseInt(page)  || 1,
      limit:  parseInt(limit) || 20,
      role,
      statut,
      search,
    });

    res.status(200).json({
      success: true,
      data:    result.users.map(toUserDTO),
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
// GET /users/:id — Détail d'un utilisateur (ADMIN+)
// ══════════════════════════════════════════════════════════
export const getUserById = async (req, res, next) => {
  try {
    const user = await UsersService.getUserById(req.params.id);
    res.status(200).json({
      success: true,
      data:    toUserDTO(user),
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// PATCH /users/:id/statut — Changer le statut (ADMIN+)
// ══════════════════════════════════════════════════════════
export const updateStatut = async (req, res, next) => {
  try {
    const updated = await UsersService.updateStatut(
      req.params.id,
      req.body.statut,
      req.user.id,
      getMeta(req)
    );
    res.status(200).json({
      success: true,
      message: `Statut mis à jour : ${req.body.statut}`,
      data:    updated,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// PATCH /users/:id/role — Changer le rôle (SUPER_ADMIN)
// ══════════════════════════════════════════════════════════
export const updateRole = async (req, res, next) => {
  try {
    const updated = await UsersService.updateRole(
      req.params.id,
      req.body.role,
      req.user.id,
      getMeta(req)
    );
    res.status(200).json({
      success: true,
      message: `Rôle mis à jour : ${req.body.role}`,
      data:    updated,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// GET /users/livreurs — Liste des livreurs actifs (ADMIN+)
// ══════════════════════════════════════════════════════════
export const getActiveLivreurs = async (req, res, next) => {
  try {
    const { zone } = req.query;
    const livreurs = await UsersService.getActiveLivreurs(zone || null);
    res.status(200).json({
      success: true,
      data:    livreurs,
    });
  } catch (err) { next(err); }
};