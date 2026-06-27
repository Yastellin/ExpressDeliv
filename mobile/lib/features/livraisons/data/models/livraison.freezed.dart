// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livraison.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Livraison _$LivraisonFromJson(Map<String, dynamic> json) {
  return _Livraison.fromJson(json);
}

/// @nodoc
mixin _$Livraison {
  String get id => throw _privateConstructorUsedError;
  String get statut =>
      throw _privateConstructorUsedError; // AFFECTEE, ACCEPTEE, EN_COURS, LIVREE, ECHEC
  int get tentatives => throw _privateConstructorUsedError;
  DateTime get date_affectation => throw _privateConstructorUsedError;
  DateTime? get date_debut => throw _privateConstructorUsedError;
  DateTime? get date_fin => throw _privateConstructorUsedError;
  DateTime get created_at => throw _privateConstructorUsedError;
  DateTime? get updated_at => throw _privateConstructorUsedError;
  String get adresse_livraison => throw _privateConstructorUsedError;
  String get montant_total => throw _privateConstructorUsedError;
  String? get client_nom => throw _privateConstructorUsedError;
  String? get client_prenom => throw _privateConstructorUsedError;
  String? get livreur_nom => throw _privateConstructorUsedError;
  String? get livreur_prenom => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LivraisonCopyWith<Livraison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LivraisonCopyWith<$Res> {
  factory $LivraisonCopyWith(Livraison value, $Res Function(Livraison) then) =
      _$LivraisonCopyWithImpl<$Res, Livraison>;
  @useResult
  $Res call(
      {String id,
      String statut,
      int tentatives,
      DateTime date_affectation,
      DateTime? date_debut,
      DateTime? date_fin,
      DateTime created_at,
      DateTime? updated_at,
      String adresse_livraison,
      String montant_total,
      String? client_nom,
      String? client_prenom,
      String? livreur_nom,
      String? livreur_prenom});
}

/// @nodoc
class _$LivraisonCopyWithImpl<$Res, $Val extends Livraison>
    implements $LivraisonCopyWith<$Res> {
  _$LivraisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statut = null,
    Object? tentatives = null,
    Object? date_affectation = null,
    Object? date_debut = freezed,
    Object? date_fin = freezed,
    Object? created_at = null,
    Object? updated_at = freezed,
    Object? adresse_livraison = null,
    Object? montant_total = null,
    Object? client_nom = freezed,
    Object? client_prenom = freezed,
    Object? livreur_nom = freezed,
    Object? livreur_prenom = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      tentatives: null == tentatives
          ? _value.tentatives
          : tentatives // ignore: cast_nullable_to_non_nullable
              as int,
      date_affectation: null == date_affectation
          ? _value.date_affectation
          : date_affectation // ignore: cast_nullable_to_non_nullable
              as DateTime,
      date_debut: freezed == date_debut
          ? _value.date_debut
          : date_debut // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      date_fin: freezed == date_fin
          ? _value.date_fin
          : date_fin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated_at: freezed == updated_at
          ? _value.updated_at
          : updated_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      adresse_livraison: null == adresse_livraison
          ? _value.adresse_livraison
          : adresse_livraison // ignore: cast_nullable_to_non_nullable
              as String,
      montant_total: null == montant_total
          ? _value.montant_total
          : montant_total // ignore: cast_nullable_to_non_nullable
              as String,
      client_nom: freezed == client_nom
          ? _value.client_nom
          : client_nom // ignore: cast_nullable_to_non_nullable
              as String?,
      client_prenom: freezed == client_prenom
          ? _value.client_prenom
          : client_prenom // ignore: cast_nullable_to_non_nullable
              as String?,
      livreur_nom: freezed == livreur_nom
          ? _value.livreur_nom
          : livreur_nom // ignore: cast_nullable_to_non_nullable
              as String?,
      livreur_prenom: freezed == livreur_prenom
          ? _value.livreur_prenom
          : livreur_prenom // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LivraisonImplCopyWith<$Res>
    implements $LivraisonCopyWith<$Res> {
  factory _$$LivraisonImplCopyWith(
          _$LivraisonImpl value, $Res Function(_$LivraisonImpl) then) =
      __$$LivraisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String statut,
      int tentatives,
      DateTime date_affectation,
      DateTime? date_debut,
      DateTime? date_fin,
      DateTime created_at,
      DateTime? updated_at,
      String adresse_livraison,
      String montant_total,
      String? client_nom,
      String? client_prenom,
      String? livreur_nom,
      String? livreur_prenom});
}

