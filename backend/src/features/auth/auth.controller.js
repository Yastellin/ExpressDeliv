import * as AuthService from './auth.service.js';
import { toAuthResponseDTO, toRefreshResponseDTO } from './auth.dto.js';
import { AppError, ErrorCodes } from '../../middlewares/errorHandler.js';

// ── Helper : extrait IP + User-Agent pour l'audit ─────────
const getMeta = (req) => ({
  ip:        req.ip,
  userAgent: req.headers['user-agent'],
});

// ══════════════════════════════════════════════════════════
// POST /auth/register
// ══════════════════════════════════════════════════════════
export const registerController = async (req, res, next) => {
  try {
    const { user, accessToken, refreshToken } =
      await AuthService.register(req.body, getMeta(req));

    res.status(201).json({
      success: true,
      message: 'Inscription réussie',
      data:    toAuthResponseDTO(user, accessToken, refreshToken),
    });
  } catch (err) {
    next(err);
  }
};

// ══════════════════════════════════════════════════════════
// POST /auth/login
// ══════════════════════════════════════════════════════════
export const loginController = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const { user, accessToken, refreshToken } =
      await AuthService.login(email, password, getMeta(req));

    res.status(200).json({
      success: true,
      message: 'Connexion réussie',
      data:    toAuthResponseDTO(user, accessToken, refreshToken),
    });
  } catch (err) {
    next(err);
  }
};

// ══════════════════════════════════════════════════════════
// POST /auth/refresh
// ══════════════════════════════════════════════════════════
export const refreshController = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    const { accessToken } = await AuthService.refresh(refreshToken);

    res.status(200).json({
      success: true,
      message: 'Token renouvelé',
      data:    toRefreshResponseDTO(accessToken),
    });
  } catch (err) {
    next(err);
  }
};

// ══════════════════════════════════════════════════════════
// POST /auth/logout
// ══════════════════════════════════════════════════════════
export const logoutController = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      throw new AppError(
        'Refresh token requis',
        400,
        ErrorCodes.VALIDATION_ERROR
      );
    }

    await AuthService.logout(refreshToken, req.user.id, getMeta(req));

    res.status(200).json({
      success: true,
      message: 'Déconnexion réussie',
    });
  } catch (err) {
    next(err);
  }
};

// ══════════════════════════════════════════════════════════
// GET /auth/me
// Retourne le profil de l'utilisateur connecté
// ══════════════════════════════════════════════════════════
export const meController = async (req, res, next) => {
  try {
    // req.user est injecté par authenticate middleware
    // On recharge depuis la DB pour avoir les données à jour
    const { findUserById } = await import('./auth.repository.js');
    const { toUserDTO }    = await import('./auth.dto.js');

    const user = await findUserById(req.user.id);
    if (!user) {
      throw new AppError('Utilisateur introuvable', 404, ErrorCodes.NOT_FOUND);
    }

    res.status(200).json({
      success: true,
      data:    toUserDTO(user),
    });
  } catch (err) {
    next(err);
  }
};