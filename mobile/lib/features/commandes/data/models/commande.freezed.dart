// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commande.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Commande _$CommandeFromJson(Map<String, dynamic> json) {
  return _Commande.fromJson(json);
}

/// @nodoc
mixin _$Commande {
  String get id => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  String get adresse_livraison => throw _privateConstructorUsedError;
  String get montant_total => throw _privateConstructorUsedError;
  DateTime get created_at => throw _privateConstructorUsedError;
  DateTime? get updated_at => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get client_nom => throw _privateConstructorUsedError;
  String? get client_prenom => throw _privateConstructorUsedError;
  String? get livraisonId => throw _privateConstructorUsedError;
  List<Colis> get colis => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommandeCopyWith<Commande> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommandeCopyWith<$Res> {
  factory $CommandeCopyWith(Commande value, $Res Function(Commande) then) =
      _$CommandeCopyWithImpl<$Res, Commande>;
  @useResult
  $Res call(
      {String id,
      String statut,
      String adresse_livraison,
      String montant_total,
      DateTime created_at,
      DateTime? updated_at,
      String? notes,
      String? client_nom,
      String? client_prenom,
      String? livraisonId,
      List<Colis> colis});
}

/// @nodoc
class _$CommandeCopyWithImpl<$Res, $Val extends Commande>
    implements $CommandeCopyWith<$Res> {
  _$CommandeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statut = null,
    Object? adresse_livraison = null,
    Object? montant_total = null,
    Object? created_at = null,
    Object? updated_at = freezed,
    Object? notes = freezed,
    Object? client_nom = freezed,
    Object? client_prenom = freezed,
    Object? livraisonId = freezed,
    Object? colis = null,
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
      adresse_livraison: null == adresse_livraison
          ? _value.adresse_livraison
          : adresse_livraison // ignore: cast_nullable_to_non_nullable
              as String,
      montant_total: null == montant_total
          ? _value.montant_total
          : montant_total // ignore: cast_nullable_to_non_nullable
              as String,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated_at: freezed == updated_at
          ? _value.updated_at
          : updated_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      client_nom: freezed == client_nom
          ? _value.client_nom
          : client_nom // ignore: cast_nullable_to_non_nullable
              as String?,
      client_prenom: freezed == client_prenom
          ? _value.client_prenom
          : client_prenom // ignore: cast_nullable_to_non_nullable
              as String?,
      livraisonId: freezed == livraisonId
          ? _value.livraisonId
          : livraisonId // ignore: cast_nullable_to_non_nullable
              as String?,
      colis: null == colis
          ? _value.colis
          : colis // ignore: cast_nullable_to_non_nullable
              as List<Colis>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommandeImplCopyWith<$Res>
    implements $CommandeCopyWith<$Res> {
  factory _$$CommandeImplCopyWith(
          _$CommandeImpl value, $Res Function(_$CommandeImpl) then) =
      __$$CommandeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String statut,
      String adresse_livraison,
      String montant_total,
      DateTime created_at,
      DateTime? updated_at,
      String? notes,
      String? client_nom,
      String? client_prenom,
      String? livraisonId,
      List<Colis> colis});
}

