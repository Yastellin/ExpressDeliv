import { query, getClient } from '../../config/database.js';

// ══════════════════════════════════════════════════════════
// createIncident() — Déclaration d'un incident (transaction ACID)
// ══════════════════════════════════════════════════════════
export const createIncident = async (livraisonId, type, description) => {
  const client = await getClient();
  try {
    await client.query('BEGIN');

    // 1. Insérer l'incident
    const incidentResult = await client.query(
      `INSERT INTO echecs_livraison
         (livraison_id, type, description)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [livraisonId, type, description]
    );

    // 2. Incrémenter le compteur de tentatives sur la livraison
    await client.query(
      `UPDATE livraisons
       SET tentatives = tentatives + 1, updated_at = NOW()
       WHERE id = $1`,
      [livraisonId]
    );

    await client.query('COMMIT');
    return incidentResult.rows[0];

  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// ══════════════════════════════════════════════════════════
// findById() — Détail d'un incident
// ══════════════════════════════════════════════════════════
export const findById = async (id) => {
  const result = await query(
    `SELECT
       e.*,
       l.livreur_id, l.commande_id,
       u.nom AS livreur_nom, u.prenom AS livreur_prenom
     FROM echecs_livraison e
     JOIN livraisons l ON l.id = e.livraison_id
     JOIN utilisateurs u ON u.id = l.livreur_id
     WHERE e.id = $1`,
    [id]
  );
  return result.rows[0] ?? null;
};

// ══════════════════════════════════════════════════════════
// findAll() — Liste paginée avec filtres
// ══════════════════════════════════════════════════════════
export const findAll = async ({ livreurId, page = 1, limit = 20, type, resolu }) => {
  const offset     = (page - 1) * limit;
  const params     = [];
  const conditions = [];

  if (livreurId) {
    params.push(livreurId);
    conditions.push(`l.livreur_id = ${params.length}`);
  }
  if (type) {
    params.push(type);
    conditions.push(`e.type = ${params.length}`);
  }
  if (resolu !== undefined) {
    params.push(resolu);
    conditions.push(`e.resolu = ${params.length}`);
  }

  const WHERE = conditions.length
    ? `WHERE ${conditions.join(' AND ')}`
    : '';

  params.push(limit, offset);
  const dataResult = await query(
    `SELECT
       e.id, e.type, e.description, e.declare_at,
       e.resolu, e.resolu_at,
       l.id AS livraison_id,
       u.nom AS livreur_nom, u.prenom AS livreur_prenom
     FROM echecs_livraison e
     JOIN livraisons l ON l.id = e.livraison_id
     JOIN utilisateurs u ON u.id = l.livreur_id
     ${WHERE}
     ORDER BY e.declare_at DESC
     LIMIT ${params.length - 1} OFFSET ${params.length}`,
    params
  );

  const countResult = await query(
    `SELECT COUNT(*) AS total
     FROM echecs_livraison e
     JOIN livraisons l ON l.id = e.livraison_id
     ${WHERE}`,
    params.slice(0, -2)
  );

  return {
    incidents:  dataResult.rows,
    total:      parseInt(countResult.rows[0].total),
    page, limit,
    totalPages: Math.ceil(parseInt(countResult.rows[0].total) / limit),
  };
};

// ══════════════════════════════════════════════════════════
// resoudreIncident() — Résolution par un admin
// ══════════════════════════════════════════════════════════
export const resoudreIncident = async (id, adminId) => {
  const result = await query(
    `UPDATE echecs_livraison
     SET resolu = true, resolu_by = $1, resolu_at = NOW()
     WHERE id = $2
     RETURNING *`,
    [adminId, id]
  );
  return result.rows[0] ?? null;
};