// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  String get periode => throw _privateConstructorUsedError;
  DateTime get date_debut => throw _privateConstructorUsedError;
  CommandesStats get commandes => throw _privateConstructorUsedError;
  LivraisonsStats get livraisons => throw _privateConstructorUsedError;
  IncidentsStats get incidents => throw _privateConstructorUsedError;
  UtilisateursStats get utilisateurs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
          DashboardStats value, $Res Function(DashboardStats) then) =
      _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call(
      {String periode,
      DateTime date_debut,
      CommandesStats commandes,
      LivraisonsStats livraisons,
      IncidentsStats incidents,
      UtilisateursStats utilisateurs});

  $CommandesStatsCopyWith<$Res> get commandes;
  $LivraisonsStatsCopyWith<$Res> get livraisons;
  $IncidentsStatsCopyWith<$Res> get incidents;
  $UtilisateursStatsCopyWith<$Res> get utilisateurs;
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periode = null,
    Object? date_debut = null,
    Object? commandes = null,
    Object? livraisons = null,
    Object? incidents = null,
    Object? utilisateurs = null,
  }) {
    return _then(_value.copyWith(
      periode: null == periode
          ? _value.periode
          : periode // ignore: cast_nullable_to_non_nullable
              as String,
      date_debut: null == date_debut
          ? _value.date_debut
          : date_debut // ignore: cast_nullable_to_non_nullable
              as DateTime,
      commandes: null == commandes
          ? _value.commandes
          : commandes // ignore: cast_nullable_to_non_nullable
              as CommandesStats,
      livraisons: null == livraisons
          ? _value.livraisons
          : livraisons // ignore: cast_nullable_to_non_nullable
              as LivraisonsStats,
      incidents: null == incidents
          ? _value.incidents
          : incidents // ignore: cast_nullable_to_non_nullable
              as IncidentsStats,
      utilisateurs: null == utilisateurs
          ? _value.utilisateurs
          : utilisateurs // ignore: cast_nullable_to_non_nullable
              as UtilisateursStats,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CommandesStatsCopyWith<$Res> get commandes {
    return $CommandesStatsCopyWith<$Res>(_value.commandes, (value) {
      return _then(_value.copyWith(commandes: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LivraisonsStatsCopyWith<$Res> get livraisons {
    return $LivraisonsStatsCopyWith<$Res>(_value.livraisons, (value) {
      return _then(_value.copyWith(livraisons: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $IncidentsStatsCopyWith<$Res> get incidents {
    return $IncidentsStatsCopyWith<$Res>(_value.incidents, (value) {
      return _then(_value.copyWith(incidents: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UtilisateursStatsCopyWith<$Res> get utilisateurs {
    return $UtilisateursStatsCopyWith<$Res>(_value.utilisateurs, (value) {
      return _then(_value.copyWith(utilisateurs: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(_$DashboardStatsImpl value,
          $Res Function(_$DashboardStatsImpl) then) =
      __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String periode,
      DateTime date_debut,
      CommandesStats commandes,
      LivraisonsStats livraisons,
      IncidentsStats incidents,
      UtilisateursStats utilisateurs});

  @override
  $CommandesStatsCopyWith<$Res> get commandes;
  @override
  $LivraisonsStatsCopyWith<$Res> get livraisons;
  @override
  $IncidentsStatsCopyWith<$Res> get incidents;
  @override
  $UtilisateursStatsCopyWith<$Res> get utilisateurs;
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
      _$DashboardStatsImpl _value, $Res Function(_$DashboardStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periode = null,
    Object? date_debut = null,
    Object? commandes = null,
    Object? livraisons = null,
    Object? incidents = null,
    Object? utilisateurs = null,
  }) {
    return _then(_$DashboardStatsImpl(
      periode: null == periode
          ? _value.periode
          : periode // ignore: cast_nullable_to_non_nullable
              as String,
      date_debut: null == date_debut
          ? _value.date_debut
          : date_debut // ignore: cast_nullable_to_non_nullable
              as DateTime,
      commandes: null == commandes
          ? _value.commandes
          : commandes // ignore: cast_nullable_to_non_nullable
              as CommandesStats,
      livraisons: null == livraisons
          ? _value.livraisons
          : livraisons // ignore: cast_nullable_to_non_nullable
              as LivraisonsStats,
      incidents: null == incidents
          ? _value.incidents
          : incidents // ignore: cast_nullable_to_non_nullable
              as IncidentsStats,
      utilisateurs: null == utilisateurs
          ? _value.utilisateurs
          : utilisateurs // ignore: cast_nullable_to_non_nullable
              as UtilisateursStats,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl(
      {required this.periode,
      required this.date_debut,
      required this.commandes,
      required this.livraisons,
      required this.incidents,
      required this.utilisateurs});

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  @override
  final String periode;
  @override
  final DateTime date_debut;
  @override
  final CommandesStats commandes;
  @override
  final LivraisonsStats livraisons;
  @override
  final IncidentsStats incidents;
  @override
  final UtilisateursStats utilisateurs;

  @override
  String toString() {
    return 'DashboardStats(periode: $periode, date_debut: $date_debut, commandes: $commandes, livraisons: $livraisons, incidents: $incidents, utilisateurs: $utilisateurs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.periode, periode) || other.periode == periode) &&
            (identical(other.date_debut, date_debut) ||
                other.date_debut == date_debut) &&
            (identical(other.commandes, commandes) ||
                other.commandes == commandes) &&
            (identical(other.livraisons, livraisons) ||
                other.livraisons == livraisons) &&
            (identical(other.incidents, incidents) ||
                other.incidents == incidents) &&
            (identical(other.utilisateurs, utilisateurs) ||
                other.utilisateurs == utilisateurs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, periode, date_debut, commandes,
      livraisons, incidents, utilisateurs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(
      this,
    );
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats(
      {required final String periode,
      required final DateTime date_debut,
      required final CommandesStats commandes,
      required final LivraisonsStats livraisons,
      required final IncidentsStats incidents,
      required final UtilisateursStats utilisateurs}) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override
  String get periode;
  @override
  DateTime get date_debut;
  @override
  CommandesStats get commandes;
  @override
  LivraisonsStats get livraisons;
  @override
  IncidentsStats get incidents;
  @override
  UtilisateursStats get utilisateurs;
  @override
  @JsonKey(ignore: true)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommandesStats _$CommandesStatsFromJson(Map<String, dynamic> json) {
  return _CommandesStats.fromJson(json);
}

/// @nodoc
mixin _$CommandesStats {
  String get total_commandes =>
      throw _privateConstructorUsedError; // Le backend renvoie des chaînes
  String get commandes_livrees => throw _privateConstructorUsedError;
  String get commandes_en_attente => throw _privateConstructorUsedError;
  String get commandes_annulees => throw _privateConstructorUsedError;
  String get revenue_total => throw _privateConstructorUsedError;
  String get revenue_livre => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommandesStatsCopyWith<CommandesStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommandesStatsCopyWith<$Res> {
  factory $CommandesStatsCopyWith(
          CommandesStats value, $Res Function(CommandesStats) then) =
      _$CommandesStatsCopyWithImpl<$Res, CommandesStats>;
  @useResult
  $Res call(
      {String total_commandes,
      String commandes_livrees,
      String commandes_en_attente,
      String commandes_annulees,
      String revenue_total,
      String revenue_livre});
}

/// @nodoc
class _$CommandesStatsCopyWithImpl<$Res, $Val extends CommandesStats>
    implements $CommandesStatsCopyWith<$Res> {
  _$CommandesStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_commandes = null,
    Object? commandes_livrees = null,
    Object? commandes_en_attente = null,
    Object? commandes_annulees = null,
    Object? revenue_total = null,
    Object? revenue_livre = null,
  }) {
    return _then(_value.copyWith(
      total_commandes: null == total_commandes
          ? _value.total_commandes
          : total_commandes // ignore: cast_nullable_to_non_nullable
              as String,
      commandes_livrees: null == commandes_livrees
          ? _value.commandes_livrees
          : commandes_livrees // ignore: cast_nullable_to_non_nullable
              as String,
      commandes_en_attente: null == commandes_en_attente
          ? _value.commandes_en_attente
          : commandes_en_attente // ignore: cast_nullable_to_non_nullable
              as String,
      commandes_annulees: null == commandes_annulees
          ? _value.commandes_annulees
          : commandes_annulees // ignore: cast_nullable_to_non_nullable
              as String,
      revenue_total: null == revenue_total
          ? _value.revenue_total
          : revenue_total // ignore: cast_nullable_to_non_nullable
              as String,
      revenue_livre: null == revenue_livre
          ? _value.revenue_livre
          : revenue_livre // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommandesStatsImplCopyWith<$Res>
    implements $CommandesStatsCopyWith<$Res> {
  factory _$$CommandesStatsImplCopyWith(_$CommandesStatsImpl value,
          $Res Function(_$CommandesStatsImpl) then) =
      __$$CommandesStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String total_commandes,
      String commandes_livrees,
      String commandes_en_attente,
      String commandes_annulees,
      String revenue_total,
      String revenue_livre});
}

/// @nodoc
class __$$CommandesStatsImplCopyWithImpl<$Res>
    extends _$CommandesStatsCopyWithImpl<$Res, _$CommandesStatsImpl>
    implements _$$CommandesStatsImplCopyWith<$Res> {
  __$$CommandesStatsImplCopyWithImpl(
      _$CommandesStatsImpl _value, $Res Function(_$CommandesStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_commandes = null,
    Object? commandes_livrees = null,
    Object? commandes_en_attente = null,
    Object? commandes_annulees = null,
    Object? revenue_total = null,
    Object? revenue_livre = null,
  }) {
    return _then(_$CommandesStatsImpl(
      total_commandes: null == total_commandes
          ? _value.total_commandes
          : total_commandes // ignore: cast_nullable_to_non_nullable
              as String,
      commandes_livrees: null == commandes_livrees
          ? _value.commandes_livrees
          : commandes_livrees // ignore: cast_nullable_to_non_nullable
              as String,
      commandes_en_attente: null == commandes_en_attente
          ? _value.commandes_en_attente
          : commandes_en_attente // ignore: cast_nullable_to_non_nullable
              as String,
      commandes_annulees: null == commandes_annulees
          ? _value.commandes_annulees
          : commandes_annulees // ignore: cast_nullable_to_non_nullable
              as String,
      revenue_total: null == revenue_total
          ? _value.revenue_total
          : revenue_total // ignore: cast_nullable_to_non_nullable
              as String,
      revenue_livre: null == revenue_livre
          ? _value.revenue_livre
          : revenue_livre // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommandesStatsImpl implements _CommandesStats {
  const _$CommandesStatsImpl(
      {required this.total_commandes,
      required this.commandes_livrees,
      required this.commandes_en_attente,
      required this.commandes_annulees,
      required this.revenue_total,
      required this.revenue_livre});

  factory _$CommandesStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommandesStatsImplFromJson(json);

  @override
  final String total_commandes;
// Le backend renvoie des chaînes
  @override
  final String commandes_livrees;
  @override
  final String commandes_en_attente;
  @override
  final String commandes_annulees;
  @override
  final String revenue_total;
  @override
  final String revenue_livre;

  @override
  String toString() {
    return 'CommandesStats(total_commandes: $total_commandes, commandes_livrees: $commandes_livrees, commandes_en_attente: $commandes_en_attente, commandes_annulees: $commandes_annulees, revenue_total: $revenue_total, revenue_livre: $revenue_livre)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommandesStatsImpl &&
            (identical(other.total_commandes, total_commandes) ||
                other.total_commandes == total_commandes) &&
            (identical(other.commandes_livrees, commandes_livrees) ||
                other.commandes_livrees == commandes_livrees) &&
            (identical(other.commandes_en_attente, commandes_en_attente) ||
                other.commandes_en_attente == commandes_en_attente) &&
            (identical(other.commandes_annulees, commandes_annulees) ||
                other.commandes_annulees == commandes_annulees) &&
            (identical(other.revenue_total, revenue_total) ||
                other.revenue_total == revenue_total) &&
            (identical(other.revenue_livre, revenue_livre) ||
                other.revenue_livre == revenue_livre));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      total_commandes,
      commandes_livrees,
      commandes_en_attente,
      commandes_annulees,
      revenue_total,
      revenue_livre);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommandesStatsImplCopyWith<_$CommandesStatsImpl> get copyWith =>
      __$$CommandesStatsImplCopyWithImpl<_$CommandesStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommandesStatsImplToJson(
      this,
    );
  }
}

abstract class _CommandesStats implements CommandesStats {
  const factory _CommandesStats(
      {required final String total_commandes,
      required final String commandes_livrees,
      required final String commandes_en_attente,
      required final String commandes_annulees,
      required final String revenue_total,
      required final String revenue_livre}) = _$CommandesStatsImpl;

  factory _CommandesStats.fromJson(Map<String, dynamic> json) =
      _$CommandesStatsImpl.fromJson;

  @override
  String get total_commandes;
  @override // Le backend renvoie des chaînes
  String get commandes_livrees;
  @override
  String get commandes_en_attente;
  @override
  String get commandes_annulees;
  @override
  String get revenue_total;
  @override
  String get revenue_livre;
  @override
  @JsonKey(ignore: true)
  _$$CommandesStatsImplCopyWith<_$CommandesStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LivraisonsStats _$LivraisonsStatsFromJson(Map<String, dynamic> json) {
  return _LivraisonsStats.fromJson(json);
}

/// @nodoc
mixin _$LivraisonsStats {
  String get total_livraisons => throw _privateConstructorUsedError;
  String get livraisons_reussies => throw _privateConstructorUsedError;
  String get livraisons_echouees => throw _privateConstructorUsedError;
  String get livraisons_en_cours => throw _privateConstructorUsedError;
  String get taux_succes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LivraisonsStatsCopyWith<LivraisonsStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LivraisonsStatsCopyWith<$Res> {
  factory $LivraisonsStatsCopyWith(
          LivraisonsStats value, $Res Function(LivraisonsStats) then) =
      _$LivraisonsStatsCopyWithImpl<$Res, LivraisonsStats>;
  @useResult
  $Res call(
      {String total_livraisons,
      String livraisons_reussies,
      String livraisons_echouees,
      String livraisons_en_cours,
      String taux_succes});
}

/// @nodoc
class _$LivraisonsStatsCopyWithImpl<$Res, $Val extends LivraisonsStats>
    implements $LivraisonsStatsCopyWith<$Res> {
  _$LivraisonsStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_livraisons = null,
    Object? livraisons_reussies = null,
    Object? livraisons_echouees = null,
    Object? livraisons_en_cours = null,
    Object? taux_succes = null,
  }) {
    return _then(_value.copyWith(
      total_livraisons: null == total_livraisons
          ? _value.total_livraisons
          : total_livraisons // ignore: cast_nullable_to_non_nullable
              as String,
      livraisons_reussies: null == livraisons_reussies
          ? _value.livraisons_reussies
          : livraisons_reussies // ignore: cast_nullable_to_non_nullable
              as String,
      livraisons_echouees: null == livraisons_echouees
          ? _value.livraisons_echouees
          : livraisons_echouees // ignore: cast_nullable_to_non_nullable
              as String,
      livraisons_en_cours: null == livraisons_en_cours
          ? _value.livraisons_en_cours
          : livraisons_en_cours // ignore: cast_nullable_to_non_nullable
              as String,
      taux_succes: null == taux_succes
          ? _value.taux_succes
          : taux_succes // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LivraisonsStatsImplCopyWith<$Res>
    implements $LivraisonsStatsCopyWith<$Res> {
  factory _$$LivraisonsStatsImplCopyWith(_$LivraisonsStatsImpl value,
          $Res Function(_$LivraisonsStatsImpl) then) =
      __$$LivraisonsStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String total_livraisons,
      String livraisons_reussies,
      String livraisons_echouees,
      String livraisons_en_cours,
      String taux_succes});
}

/// @nodoc
class __$$LivraisonsStatsImplCopyWithImpl<$Res>
    extends _$LivraisonsStatsCopyWithImpl<$Res, _$LivraisonsStatsImpl>
    implements _$$LivraisonsStatsImplCopyWith<$Res> {
  __$$LivraisonsStatsImplCopyWithImpl(
      _$LivraisonsStatsImpl _value, $Res Function(_$LivraisonsStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_livraisons = null,
    Object? livraisons_reussies = null,
    Object? livraisons_echouees = null,
    Object? livraisons_en_cours = null,
    Object? taux_succes = null,
  }) {
    return _then(_$LivraisonsStatsImpl(
      total_livraisons: null == total_livraisons
          ? _value.total_livraisons
          : total_livraisons // ignore: cast_nullable_to_non_nullable
              as String,
      livraisons_reussies: null == livraisons_reussies
          ? _value.livraisons_reussies
          : livraisons_reussies // ignore: cast_nullable_to_non_nullable
              as String,
      livraisons_echouees: null == livraisons_echouees
          ? _value.livraisons_echouees
          : livraisons_echouees // ignore: cast_nullable_to_non_nullable
              as String,
      livraisons_en_cours: null == livraisons_en_cours
          ? _value.livraisons_en_cours
          : livraisons_en_cours // ignore: cast_nullable_to_non_nullable
              as String,
      taux_succes: null == taux_succes
          ? _value.taux_succes
          : taux_succes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LivraisonsStatsImpl implements _LivraisonsStats {
  const _$LivraisonsStatsImpl(
      {required this.total_livraisons,
      required this.livraisons_reussies,
      required this.livraisons_echouees,
      required this.livraisons_en_cours,
      required this.taux_succes});

  factory _$LivraisonsStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LivraisonsStatsImplFromJson(json);

  @override
  final String total_livraisons;
  @override
  final String livraisons_reussies;
  @override
  final String livraisons_echouees;
  @override
  final String livraisons_en_cours;
  @override
  final String taux_succes;

  @override
  String toString() {
    return 'LivraisonsStats(total_livraisons: $total_livraisons, livraisons_reussies: $livraisons_reussies, livraisons_echouees: $livraisons_echouees, livraisons_en_cours: $livraisons_en_cours, taux_succes: $taux_succes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LivraisonsStatsImpl &&
            (identical(other.total_livraisons, total_livraisons) ||
                other.total_livraisons == total_livraisons) &&
            (identical(other.livraisons_reussies, livraisons_reussies) ||
                other.livraisons_reussies == livraisons_reussies) &&
            (identical(other.livraisons_echouees, livraisons_echouees) ||
                other.livraisons_echouees == livraisons_echouees) &&
            (identical(other.livraisons_en_cours, livraisons_en_cours) ||
                other.livraisons_en_cours == livraisons_en_cours) &&
            (identical(other.taux_succes, taux_succes) ||
                other.taux_succes == taux_succes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      total_livraisons,
      livraisons_reussies,
      livraisons_echouees,
      livraisons_en_cours,
      taux_succes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LivraisonsStatsImplCopyWith<_$LivraisonsStatsImpl> get copyWith =>
      __$$LivraisonsStatsImplCopyWithImpl<_$LivraisonsStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LivraisonsStatsImplToJson(
      this,
    );
  }
}

abstract class _LivraisonsStats implements LivraisonsStats {
  const factory _LivraisonsStats(
      {required final String total_livraisons,
      required final String livraisons_reussies,
      required final String livraisons_echouees,
      required final String livraisons_en_cours,
      required final String taux_succes}) = _$LivraisonsStatsImpl;

  factory _LivraisonsStats.fromJson(Map<String, dynamic> json) =
      _$LivraisonsStatsImpl.fromJson;

  @override
  String get total_livraisons;
  @override
  String get livraisons_reussies;
  @override
  String get livraisons_echouees;
  @override
  String get livraisons_en_cours;
  @override
  String get taux_succes;
  @override
  @JsonKey(ignore: true)
  _$$LivraisonsStatsImplCopyWith<_$LivraisonsStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IncidentsStats _$IncidentsStatsFromJson(Map<String, dynamic> json) {
  return _IncidentsStats.fromJson(json);
}

/// @nodoc
mixin _$IncidentsStats {
  String get total_incidents => throw _privateConstructorUsedError;
  String get incidents_ouverts => throw _privateConstructorUsedError;
  String get incidents_resolus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IncidentsStatsCopyWith<IncidentsStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncidentsStatsCopyWith<$Res> {
  factory $IncidentsStatsCopyWith(
          IncidentsStats value, $Res Function(IncidentsStats) then) =
      _$IncidentsStatsCopyWithImpl<$Res, IncidentsStats>;
  @useResult
  $Res call(
      {String total_incidents,
      String incidents_ouverts,
      String incidents_resolus});
}

/// @nodoc
class _$IncidentsStatsCopyWithImpl<$Res, $Val extends IncidentsStats>
    implements $IncidentsStatsCopyWith<$Res> {
  _$IncidentsStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_incidents = null,
    Object? incidents_ouverts = null,
    Object? incidents_resolus = null,
  }) {
    return _then(_value.copyWith(
      total_incidents: null == total_incidents
          ? _value.total_incidents
          : total_incidents // ignore: cast_nullable_to_non_nullable
              as String,
      incidents_ouverts: null == incidents_ouverts
          ? _value.incidents_ouverts
          : incidents_ouverts // ignore: cast_nullable_to_non_nullable
              as String,
      incidents_resolus: null == incidents_resolus
          ? _value.incidents_resolus
          : incidents_resolus // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IncidentsStatsImplCopyWith<$Res>
    implements $IncidentsStatsCopyWith<$Res> {
  factory _$$IncidentsStatsImplCopyWith(_$IncidentsStatsImpl value,
          $Res Function(_$IncidentsStatsImpl) then) =
      __$$IncidentsStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String total_incidents,
      String incidents_ouverts,
      String incidents_resolus});
}

/// @nodoc
class __$$IncidentsStatsImplCopyWithImpl<$Res>
    extends _$IncidentsStatsCopyWithImpl<$Res, _$IncidentsStatsImpl>
    implements _$$IncidentsStatsImplCopyWith<$Res> {
  __$$IncidentsStatsImplCopyWithImpl(
      _$IncidentsStatsImpl _value, $Res Function(_$IncidentsStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_incidents = null,
    Object? incidents_ouverts = null,
    Object? incidents_resolus = null,
  }) {
    return _then(_$IncidentsStatsImpl(
      total_incidents: null == total_incidents
          ? _value.total_incidents
          : total_incidents // ignore: cast_nullable_to_non_nullable
              as String,
      incidents_ouverts: null == incidents_ouverts
          ? _value.incidents_ouverts
          : incidents_ouverts // ignore: cast_nullable_to_non_nullable
              as String,
      incidents_resolus: null == incidents_resolus
          ? _value.incidents_resolus
          : incidents_resolus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IncidentsStatsImpl implements _IncidentsStats {
  const _$IncidentsStatsImpl(
      {required this.total_incidents,
      required this.incidents_ouverts,
      required this.incidents_resolus});

  factory _$IncidentsStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncidentsStatsImplFromJson(json);

  @override
  final String total_incidents;
  @override
  final String incidents_ouverts;
  @override
  final String incidents_resolus;

  @override
  String toString() {
    return 'IncidentsStats(total_incidents: $total_incidents, incidents_ouverts: $incidents_ouverts, incidents_resolus: $incidents_resolus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncidentsStatsImpl &&
            (identical(other.total_incidents, total_incidents) ||
                other.total_incidents == total_incidents) &&
            (identical(other.incidents_ouverts, incidents_ouverts) ||
                other.incidents_ouverts == incidents_ouverts) &&
            (identical(other.incidents_resolus, incidents_resolus) ||
                other.incidents_resolus == incidents_resolus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, total_incidents, incidents_ouverts, incidents_resolus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IncidentsStatsImplCopyWith<_$IncidentsStatsImpl> get copyWith =>
      __$$IncidentsStatsImplCopyWithImpl<_$IncidentsStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IncidentsStatsImplToJson(
      this,
    );
  }
}

abstract class _IncidentsStats implements IncidentsStats {
  const factory _IncidentsStats(
      {required final String total_incidents,
      required final String incidents_ouverts,
      required final String incidents_resolus}) = _$IncidentsStatsImpl;

  factory _IncidentsStats.fromJson(Map<String, dynamic> json) =
      _$IncidentsStatsImpl.fromJson;

  @override
  String get total_incidents;
  @override
  String get incidents_ouverts;
  @override
  String get incidents_resolus;
  @override
  @JsonKey(ignore: true)
  _$$IncidentsStatsImplCopyWith<_$IncidentsStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UtilisateursStats _$UtilisateursStatsFromJson(Map<String, dynamic> json) {
  return _UtilisateursStats.fromJson(json);
}

/// @nodoc
mixin _$UtilisateursStats {
  String get total_utilisateurs => throw _privateConstructorUsedError;
  String get total_clients => throw _privateConstructorUsedError;
  String get total_livreurs => throw _privateConstructorUsedError;
  String get nouveaux_utilisateurs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UtilisateursStatsCopyWith<UtilisateursStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UtilisateursStatsCopyWith<$Res> {
  factory $UtilisateursStatsCopyWith(
          UtilisateursStats value, $Res Function(UtilisateursStats) then) =
      _$UtilisateursStatsCopyWithImpl<$Res, UtilisateursStats>;
  @useResult
  $Res call(
      {String total_utilisateurs,
      String total_clients,
      String total_livreurs,
      String nouveaux_utilisateurs});
}

/// @nodoc
class _$UtilisateursStatsCopyWithImpl<$Res, $Val extends UtilisateursStats>
    implements $UtilisateursStatsCopyWith<$Res> {
  _$UtilisateursStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_utilisateurs = null,
    Object? total_clients = null,
    Object? total_livreurs = null,
    Object? nouveaux_utilisateurs = null,
  }) {
    return _then(_value.copyWith(
      total_utilisateurs: null == total_utilisateurs
          ? _value.total_utilisateurs
          : total_utilisateurs // ignore: cast_nullable_to_non_nullable
              as String,
      total_clients: null == total_clients
          ? _value.total_clients
          : total_clients // ignore: cast_nullable_to_non_nullable
              as String,
      total_livreurs: null == total_livreurs
          ? _value.total_livreurs
          : total_livreurs // ignore: cast_nullable_to_non_nullable
              as String,
      nouveaux_utilisateurs: null == nouveaux_utilisateurs
          ? _value.nouveaux_utilisateurs
          : nouveaux_utilisateurs // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UtilisateursStatsImplCopyWith<$Res>
    implements $UtilisateursStatsCopyWith<$Res> {
  factory _$$UtilisateursStatsImplCopyWith(_$UtilisateursStatsImpl value,
          $Res Function(_$UtilisateursStatsImpl) then) =
      __$$UtilisateursStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String total_utilisateurs,
      String total_clients,
      String total_livreurs,
      String nouveaux_utilisateurs});
}

/// @nodoc
class __$$UtilisateursStatsImplCopyWithImpl<$Res>
    extends _$UtilisateursStatsCopyWithImpl<$Res, _$UtilisateursStatsImpl>
    implements _$$UtilisateursStatsImplCopyWith<$Res> {
  __$$UtilisateursStatsImplCopyWithImpl(_$UtilisateursStatsImpl _value,
      $Res Function(_$UtilisateursStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total_utilisateurs = null,
    Object? total_clients = null,
    Object? total_livreurs = null,
    Object? nouveaux_utilisateurs = null,
  }) {
    return _then(_$UtilisateursStatsImpl(
      total_utilisateurs: null == total_utilisateurs
          ? _value.total_utilisateurs
          : total_utilisateurs // ignore: cast_nullable_to_non_nullable
              as String,
      total_clients: null == total_clients
          ? _value.total_clients
          : total_clients // ignore: cast_nullable_to_non_nullable
              as String,
      total_livreurs: null == total_livreurs
          ? _value.total_livreurs
          : total_livreurs // ignore: cast_nullable_to_non_nullable
              as String,
      nouveaux_utilisateurs: null == nouveaux_utilisateurs
          ? _value.nouveaux_utilisateurs
          : nouveaux_utilisateurs // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UtilisateursStatsImpl implements _UtilisateursStats {
  const _$UtilisateursStatsImpl(
      {required this.total_utilisateurs,
      required this.total_clients,
      required this.total_livreurs,
      required this.nouveaux_utilisateurs});

  factory _$UtilisateursStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UtilisateursStatsImplFromJson(json);

  @override
  final String total_utilisateurs;
  @override
  final String total_clients;
  @override
  final String total_livreurs;
  @override
  final String nouveaux_utilisateurs;

  @override
  String toString() {
    return 'UtilisateursStats(total_utilisateurs: $total_utilisateurs, total_clients: $total_clients, total_livreurs: $total_livreurs, nouveaux_utilisateurs: $nouveaux_utilisateurs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UtilisateursStatsImpl &&
            (identical(other.total_utilisateurs, total_utilisateurs) ||
                other.total_utilisateurs == total_utilisateurs) &&
            (identical(other.total_clients, total_clients) ||
                other.total_clients == total_clients) &&
            (identical(other.total_livreurs, total_livreurs) ||
                other.total_livreurs == total_livreurs) &&
            (identical(other.nouveaux_utilisateurs, nouveaux_utilisateurs) ||
                other.nouveaux_utilisateurs == nouveaux_utilisateurs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, total_utilisateurs,
      total_clients, total_livreurs, nouveaux_utilisateurs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UtilisateursStatsImplCopyWith<_$UtilisateursStatsImpl> get copyWith =>
      __$$UtilisateursStatsImplCopyWithImpl<_$UtilisateursStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UtilisateursStatsImplToJson(
      this,
    );
  }
}

abstract class _UtilisateursStats implements UtilisateursStats {
  const factory _UtilisateursStats(
      {required final String total_utilisateurs,
      required final String total_clients,
      required final String total_livreurs,
      required final String nouveaux_utilisateurs}) = _$UtilisateursStatsImpl;

  factory _UtilisateursStats.fromJson(Map<String, dynamic> json) =
      _$UtilisateursStatsImpl.fromJson;

  @override
  String get total_utilisateurs;
  @override
  String get total_clients;
  @override
  String get total_livreurs;
  @override
  String get nouveaux_utilisateurs;
  @override
  @JsonKey(ignore: true)
  _$$UtilisateursStatsImplCopyWith<_$UtilisateursStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
