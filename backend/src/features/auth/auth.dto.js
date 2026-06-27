// ── DTO (Data Transfer Object) ────────────────────────────
// Transforme les données brutes de la DB en objets
// sûrs et formatés pour le client Flutter.
// Règle : jamais retourner password_hash, role_id raw,
// ou tout autre champ interne sensible.

// ── UserDTO : profil utilisateur public ───────────────────
export const toUserDTO = (user) => ({
  id:               user.id,
  nom:              user.nom,
  prenom:           user.prenom,
  email:            user.email,
  telephone:        user.telephone,
  role:             user.role_nom  ?? user.role,
  adresse_defaut:   user.adresse_defaut   ?? null,
  zone_geographique: user.zone_geographique ?? null,
  statut:           user.statut,
  created_at:       user.created_at,
});

// ── AuthResponseDTO : réponse après login/register ───────
export const toAuthResponseDTO = (user, accessToken, refreshToken) => ({
  accessToken,
  refreshToken,
  user: toUserDTO(user),
});

// ── RefreshResponseDTO : réponse après refresh ────────────
export const toRefreshResponseDTO = (accessToken) => ({
  accessToken,
});