import { AppError, ErrorCodes } from './errorHandler.js';

// ── Hiérarchie des rôles ──────────────────────────────────
// Un rôle de rang supérieur hérite des droits des rangs inférieurs
// SUPER_ADMIN > ADMIN > LIVREUR > CLIENT
const ROLE_HIERARCHY = {
  CLIENT:      1,
  LIVREUR:     2,
  ADMIN:       3,
  SUPER_ADMIN: 4,
};

// ── authorize(...roles) ───────────────────────────────────
// Génère un middleware qui accepte un ou plusieurs rôles
//
// Usage dans les routes :
//   router.get('/', authenticate, authorize('ADMIN', 'SUPER_ADMIN'), controller)
//   router.get('/', authenticate, authorize('ADMIN+'), controller)
//
// Syntaxe spéciale "ROLE+" : accepte ce rôle ET tous les rangs supérieurs
//   authorize('ADMIN+') → accepte ADMIN et SUPER_ADMIN
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(
        new AppError('Non authentifié', 401, ErrorCodes.UNAUTHORIZED)
      );
    }

    const userRank = ROLE_HIERARCHY[req.user.role] ?? 0;

    const isAllowed = roles.some((role) => {
      // Syntaxe "ROLE+" : rang >= rôle demandé
      if (role.endsWith('+')) {
        const baseRole = role.slice(0, -1);
        const baseRank = ROLE_HIERARCHY[baseRole] ?? 0;
        return userRank >= baseRank;
      }
      // Comparaison exacte
      return req.user.role === role;
    });

    if (!isAllowed) {
      return next(
        new AppError(
          'Accès refusé : droits insuffisants',
          403,
          ErrorCodes.FORBIDDEN
        )
      );
    }

    next();
  };
};

// ── Helpers prêts à l'emploi ──────────────────────────────
// Importables directement dans les fichiers de routes
const isClient       = authorize('CLIENT');
const isLivreur      = authorize('LIVREUR');
const isAdmin        = authorize('ADMIN+');    // ADMIN + SUPER_ADMIN
const isSuperAdmin   = authorize('SUPER_ADMIN');
const isAuthenticated = authorize(             // tous les rôles
  'CLIENT', 'LIVREUR', 'ADMIN', 'SUPER_ADMIN'
);

export {
  authorize,
  isClient,
  isLivreur,
  isAdmin,
  isSuperAdmin,
  isAuthenticated,
  ROLE_HIERARCHY,
};