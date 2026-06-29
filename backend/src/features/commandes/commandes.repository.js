import { query, getClient } from '../../config/database.js';

// ══════════════════════════════════════════════════════════
// createCommande() — Crée commande + colis (transaction ACID)
// ══════════════════════════════════════════════════════════
export const createCommande = async (clientId, commandeData) => {
  const {
    adresse_livraison,
    adresse_livraison_lat,
    adresse_livraison_lng,
    notes,
    colis,
    expediteur_nom,      // ✅ Ajout
    expediteur_prenom,   // ✅ Ajout
    expediteur_telephone // ✅ Ajout
  } = commandeData;

  // Calcul du montant total depuis les colis
  const montantTotal = colis.reduce(
    (sum, c) => sum + (c.prix_unitaire || 0), 0
  );

  const client = await getClient();
  try {
    await client.query('BEGIN');

    // 1. Insérer la commande avec les champs expéditeur
    const cmdResult = await client.query(
      `INSERT INTO commandes
         (client_id, adresse_livraison, adresse_livraison_lat,
          adresse_livraison_lng, montant_total, notes,
          expediteur_nom, expediteur_prenom, expediteur_telephone)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [clientId, adresse_livraison, adresse_livraison_lat ?? null,
       adresse_livraison_lng ?? null, montantTotal, notes ?? null,
       expediteur_nom ?? null, expediteur_prenom ?? null, expediteur_telephone ?? null]
    );
    const commande = cmdResult.rows[0];

    // 2. Insérer chaque colis lié à la commande
    const colisInseres = [];
    for (const c of colis) {
      const colisResult = await client.query(
        `INSERT INTO colis
           (commande_id, description, poids, dimensions, fragile, prix_unitaire)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [commande.id, c.description, c.poids ?? null,
         c.dimensions ? JSON.stringify(c.dimensions) : null,
         c.fragile ?? false, c.prix_unitaire]
      );
      colisInseres.push(colisResult.rows[0]);
    }

    await client.query('COMMIT');
    return { ...commande, colis: colisInseres };

  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// ══════════════════════════════════════════════════════════
// findById() — Détail commande avec ses colis et livraisons
// ══════════════════════════════════════════════════════════
export const findById = async (id) => {
  const cmdResult = await query(
    `SELECT
       c.*,
       u.nom AS client_nom, u.prenom AS client_prenom,
       u.email AS client_email, u.telephone AS client_telephone
     FROM commandes c
     JOIN utilisateurs u ON u.id = c.client_id
     WHERE c.id = $1`,
    [id]
  );
  if (!cmdResult.rows[0]) return null;

  const colisResult = await query(
    `SELECT * FROM colis WHERE commande_id = $1 ORDER BY created_at ASC`,
    [id]
  );

  const livraisonResult = await query(
    `SELECT
       l.*,
       u.nom AS livreur_nom, u.prenom AS livreur_prenom,
       u.telephone AS livreur_telephone
     FROM livraisons l
     JOIN utilisateurs u ON u.id = l.livreur_id
     WHERE l.commande_id = $1
     ORDER BY l.created_at DESC
     LIMIT 1`,
    [id]
  );

  return {
    ...cmdResult.rows[0],
    colis:     colisResult.rows,
    livraison: livraisonResult.rows[0] ?? null,
  };
};

// ══════════════════════════════════════════════════════════
// findAll() — Liste paginée avec filtres
// ══════════════════════════════════════════════════════════
export const findAll = async ({ clientId, page = 1, limit = 20,
                                statut, date_from, date_to }) => {
  const offset     = (page - 1) * limit;
  const params     = [];
  const conditions = [];

  let paramIndex = 1; // Compteur pour les placeholders $1, $2, ...

  if (clientId) {
    params.push(clientId);
    conditions.push(`c.client_id = $${paramIndex++}`);
  }
  if (statut) {
    params.push(statut);
    conditions.push(`c.statut = $${paramIndex++}`);
  }
  if (date_from) {
    params.push(date_from);
    conditions.push(`c.created_at >= $${paramIndex++}`);
  }
  if (date_to) {
    params.push(date_to);
    conditions.push(`c.created_at <= $${paramIndex++}`);
  }

  const WHERE = conditions.length
    ? `WHERE ${conditions.join(' AND ')}`
    : '';

  // Ajout des placeholders pour LIMIT et OFFSET
  params.push(limit, offset);
  const limitPlaceholder  = `$${paramIndex++}`;
  const offsetPlaceholder = `$${paramIndex}`;

  const dataResult = await query(
    `SELECT
       c.id, c.statut, c.adresse_livraison,
       c.montant_total, c.notes, c.created_at, c.updated_at,
       u.nom AS client_nom, u.prenom AS client_prenom
     FROM commandes c
     JOIN utilisateurs u ON u.id = c.client_id
     ${WHERE}
     ORDER BY c.created_at DESC
     LIMIT ${limitPlaceholder} OFFSET ${offsetPlaceholder}`,
    params
  );

  // Pour le COUNT, on utilise les mêmes conditions mais sans LIMIT/OFFSET
  const countParams = params.slice(0, -2); // On retire limit et offset
  const countResult = await query(
    `SELECT COUNT(*) AS total
     FROM commandes c
     JOIN utilisateurs u ON u.id = c.client_id
     ${WHERE}`,
    countParams
  );

  return {
    commandes:  dataResult.rows,
    total:      parseInt(countResult.rows[0].total),
    page,
    limit,
    totalPages: Math.ceil(parseInt(countResult.rows[0].total) / limit),
  };
};

// ══════════════════════════════════════════════════════════
// updateStatut() — Met à jour le statut d'une commande
// ══════════════════════════════════════════════════════════
export const updateStatut = async (id, statut) => {
  const result = await query(
    `UPDATE commandes
     SET statut = $1, updated_at = NOW()
     WHERE id = $2
     RETURNING *`,
    [statut, id]
  );
  return result.rows[0] ?? null;
};