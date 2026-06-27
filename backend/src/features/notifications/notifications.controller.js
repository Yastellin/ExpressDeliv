import { query }        from '../../config/database.js';
import { createLogger } from '../../config/winston.js';
import { AppError, ErrorCodes } from '../../middlewares/errorHandler.js';

const logger = createLogger('notificationsController');

// ══════════════════════════════════════════════════════════
// POST /notifications/token
// Enregistre ou met à jour le token FCM de l'appareil
// ══════════════════════════════════════════════════════════
export const registerToken = async (req, res, next) => {
  try {
    const { token_fcm, plateforme } = req.body;

    // Upsert : insert ou mise à jour si le token existe déjà
    await query(
      `INSERT INTO jetons_appareils
         (utilisateur_id, token_fcm, plateforme, dernier_usage)
       VALUES ($1, $2, $3, NOW())
       ON CONFLICT (utilisateur_id, token_fcm)
       DO UPDATE SET
         plateforme    = EXCLUDED.plateforme,
         actif         = true,
         dernier_usage = NOW()`,
      [req.user.id, token_fcm, plateforme]
    );

    logger.debug('Token FCM enregistré', {
      userId:     req.user.id,
      plateforme,
    });

    res.status(200).json({
      success: true,
      message: 'Token FCM enregistré avec succès',
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════
// DELETE /notifications/token
// Désactive le token FCM à la déconnexion
// ══════════════════════════════════════════════════════════
export const unregisterToken = async (req, res, next) => {
  try {
    const { token_fcm } = req.body;

    if (!token_fcm) {
      throw new AppError(
        'token_fcm est requis',
        400,
        ErrorCodes.VALIDATION_ERROR
      );
    }

    await query(
      `UPDATE jetons_appareils
       SET actif = false
       WHERE utilisateur_id = $1
         AND token_fcm = $2`,
      [req.user.id, token_fcm]
    );

    logger.debug('Token FCM désactivé', { userId: req.user.id });

    res.status(200).json({
      success: true,
      message: 'Token FCM désactivé',
    });
  } catch (err) { next(err); }
};