// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livraison.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LivraisonImpl _$$LivraisonImplFromJson(Map<String, dynamic> json) =>
    _$LivraisonImpl(
      id: json['id'] as String,
      statut: json['statut'] as String,
      tentatives: (json['tentatives'] as num).toInt(),
      date_affectation: DateTime.parse(json['date_affectation'] as String),
      date_debut: json['date_debut'] == null
          ? null
          : DateTime.parse(json['date_debut'] as String),
      date_fin: json['date_fin'] == null
          ? null
          : DateTime.parse(json['date_fin'] as String),
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      adresse_livraison: json['adresse_livraison'] as String,
      montant_total: json['montant_total'] as String,
      client_nom: json['client_nom'] as String?,
      client_prenom: json['client_prenom'] as String?,
      livreur_nom: json['livreur_nom'] as String?,
      livreur_prenom: json['livreur_prenom'] as String?,
    );

Map<String, dynamic> _$$LivraisonImplToJson(_$LivraisonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'statut': instance.statut,
      'tentatives': instance.tentatives,
      'date_affectation': instance.date_affectation.toIso8601String(),
      'date_debut': instance.date_debut?.toIso8601String(),
      'date_fin': instance.date_fin?.toIso8601String(),
      'created_at': instance.created_at.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'adresse_livraison': instance.adresse_livraison,
      'montant_total': instance.montant_total,
      'client_nom': instance.client_nom,
      'client_prenom': instance.client_prenom,
      'livreur_nom': instance.livreur_nom,
      'livreur_prenom': instance.livreur_prenom,
    };
