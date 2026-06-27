import { query, getClient } from '../../config/database.js';

// ── Utilisateurs ──────────────────────────────────────────

// Recherche un utilisateur par email (avec son rôle jointuré)
export const findUserByEmail = async (email) => {
  const result = await query(
    `SELECT
       u.id, u.nom, u.prenom, u.email, u.telephone,
       u.password_hash, u.adresse_defaut, u.zone_geographique,
       u.statut, u.created_at,
       r.nom AS role_nom
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     WHERE u.email = $1`,
    [email]
  );
  return result.rows[0] ?? null;
};

// Recherche un utilisateur par ID
export const findUserById = async (id) => {
  const result = await query(
    `SELECT
       u.id, u.nom, u.prenom, u.email, u.telephone,
       u.adresse_defaut, u.zone_geographique,
       u.statut, u.created_at,
       r.nom AS role_nom
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     WHERE u.id = $1`,
    [id]
  );
  return result.rows[0] ?? null;
};

// Création d'un utilisateur (transaction ACID) — avec paramètre 'role'
export const createUser = async ({ nom, prenom, email, telephone, passwordHash, adresseDefaut, role = 'CLIENT' }) => {
  const client = await getClient();
  try {
    await client.query('BEGIN');

    // Récupère l'id du rôle passé en paramètre (au lieu de forcer 'CLIENT')
    const roleResult = await client.query(
      `SELECT id FROM roles WHERE nom = $1`,
      [role]
    );
    if (roleResult.rows.length === 0) {
      throw new Error(`Rôle "${role}" invalide`);
    }
    const roleId = roleResult.rows[0].id;

    // Insère l'utilisateur
    const userResult = await client.query(
      `INSERT INTO utilisateurs
         (nom, prenom, email, telephone, password_hash, role_id, adresse_defaut)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING
         id, nom, prenom, email, telephone,
         adresse_defaut, statut, created_at`,
      [nom, prenom, email, telephone, passwordHash, roleId, adresseDefaut ?? null]
    );
    const user = userResult.rows[0];

    await client.query('COMMIT');

    // Retourne avec le nom du rôle (le même que celui utilisé)
    return { ...user, role_nom: role };

  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// ── Refresh Tokens ────────────────────────────────────────

// Sauvegarde un refresh token en base
export const saveRefreshToken = async (utilisateurId, token, expiresAt) => {
  await query(
    `INSERT INTO refresh_tokens
       (utilisateur_id, token, expires_at)
     VALUES ($1, $2, $3)`,
    [utilisateurId, token, expiresAt]
  );
};

// Recherche un refresh token valide (non révoqué, non expiré)
export const findValidRefreshToken = async (token) => {
  const result = await query(
    `SELECT rt.*, u.id AS user_id
     FROM refresh_tokens rt
     JOIN utilisateurs u ON u.id = rt.utilisateur_id
     WHERE rt.token = $1
       AND rt.revoque = false
       AND rt.expires_at > NOW()`,
    [token]
  );
  return result.rows[0] ?? null;
};

// Révoque un refresh token (logout)
export const revokeRefreshToken = async (token) => {
  await query(
    `UPDATE refresh_tokens
     SET revoque = true
     WHERE token = $1`,
    [token]
  );
};

// Révoque tous les refresh tokens d'un utilisateur
export const revokeAllUserTokens = async (utilisateurId) => {
  await query(
    `UPDATE refresh_tokens
     SET revoque = true
     WHERE utilisateur_id = $1
       AND revoque = false`,
    [utilisateurId]
  );
};