/// @nodoc
class __$$CommandeImplCopyWithImpl<$Res>
    extends _$CommandeCopyWithImpl<$Res, _$CommandeImpl>
    implements _$$CommandeImplCopyWith<$Res> {
  __$$CommandeImplCopyWithImpl(
      _$CommandeImpl _value, $Res Function(_$CommandeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? statut = null,
    Object? adresse_livraison = null,
    Object? montant_total = null,
    Object? created_at = null,
    Object? updated_at = freezed,
    Object? notes = freezed,
    Object? client_nom = freezed,
    Object? client_prenom = freezed,
    Object? livraisonId = freezed,
    Object? colis = null,
  }) {
    return _then(_$CommandeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
      adresse_livraison: null == adresse_livraison
          ? _value.adresse_livraison
          : adresse_livraison // ignore: cast_nullable_to_non_nullable
              as String,
      montant_total: null == montant_total
          ? _value.montant_total
          : montant_total // ignore: cast_nullable_to_non_nullable
              as String,
      created_at: null == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated_at: freezed == updated_at
          ? _value.updated_at
          : updated_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      client_nom: freezed == client_nom
          ? _value.client_nom
          : client_nom // ignore: cast_nullable_to_non_nullable
              as String?,
      client_prenom: freezed == client_prenom
          ? _value.client_prenom
          : client_prenom // ignore: cast_nullable_to_non_nullable
              as String?,
      livraisonId: freezed == livraisonId
          ? _value.livraisonId
          : livraisonId // ignore: cast_nullable_to_non_nullable
              as String?,
      colis: null == colis
          ? _value._colis
          : colis // ignore: cast_nullable_to_non_nullable
              as List<Colis>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommandeImpl implements _Commande {
  const _$CommandeImpl(
      {required this.id,
      required this.statut,
      required this.adresse_livraison,
      required this.montant_total,
      required this.created_at,
      this.updated_at,
      this.notes,
      this.client_nom,
      this.client_prenom,
      this.livraisonId,
      final List<Colis> colis = const []})
      : _colis = colis;

  factory _$CommandeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommandeImplFromJson(json);

  @override
  final String id;
  @override
  final String statut;
  @override
  final String adresse_livraison;
  @override
  final String montant_total;
  @override
  final DateTime created_at;
  @override
  final DateTime? updated_at;
  @override
  final String? notes;
  @override
  final String? client_nom;
  @override
  final String? client_prenom;
  @override
  final String? livraisonId;
  final List<Colis> _colis;
  @override
  @JsonKey()
  List<Colis> get colis {
    if (_colis is EqualUnmodifiableListView) return _colis;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_colis);
  }

  @override
  String toString() {
    return 'Commande(id: $id, statut: $statut, adresse_livraison: $adresse_livraison, montant_total: $montant_total, created_at: $created_at, updated_at: $updated_at, notes: $notes, client_nom: $client_nom, client_prenom: $client_prenom, livraisonId: $livraisonId, colis: $colis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommandeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.adresse_livraison, adresse_livraison) ||
                other.adresse_livraison == adresse_livraison) &&
            (identical(other.montant_total, montant_total) ||
                other.montant_total == montant_total) &&
            (identical(other.created_at, created_at) ||
                other.created_at == created_at) &&
            (identical(other.updated_at, updated_at) ||
                other.updated_at == updated_at) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.client_nom, client_nom) ||
                other.client_nom == client_nom) &&
            (identical(other.client_prenom, client_prenom) ||
                other.client_prenom == client_prenom) &&
            (identical(other.livraisonId, livraisonId) ||
                other.livraisonId == livraisonId) &&
            const DeepCollectionEquality().equals(other._colis, _colis));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      statut,
      adresse_livraison,
      montant_total,
      created_at,
      updated_at,
      notes,
      client_nom,
      client_prenom,
      livraisonId,
      const DeepCollectionEquality().hash(_colis));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommandeImplCopyWith<_$CommandeImpl> get copyWith =>
      __$$CommandeImplCopyWithImpl<_$CommandeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommandeImplToJson(
      this,
    );
  }
}

abstract class _Commande implements Commande {
  const factory _Commande(
      {required final String id,
      required final String statut,
      required final String adresse_livraison,
      required final String montant_total,
      required final DateTime created_at,
      final DateTime? updated_at,
      final String? notes,
      final String? client_nom,
      final String? client_prenom,
      final String? livraisonId,
      final List<Colis> colis}) = _$CommandeImpl;

  factory _Commande.fromJson(Map<String, dynamic> json) =
      _$CommandeImpl.fromJson;

