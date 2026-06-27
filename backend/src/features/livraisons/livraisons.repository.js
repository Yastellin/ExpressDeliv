import { query, getClient } from '../../config/database.js';

// ══════════════════════════════════════════════════════════
// createLivraison() — Création + mise à jour commande (ACID)
// ══════════════════════════════════════════════════════════
export const createLivraison = async (commandeId, livreurId) => {
  const client = await getClient();
  try {
    await client.query('BEGIN');

    // 1. Créer la livraison
    const livrResult = await client.query(
      `INSERT INTO livraisons (commande_id, livreur_id)
       VALUES ($1, $2)
       RETURNING *`,
      [commandeId, livreurId]
    );
    const livraison = livrResult.rows[0];

    // 2. Mettre à jour le statut de la commande → CONFIRMEE
    await client.query(
      `UPDATE commandes
       SET statut = 'CONFIRMEE', updated_at = NOW()
       WHERE id = $1`,
      [commandeId]
    );

    await client.query('COMMIT');
    return livraison;

  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// ══════════════════════════════════════════════════════════
// findById() — Détail complet d'une livraison
// ══════════════════════════════════════════════════════════
export const findById = async (id) => {
  const result = await query(
    `SELECT
       l.*,
       c.adresse_livraison, c.montant_total, c.notes,
       c.client_id,
       cl.nom  AS client_nom,  cl.prenom  AS client_prenom,
       cl.email AS client_email, cl.telephone AS client_telephone,
       lv.nom  AS livreur_nom, lv.prenom  AS livreur_prenom,
       lv.telephone AS livreur_telephone
     FROM livraisons l
     JOIN commandes    c  ON c.id  = l.commande_id
     JOIN utilisateurs cl ON cl.id = c.client_id
     JOIN utilisateurs lv ON lv.id = l.livreur_id
     WHERE l.id = $1`,
    [id]
  );
  return result.rows[0] ?? null;
};

// ══════════════════════════════════════════════════════════
// findAll() — Liste paginée avec filtres
// ══════════════════════════════════════════════════════════
export const findAll = async ({ livreurId, livreur_id, statut, page = 1, limit = 20 }) => {
  const offset = (page - 1) * limit;
  const params = [];
  const conditions = [];
  let paramIndex = 1; // ✅ Compteur de placeholders

  // On accepte livreurId ou livreur_id
  const idLivreur = livreurId || livreur_id;
  if (idLivreur) {
    params.push(idLivreur);
    conditions.push(`l.livreur_id = $${paramIndex++}::uuid`); // ✅ conversion explicite
  }
  if (statut) {
    params.push(statut);
    conditions.push(`l.statut = $${paramIndex++}`);
  }

  const WHERE = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

  // On ajoute LIMIT et OFFSET avec des placeholders
  params.push(limit, offset);
  const limitPlaceholder = `$${paramIndex++}`;
  const offsetPlaceholder = `$${paramIndex}`;

  const dataResult = await query(
    `SELECT
       l.id, l.statut, l.tentatives,
       l.date_affectation, l.date_debut, l.date_fin,
       l.created_at, l.updated_at,
       c.adresse_livraison, c.montant_total,
       cl.nom AS client_nom, cl.prenom AS client_prenom,
       lv.nom AS livreur_nom, lv.prenom AS livreur_prenom
     FROM livraisons l
     JOIN commandes    c  ON c.id  = l.commande_id
     JOIN utilisateurs cl ON cl.id = c.client_id
     JOIN utilisateurs lv ON lv.id = l.livreur_id
     ${WHERE}
     ORDER BY l.created_at DESC
     LIMIT ${limitPlaceholder} OFFSET ${offsetPlaceholder}`,
    params
  );

  // Comptage : on retire les deux derniers paramètres (limit, offset)
  const countParams = params.slice(0, -2);
  const countResult = await query(
    `SELECT COUNT(*) AS total
     FROM livraisons l
     JOIN commandes    c  ON c.id  = l.commande_id
     JOIN utilisateurs cl ON cl.id = c.client_id
     JOIN utilisateurs lv ON lv.id = l.livreur_id
     ${WHERE}`,
    countParams
  );

  return {
    livraisons: dataResult.rows,
    total: parseInt(countResult.rows[0].total),
    page,
    limit,
    totalPages: Math.ceil(parseInt(countResult.rows[0].total) / limit),
  };
};

// ══════════════════════════════════════════════════════════
// updateStatut() — Mise à jour statut livraison + commande (ACID)
// ══════════════════════════════════════════════════════════
export const updateStatut = async (id, statut, extra = {}) => {
  const client = await getClient();
  try {
    await client.query('BEGIN');

    // Champs dynamiques selon le statut
    let extraFields = '';
    if (statut === 'EN_COURS') extraFields = `, date_debut = NOW()`;
    if (['LIVREE', 'ECHOUEE', 'ANNULEE'].includes(statut)) {
      extraFields = `, date_fin = NOW()`;
    }

    const livrResult = await client.query(
      `UPDATE livraisons
       SET statut = $1, updated_at = NOW()${extraFields}
       WHERE id = $2
       RETURNING *`,
      [statut, id]
    );
    const livraison = livrResult.rows[0];

    // Synchroniser le statut de la commande
    const commandeStatut = {
      EN_COURS: 'EN_COURS',
      LIVREE:   'LIVREE',
      ECHOUEE:  'EN_ATTENTE',   // retour en attente de réaffectation
      ANNULEE:  'ANNULEE',
    }[statut];

    if (commandeStatut) {
      await client.query(
        `UPDATE commandes
         SET statut = $1, updated_at = NOW()
         WHERE id = $2`,
        [commandeStatut, livraison.commande_id]
      );
    }

    await client.query('COMMIT');
    return livraison;

  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// ══════════════════════════════════════════════════════════
// savePreuve() — Enregistre la preuve de livraison (ACID)
// ══════════════════════════════════════════════════════════
export const savePreuve = async (livraisonId, type, donneePreuve) => {
  const client = await getClient();
  try {
    await client.query('BEGIN');

    // 1. Insérer la preuve
    const preuveResult = await client.query(
      `INSERT INTO preuves_livraison
         (livraison_id, type, donnee_preuve)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [livraisonId, type, donneePreuve]
    );

    // 2. Clôturer la livraison → LIVREE
    await client.query(
      `UPDATE livraisons
       SET statut = 'LIVREE', date_fin = NOW(), updated_at = NOW()
       WHERE id = $1`,
      [livraisonId]
    );

    // 3. Mettre à jour la commande → LIVREE
    await client.query(
      `UPDATE commandes c
       SET statut = 'LIVREE', updated_at = NOW()
       FROM livraisons l
       WHERE l.id = $1 AND c.id = l.commande_id`,
      [livraisonId]
    );

    await client.query('COMMIT');
    return preuveResult.rows[0];

  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// ══════════════════════════════════════════════════════════
// getPositions() — Historique GPS d'une livraison
// ══════════════════════════════════════════════════════════
export const getPositions = async (livraisonId, limit = 100) => {
  const result = await query(
    `SELECT latitude, longitude, precision_m, created_at
     FROM historique_positions_gps
     WHERE livraison_id = $1
     ORDER BY created_at DESC
     LIMIT $2`,
    [livraisonId, limit]
  );
  return result.rows;
};