/// @nodoc
class __$$LivraisonImplCopyWithImpl<$Res>
    extends _$LivraisonCopyWithImpl<$Res, _$LivraisonImpl>
    implements _$$LivraisonImplCopyWith<$Res> {
  __$$LivraisonImplCopyWithImpl(
      _$LivraisonImpl _value, $Res Function(_$LivraisonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statut = null,
    Object? tentatives = null,
    Object? date_affectation = null,
    Object? date_debut = freezed,
    Object? date_fin = freezed,
    Object? created_at = null,
    Object? updated_at = freezed,
    Object? adresse_livraison = null,
    Object? montant_total = null,
    Object? client_nom = freezed,
    Object? client_prenom = freezed,
    Object? livreur_nom = freezed,
    Object? livreur_prenom = freezed,
  }) {
    return _then(_$LivraisonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      tentatives: null == tentatives
          ? _value.tentatives
          : tentatives // ignore: cast_nullable_to_non_nullable
              as int,
      date_affectation: null == date_affectation
          ? _value.date_affectation
          : date_affectation // ignore: cast_nullable_to_non_nullable
              as DateTime,
      date_debut: freezed == date_debut
          ? _value.date_debut
          : date_debut // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      date_fin: freezed == date_fin
          ? _value.date_fin
          : date_fin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated_at: freezed == updated_at
          ? _value.updated_at
          : updated_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      adresse_livraison: null == adresse_livraison
          ? _value.adresse_livraison
          : adresse_livraison // ignore: cast_nullable_to_non_nullable
              as String,
      montant_total: null == montant_total
          ? _value.montant_total
          : montant_total // ignore: cast_nullable_to_non_nullable
              as String,
      client_nom: freezed == client_nom
          ? _value.client_nom
          : client_nom // ignore: cast_nullable_to_non_nullable
              as String?,
      client_prenom: freezed == client_prenom
          ? _value.client_prenom
          : client_prenom // ignore: cast_nullable_to_non_nullable
              as String?,
      livreur_nom: freezed == livreur_nom
          ? _value.livreur_nom
          : livreur_nom // ignore: cast_nullable_to_non_nullable
              as String?,
      livreur_prenom: freezed == livreur_prenom
          ? _value.livreur_prenom
          : livreur_prenom // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LivraisonImpl implements _Livraison {
  const _$LivraisonImpl(
      {required this.id,
      required this.statut,
      required this.tentatives,
      required this.date_affectation,
      this.date_debut,
      this.date_fin,
      required this.created_at,
      this.updated_at,
      required this.adresse_livraison,
      required this.montant_total,
      this.client_nom,
      this.client_prenom,
      this.livreur_nom,
      this.livreur_prenom});

  factory _$LivraisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LivraisonImplFromJson(json);

  @override
  final String id;
  @override
  final String statut;
// AFFECTEE, ACCEPTEE, EN_COURS, LIVREE, ECHEC
  @override
  final int tentatives;
  @override
  final DateTime date_affectation;
  @override
  final DateTime? date_debut;
  @override
  final DateTime? date_fin;
  @override
  final DateTime created_at;
  @override
  final DateTime? updated_at;
  @override
  final String adresse_livraison;
  @override
  final String montant_total;
  @override
  final String? client_nom;
  @override
  final String? client_prenom;
  @override
  final String? livreur_nom;
  @override
  final String? livreur_prenom;

  @override
  String toString() {
    return 'Livraison(id: $id, statut: $statut, tentatives: $tentatives, date_affectation: $date_affectation, date_debut: $date_debut, date_fin: $date_fin, created_at: $created_at, updated_at: $updated_at, adresse_livraison: $adresse_livraison, montant_total: $montant_total, client_nom: $client_nom, client_prenom: $client_prenom, livreur_nom: $livreur_nom, livreur_prenom: $livreur_prenom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LivraisonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.tentatives, tentatives) ||
                other.tentatives == tentatives) &&
            (identical(other.date_affectation, date_affectation) ||
                other.date_affectation == date_affectation) &&
            (identical(other.date_debut, date_debut) ||
                other.date_debut == date_debut) &&
            (identical(other.date_fin, date_fin) ||
                other.date_fin == date_fin) &&
            (identical(other.created_at, created_at) ||
                other.created_at == created_at) &&
            (identical(other.updated_at, updated_at) ||
                other.updated_at == updated_at) &&
            (identical(other.adresse_livraison, adresse_livraison) ||
                other.adresse_livraison == adresse_livraison) &&
            (identical(other.montant_total, montant_total) ||
                other.montant_total == montant_total) &&
            (identical(other.client_nom, client_nom) ||
                other.client_nom == client_nom) &&
            (identical(other.client_prenom, client_prenom) ||
                other.client_prenom == client_prenom) &&
            (identical(other.livreur_nom, livreur_nom) ||
                other.livreur_nom == livreur_nom) &&
            (identical(other.livreur_prenom, livreur_prenom) ||
                other.livreur_prenom == livreur_prenom));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      statut,
      tentatives,
      date_affectation,
      date_debut,
      date_fin,
      created_at,
      updated_at,
      adresse_livraison,
      montant_total,
      client_nom,
      client_prenom,
      livreur_nom,
      livreur_prenom);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LivraisonImplCopyWith<_$LivraisonImpl> get copyWith =>
      __$$LivraisonImplCopyWithImpl<_$LivraisonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LivraisonImplToJson(
      this,
    );
  }
}

abstract class _Livraison implements Livraison {
  const factory _Livraison(
      {required final String id,
      required final String statut,
      required final int tentatives,
      required final DateTime date_affectation,
      final DateTime? date_debut,
      final DateTime? date_fin,
      required final DateTime created_at,
      final DateTime? updated_at,
      required final String adresse_livraison,
      required final String montant_total,
      final String? client_nom,
      final String? client_prenom,
      final String? livreur_nom,
      final String? livreur_prenom}) = _$LivraisonImpl;

  factory _Livraison.fromJson(Map<String, dynamic> json) =
      _$LivraisonImpl.fromJson;

  @override
  String get id;
  @override
  String get statut;
  @override // AFFECTEE, ACCEPTEE, EN_COURS, LIVREE, ECHEC
  int get tentatives;
  @override
  DateTime get date_affectation;
  @override
  DateTime? get date_debut;
  @override
  DateTime? get date_fin;
  @override
  DateTime get created_at;
  @override
  DateTime? get updated_at;
  @override
  String get adresse_livraison;
  @override
  String get montant_total;
  @override
  String? get client_nom;
  @override
  String? get client_prenom;
  @override
  String? get livreur_nom;
  @override
  String? get livreur_prenom;
  @override
  @JsonKey(ignore: true)
  _$$LivraisonImplCopyWith<_$LivraisonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
