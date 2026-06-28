// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commande.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommandeImpl _$$CommandeImplFromJson(Map<String, dynamic> json) =>
    _$CommandeImpl(
      id: json['id'] as String,
      statut: json['statut'] as String,
      adresse_livraison: json['adresse_livraison'] as String,
      montant_total: json['montant_total'] as String,
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      notes: json['notes'] as String?,
      client_nom: json['client_nom'] as String?,
      client_prenom: json['client_prenom'] as String?,
      colis: (json['colis'] as List<dynamic>?)
              ?.map((e) => Colis.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CommandeImplToJson(_$CommandeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'statut': instance.statut,
      'adresse_livraison': instance.adresse_livraison,
      'montant_total': instance.montant_total,
      'created_at': instance.created_at.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'notes': instance.notes,
      'client_nom': instance.client_nom,
      'client_prenom': instance.client_prenom,
      'colis': instance.colis,
    };

_$ColisImpl _$$ColisImplFromJson(Map<String, dynamic> json) => _$ColisImpl(
      id: json['id'] as String,
      description: json['description'] as String,
      poids: json['poids'] as String,
      prix_unitaire: json['prix_unitaire'] as String,
      quantite: json['quantite'] as String? ?? '1',
      dimensions: json['dimensions'] as String?,
      fragile: json['fragile'] as bool?,
      created_at: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ColisImplToJson(_$ColisImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'poids': instance.poids,
      'prix_unitaire': instance.prix_unitaire,
      'quantite': instance.quantite,
      'dimensions': instance.dimensions,
      'fragile': instance.fragile,
      'created_at': instance.created_at?.toIso8601String(),
    };
