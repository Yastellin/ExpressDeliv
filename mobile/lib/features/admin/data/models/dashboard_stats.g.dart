// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      periode: json['periode'] as String,
      date_debut: DateTime.parse(json['date_debut'] as String),
      commandes:
          CommandesStats.fromJson(json['commandes'] as Map<String, dynamic>),
      livraisons:
          LivraisonsStats.fromJson(json['livraisons'] as Map<String, dynamic>),
      incidents:
          IncidentsStats.fromJson(json['incidents'] as Map<String, dynamic>),
      utilisateurs: UtilisateursStats.fromJson(
          json['utilisateurs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
        _$DashboardStatsImpl instance) =>
    <String, dynamic>{
      'periode': instance.periode,
      'date_debut': instance.date_debut.toIso8601String(),
      'commandes': instance.commandes,
      'livraisons': instance.livraisons,
      'incidents': instance.incidents,
      'utilisateurs': instance.utilisateurs,
    };

_$CommandesStatsImpl _$$CommandesStatsImplFromJson(Map<String, dynamic> json) =>
    _$CommandesStatsImpl(
      total_commandes: json['total_commandes'] as String,
      commandes_livrees: json['commandes_livrees'] as String,
      commandes_en_attente: json['commandes_en_attente'] as String,
      commandes_annulees: json['commandes_annulees'] as String,
      revenue_total: json['revenue_total'] as String,
      revenue_livre: json['revenue_livre'] as String,
    );

Map<String, dynamic> _$$CommandesStatsImplToJson(
        _$CommandesStatsImpl instance) =>
    <String, dynamic>{
      'total_commandes': instance.total_commandes,
      'commandes_livrees': instance.commandes_livrees,
      'commandes_en_attente': instance.commandes_en_attente,
      'commandes_annulees': instance.commandes_annulees,
      'revenue_total': instance.revenue_total,
      'revenue_livre': instance.revenue_livre,
    };

_$LivraisonsStatsImpl _$$LivraisonsStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$LivraisonsStatsImpl(
      total_livraisons: json['total_livraisons'] as String,
      livraisons_reussies: json['livraisons_reussies'] as String,
      livraisons_echouees: json['livraisons_echouees'] as String,
      livraisons_en_cours: json['livraisons_en_cours'] as String,
      taux_succes: json['taux_succes'] as String,
    );

Map<String, dynamic> _$$LivraisonsStatsImplToJson(
        _$LivraisonsStatsImpl instance) =>
    <String, dynamic>{
      'total_livraisons': instance.total_livraisons,
      'livraisons_reussies': instance.livraisons_reussies,
      'livraisons_echouees': instance.livraisons_echouees,
      'livraisons_en_cours': instance.livraisons_en_cours,
      'taux_succes': instance.taux_succes,
    };

_$IncidentsStatsImpl _$$IncidentsStatsImplFromJson(Map<String, dynamic> json) =>
    _$IncidentsStatsImpl(
      total_incidents: json['total_incidents'] as String,
      incidents_ouverts: json['incidents_ouverts'] as String,
      incidents_resolus: json['incidents_resolus'] as String,
    );

Map<String, dynamic> _$$IncidentsStatsImplToJson(
        _$IncidentsStatsImpl instance) =>
    <String, dynamic>{
      'total_incidents': instance.total_incidents,
      'incidents_ouverts': instance.incidents_ouverts,
      'incidents_resolus': instance.incidents_resolus,
    };

_$UtilisateursStatsImpl _$$UtilisateursStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$UtilisateursStatsImpl(
      total_utilisateurs: json['total_utilisateurs'] as String,
      total_clients: json['total_clients'] as String,
      total_livreurs: json['total_livreurs'] as String,
      nouveaux_utilisateurs: json['nouveaux_utilisateurs'] as String,
    );

Map<String, dynamic> _$$UtilisateursStatsImplToJson(
        _$UtilisateursStatsImpl instance) =>
    <String, dynamic>{
      'total_utilisateurs': instance.total_utilisateurs,
      'total_clients': instance.total_clients,
      'total_livreurs': instance.total_livreurs,
      'nouveaux_utilisateurs': instance.nouveaux_utilisateurs,
    };
