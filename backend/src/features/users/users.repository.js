import { query } from '../../config/database.js';

// ── Champs publics réutilisables (sans password_hash) ─────
const PUBLIC_FIELDS = `
  u.id, u.nom, u.prenom, u.email, u.telephone,
  u.adresse_defaut, u.zone_geographique,
  u.statut, u.created_at, u.updated_at,
  r.nom AS role_nom
`;

// ── Trouver un utilisateur par ID ─────────────────────────
export const findById = async (id) => {
  const result = await query(
    `SELECT ${PUBLIC_FIELDS}
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     WHERE u.id = $1`,
    [id]
  );
  return result.rows[0] ?? null;
};

// ── Liste paginée avec filtres ────────────────────────────
// Supporte : ?page=1&limit=20&role=CLIENT&statut=ACTIF&search=rakoto
export const findAll = async ({ page = 1, limit = 20, role, statut, search }) => {
  const offset = (page - 1) * limit;
  const params = [];
  const conditions = [];

  // Construction dynamique des filtres
  if (role) {
    params.push(role);
    conditions.push(`r.nom = $${params.length}`);
  }
  if (statut) {
    params.push(statut);
    conditions.push(`u.statut = $${params.length}`);
  }
  if (search) {
    params.push(`%${search.toLowerCase()}%`);
    conditions.push(`(
      LOWER(u.nom)     LIKE $${params.length} OR
      LOWER(u.prenom)  LIKE $${params.length} OR
      LOWER(u.email)   LIKE $${params.length} OR
      u.telephone      LIKE $${params.length}
    )`);
  }

  const WHERE = conditions.length
    ? `WHERE ${conditions.join(' AND ')}`
    : '';

  // Requête principale
  params.push(limit, offset);
  const dataResult = await query(
    `SELECT ${PUBLIC_FIELDS}
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     ${WHERE}
     ORDER BY u.created_at DESC
     LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params
  );

  // Compte total (pour la pagination)
  const countParams = params.slice(0, -2);
  const countResult = await query(
    `SELECT COUNT(*) AS total
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     ${WHERE}`,
    countParams
  );

  return {
    users:      dataResult.rows,
    total:      parseInt(countResult.rows[0].total),
    page,
    limit,
    totalPages: Math.ceil(parseInt(countResult.rows[0].total) / limit),
  };
};

// ── Mise à jour du profil (champs dynamiques) ─────────────
export const updateProfile = async (id, fields) => {
  const allowed = ['nom', 'prenom', 'telephone', 'adresse_defaut', 'zone_geographique'];
  const updates = [];
  const params  = [];

  Object.entries(fields).forEach(([key, value]) => {
    if (allowed.includes(key) && value !== undefined) {
      params.push(value);
      updates.push(`${key} = $${params.length}`);
    }
  });

  if (!updates.length) return null;

  params.push(id);
  const result = await query(
    `UPDATE utilisateurs
     SET ${updates.join(', ')}, updated_at = NOW()
     WHERE id = $${params.length}
     RETURNING id, nom, prenom, email, telephone,
               adresse_defaut, zone_geographique, statut, updated_at`,
    params
  );
  return result.rows[0] ?? null;
};

// ── Mise à jour du statut (ADMIN+) ────────────────────────
export const updateStatut = async (id, statut) => {
  const result = await query(
    `UPDATE utilisateurs
     SET statut = $1, updated_at = NOW()
     WHERE id = $2
     RETURNING id, nom, prenom, email, statut, updated_at`,
    [statut, id]
  );
  return result.rows[0] ?? null;
};

// ── Mise à jour du rôle (SUPER_ADMIN) ────────────────────
export const updateRole = async (id, roleNom) => {
  const roleResult = await query(
    `SELECT id FROM roles WHERE nom = $1`,
    [roleNom]
  );
  if (!roleResult.rows[0]) return null;

  const result = await query(
    `UPDATE utilisateurs
     SET role_id = $1, updated_at = NOW()
     WHERE id = $2
     RETURNING id, nom, prenom, email, updated_at`,
    [roleResult.rows[0].id, id]
  );
  return result.rows[0] ?? null;
};

// ── Trouver tous les livreurs actifs (pour affectation) ───
export const findActiveLivreurs = async (zone = null) => {
  const params = [];
  let zoneFilter = '';

  if (zone) {
    params.push(zone);
    zoneFilter = `AND u.zone_geographique = $${params.length}`;
  }

  const result = await query(
    `SELECT u.id, u.nom, u.prenom, u.telephone, u.zone_geographique
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     WHERE r.nom = 'LIVREUR'
       AND u.statut = 'ACTIF'
       ${zoneFilter}
     ORDER BY u.nom ASC`,
    params
  );
  return result.rows;
};