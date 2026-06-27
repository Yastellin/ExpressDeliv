import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    required String periode,
    required DateTime date_debut,
    required CommandesStats commandes,
    required LivraisonsStats livraisons,
    required IncidentsStats incidents,
    required UtilisateursStats utilisateurs,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}

@freezed
class CommandesStats with _$CommandesStats {
  const factory CommandesStats({
    required String total_commandes,    // Le backend renvoie des chaînes
    required String commandes_livrees,
    required String commandes_en_attente,
    required String commandes_annulees,
    required String revenue_total,
    required String revenue_livre,
  }) = _CommandesStats;

  factory CommandesStats.fromJson(Map<String, dynamic> json) =>
      _$CommandesStatsFromJson(json);
}

@freezed
class LivraisonsStats with _$LivraisonsStats {
  const factory LivraisonsStats({
    required String total_livraisons,
    required String livraisons_reussies,
    required String livraisons_echouees,
    required String livraisons_en_cours,
    required String taux_succes,
  }) = _LivraisonsStats;

  factory LivraisonsStats.fromJson(Map<String, dynamic> json) =>
      _$LivraisonsStatsFromJson(json);
}

@freezed
class IncidentsStats with _$IncidentsStats {
  const factory IncidentsStats({
    required String total_incidents,
    required String incidents_ouverts,
    required String incidents_resolus,
  }) = _IncidentsStats;

  factory IncidentsStats.fromJson(Map<String, dynamic> json) =>
      _$IncidentsStatsFromJson(json);
}

@freezed
class UtilisateursStats with _$UtilisateursStats {
  const factory UtilisateursStats({
    required String total_utilisateurs,
    required String total_clients,
    required String total_livreurs,
    required String nouveaux_utilisateurs,
  }) = _UtilisateursStats;

  factory UtilisateursStats.fromJson(Map<String, dynamic> json) =>
      _$UtilisateursStatsFromJson(json);
}