  @override
  String get id;
  @override
  String get statut;
  @override
  String get adresse_livraison;
  @override
  String get montant_total;
  @override
  DateTime get created_at;
  @override
  DateTime? get updated_at;
  @override
  String? get notes;
  @override
  String? get client_nom;
  @override
  String? get client_prenom;
  @override
  String? get livraisonId;
  @override
  List<Colis> get colis;
  @override
  @JsonKey(ignore: true)
  _$$CommandeImplCopyWith<_$CommandeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Colis _$ColisFromJson(Map<String, dynamic> json) {
  return _Colis.fromJson(json);
}

/// @nodoc
mixin _$Colis {
  String get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get poids => throw _privateConstructorUsedError;
  String get prix_unitaire => throw _privateConstructorUsedError;
  String get quantite =>
      throw _privateConstructorUsedError; // ✅ valeur par défaut si absent
  String? get dimensions => throw _privateConstructorUsedError;
  bool? get fragile => throw _privateConstructorUsedError;
  DateTime? get created_at => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ColisCopyWith<Colis> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColisCopyWith<$Res> {
  factory $ColisCopyWith(Colis value, $Res Function(Colis) then) =
      _$ColisCopyWithImpl<$Res, Colis>;
  @useResult
  $Res call(
      {String id,
      String description,
      String poids,
      String prix_unitaire,
      String quantite,
      String? dimensions,
      bool? fragile,
      DateTime? created_at});
}

/// @nodoc
class _$ColisCopyWithImpl<$Res, $Val extends Colis>
    implements $ColisCopyWith<$Res> {
  _$ColisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? poids = null,
    Object? prix_unitaire = null,
    Object? quantite = null,
    Object? dimensions = freezed,
    Object? fragile = freezed,
    Object? created_at = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      poids: null == poids
          ? _value.poids
          : poids // ignore: cast_nullable_to_non_nullable
              as String,
      prix_unitaire: null == prix_unitaire
          ? _value.prix_unitaire
          : prix_unitaire // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as String,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      fragile: freezed == fragile
          ? _value.fragile
          : fragile // ignore: cast_nullable_to_non_nullable
              as bool?,
      created_at: freezed == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ColisImplCopyWith<$Res> implements $ColisCopyWith<$Res> {
  factory _$$ColisImplCopyWith(
          _$ColisImpl value, $Res Function(_$ColisImpl) then) =
      __$$ColisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String description,
      String poids,
      String prix_unitaire,
      String quantite,
      String? dimensions,
      bool? fragile,
      DateTime? created_at});
}

/// @nodoc
class __$$ColisImplCopyWithImpl<$Res>
    extends _$ColisCopyWithImpl<$Res, _$ColisImpl>
    implements _$$ColisImplCopyWith<$Res> {
  __$$ColisImplCopyWithImpl(
      _$ColisImpl _value, $Res Function(_$ColisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? poids = null,
    Object? prix_unitaire = null,
    Object? quantite = null,
    Object? dimensions = freezed,
    Object? fragile = freezed,
    Object? created_at = freezed,
  }) {
    return _then(_$ColisImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      poids: null == poids
          ? _value.poids
          : poids // ignore: cast_nullable_to_non_nullable
              as String,
      prix_unitaire: null == prix_unitaire
          ? _value.prix_unitaire
          : prix_unitaire // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as String,
      dimensions: freezed == dimensions
          ? _value.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as String?,
      fragile: freezed == fragile
          ? _value.fragile
          : fragile // ignore: cast_nullable_to_non_nullable
              as bool?,
      created_at: freezed == created_at
          ? _value.created_at
          : created_at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ColisImpl implements _Colis {
  const _$ColisImpl(
      {required this.id,
      required this.description,
      required this.poids,
      required this.prix_unitaire,
      this.quantite = '1',
      this.dimensions,
      this.fragile,
      this.created_at});

  factory _$ColisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColisImplFromJson(json);

  @override
  final String id;
  @override
  final String description;
  @override
  final String poids;
  @override
  final String prix_unitaire;
  @override
  @JsonKey()
  final String quantite;
// ✅ valeur par défaut si absent
  @override
  final String? dimensions;
  @override
  final bool? fragile;
  @override
  final DateTime? created_at;

  @override
  String toString() {
    return 'Colis(id: $id, description: $description, poids: $poids, prix_unitaire: $prix_unitaire, quantite: $quantite, dimensions: $dimensions, fragile: $fragile, created_at: $created_at)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColisImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.poids, poids) || other.poids == poids) &&
            (identical(other.prix_unitaire, prix_unitaire) ||
                other.prix_unitaire == prix_unitaire) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite) &&
            (identical(other.dimensions, dimensions) ||
                other.dimensions == dimensions) &&
            (identical(other.fragile, fragile) || other.fragile == fragile) &&
            (identical(other.created_at, created_at) ||
                other.created_at == created_at));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, description, poids,
      prix_unitaire, quantite, dimensions, fragile, created_at);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ColisImplCopyWith<_$ColisImpl> get copyWith =>
      __$$ColisImplCopyWithImpl<_$ColisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColisImplToJson(
      this,
    );
  }
}

abstract class _Colis implements Colis {
  const factory _Colis(
      {required final String id,
      required final String description,
      required final String poids,
      required final String prix_unitaire,
      final String quantite,
      final String? dimensions,
      final bool? fragile,
      final DateTime? created_at}) = _$ColisImpl;

  factory _Colis.fromJson(Map<String, dynamic> json) = _$ColisImpl.fromJson;

  @override
  String get id;
  @override
  String get description;
  @override
  String get poids;
  @override
  String get prix_unitaire;
  @override
  String get quantite;
  @override // ✅ valeur par défaut si absent
  String? get dimensions;
  @override
  bool? get fragile;
  @override
  DateTime? get created_at;
  @override
  @JsonKey(ignore: true)
  _$$ColisImplCopyWith<_$ColisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
