import { query } from '../../config/database.js';

// ══════════════════════════════════════════════════════════
// getDashboardStats() — KPIs principaux du dashboard admin
// ══════════════════════════════════════════════════════════
export const getDashboardStats = async (periode = '7d') => {
  const periodes = { '1d': 1, '7d': 7, '30d': 30, '90d': 90 };
  const jours = periodes[periode] ?? 7;
  const dateDebut = new Date();
  dateDebut.setDate(dateDebut.getDate() - jours);

  // ── KPIs commandes ────────────────────────────────────
  const commandesResult = await query(
    `SELECT
       COUNT(*)                                          AS total_commandes,
       COUNT(*) FILTER (WHERE statut = 'LIVREE')        AS commandes_livrees,
       COUNT(*) FILTER (WHERE statut = 'EN_ATTENTE')    AS commandes_en_attente,
       COUNT(*) FILTER (WHERE statut = 'ANNULEE')       AS commandes_annulees,
       COALESCE(SUM(montant_total), 0)                  AS revenue_total,
       COALESCE(SUM(montant_total)
         FILTER (WHERE statut = 'LIVREE'), 0)           AS revenue_livre
     FROM commandes
     WHERE created_at >= $1`,
    [dateDebut]
  );

  // ── KPIs livraisons ───────────────────────────────────
  const livraisonsResult = await query(
    `SELECT
       COUNT(*)                                         AS total_livraisons,
       COUNT(*) FILTER (WHERE statut = 'LIVREE')       AS livraisons_reussies,
       COUNT(*) FILTER (WHERE statut = 'ECHOUEE')      AS livraisons_echouees,
       COUNT(*) FILTER (WHERE statut = 'EN_COURS')     AS livraisons_en_cours,
       ROUND(
         COUNT(*) FILTER (WHERE statut = 'LIVREE')::numeric
         / NULLIF(COUNT(*), 0) * 100, 2
       )                                               AS taux_succes
     FROM livraisons
     WHERE created_at >= $1`,
    [dateDebut]
  );

  // ── KPIs incidents ────────────────────────────────────
  const incidentsResult = await query(
    `SELECT
       COUNT(*)                                    AS total_incidents,
       COUNT(*) FILTER (WHERE resolu = false)      AS incidents_ouverts,
       COUNT(*) FILTER (WHERE resolu = true)       AS incidents_resolus
     FROM echecs_livraison
     WHERE declare_at >= $1`,
    [dateDebut]
  );

  // ── KPIs utilisateurs ─────────────────────────────────
  const usersResult = await query(
    `SELECT
       COUNT(*)                                              AS total_utilisateurs,
       COUNT(*) FILTER (WHERE r.nom = 'CLIENT')             AS total_clients,
       COUNT(*) FILTER (WHERE r.nom = 'LIVREUR')            AS total_livreurs,
       COUNT(*) FILTER (WHERE u.created_at >= $1)           AS nouveaux_utilisateurs
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     WHERE u.statut = 'ACTIF'`,
    [dateDebut]
  );

  return {
    periode,
    date_debut: dateDebut.toISOString(),
    commandes:  commandesResult.rows[0],
    livraisons: livraisonsResult.rows[0],
    incidents:  incidentsResult.rows[0],
    utilisateurs: usersResult.rows[0],
  };
};

// ══════════════════════════════════════════════════════════
// getLivraisonsParJour() — Évolution journalière (graphique)
// ══════════════════════════════════════════════════════════
export const getLivraisonsParJour = async (jours = 7) => {
  const result = await query(
    `SELECT
       DATE(created_at)                              AS date,
       COUNT(*)                                      AS total,
       COUNT(*) FILTER (WHERE statut = 'LIVREE')    AS reussies,
       COUNT(*) FILTER (WHERE statut = 'ECHOUEE')   AS echouees
     FROM livraisons
     WHERE created_at >= NOW() - INTERVAL '$1 days'
     GROUP BY DATE(created_at)
     ORDER BY date ASC`,
    [jours]
  );
  return result.rows;
};

// ══════════════════════════════════════════════════════════
// getTopLivreurs() — Classement des meilleurs livreurs
// ══════════════════════════════════════════════════════════
export const getTopLivreurs = async (limit = 5) => {
  const result = await query(
    `SELECT
       u.id, u.nom, u.prenom, u.zone_geographique,
       COUNT(l.id)                                        AS total_missions,
       COUNT(l.id) FILTER (WHERE l.statut = 'LIVREE')    AS missions_reussies,
       ROUND(
         COUNT(l.id) FILTER (WHERE l.statut = 'LIVREE')::numeric
         / NULLIF(COUNT(l.id), 0) * 100, 2
       )                                                  AS taux_succes
     FROM utilisateurs u
     JOIN roles r ON r.id = u.role_id
     LEFT JOIN livraisons l ON l.livreur_id = u.id
     WHERE r.nom = 'LIVREUR' AND u.statut = 'ACTIF'
     GROUP BY u.id, u.nom, u.prenom, u.zone_geographique
     ORDER BY missions_reussies DESC
     LIMIT $1`,
    [limit]
  );
  return result.rows;
};

// ══════════════════════════════════════════════════════════
// getIncidentsParType() — Répartition des incidents par type
// ══════════════════════════════════════════════════════════
export const getIncidentsParType = async () => {
  const result = await query(
    `SELECT
       type,
       COUNT(*) AS total
     FROM echecs_livraison
     GROUP BY type
     ORDER BY total DESC`
  );
  return result.rows;
};