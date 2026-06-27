// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preuve.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Preuve _$PreuveFromJson(Map<String, dynamic> json) {
  return _Preuve.fromJson(json);
}

/// @nodoc
mixin _$Preuve {
  String get livraisonId => throw _privateConstructorUsedError;
  String? get photoBase64 =>
      throw _privateConstructorUsedError; // ou photoUrl selon votre backend
  String? get signatureBase64 => throw _privateConstructorUsedError;
  String? get pinCode => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreuveCopyWith<Preuve> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreuveCopyWith<$Res> {
  factory $PreuveCopyWith(Preuve value, $Res Function(Preuve) then) =
      _$PreuveCopyWithImpl<$Res, Preuve>;
  @useResult
  $Res call(
      {String livraisonId,
      String? photoBase64,
      String? signatureBase64,
      String? pinCode,
      DateTime timestamp});
}

/// @nodoc
class _$PreuveCopyWithImpl<$Res, $Val extends Preuve>
    implements $PreuveCopyWith<$Res> {
  _$PreuveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? livraisonId = null,
    Object? photoBase64 = freezed,
    Object? signatureBase64 = freezed,
    Object? pinCode = freezed,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      livraisonId: null == livraisonId
          ? _value.livraisonId
          : livraisonId // ignore: cast_nullable_to_non_nullable
              as String,
      photoBase64: freezed == photoBase64
          ? _value.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureBase64: freezed == signatureBase64
          ? _value.signatureBase64
          : signatureBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      pinCode: freezed == pinCode
          ? _value.pinCode
          : pinCode // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreuveImplCopyWith<$Res> implements $PreuveCopyWith<$Res> {
  factory _$$PreuveImplCopyWith(
          _$PreuveImpl value, $Res Function(_$PreuveImpl) then) =
      __$$PreuveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String livraisonId,
      String? photoBase64,
      String? signatureBase64,
      String? pinCode,
      DateTime timestamp});
}

/// @nodoc
class __$$PreuveImplCopyWithImpl<$Res>
    extends _$PreuveCopyWithImpl<$Res, _$PreuveImpl>
    implements _$$PreuveImplCopyWith<$Res> {
  __$$PreuveImplCopyWithImpl(
      _$PreuveImpl _value, $Res Function(_$PreuveImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? livraisonId = null,
    Object? photoBase64 = freezed,
    Object? signatureBase64 = freezed,
    Object? pinCode = freezed,
    Object? timestamp = null,
  }) {
    return _then(_$PreuveImpl(
      livraisonId: null == livraisonId
          ? _value.livraisonId
          : livraisonId // ignore: cast_nullable_to_non_nullable
              as String,
      photoBase64: freezed == photoBase64
          ? _value.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureBase64: freezed == signatureBase64
          ? _value.signatureBase64
          : signatureBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      pinCode: freezed == pinCode
          ? _value.pinCode
          : pinCode // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreuveImpl implements _Preuve {
  const _$PreuveImpl(
      {required this.livraisonId,
      this.photoBase64,
      this.signatureBase64,
      this.pinCode,
      required this.timestamp});

  factory _$PreuveImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreuveImplFromJson(json);

  @override
  final String livraisonId;
  @override
  final String? photoBase64;
// ou photoUrl selon votre backend
  @override
  final String? signatureBase64;
  @override
  final String? pinCode;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'Preuve(livraisonId: $livraisonId, photoBase64: $photoBase64, signatureBase64: $signatureBase64, pinCode: $pinCode, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreuveImpl &&
            (identical(other.livraisonId, livraisonId) ||
                other.livraisonId == livraisonId) &&
            (identical(other.photoBase64, photoBase64) ||
                other.photoBase64 == photoBase64) &&
            (identical(other.signatureBase64, signatureBase64) ||
                other.signatureBase64 == signatureBase64) &&
            (identical(other.pinCode, pinCode) || other.pinCode == pinCode) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, livraisonId, photoBase64,
      signatureBase64, pinCode, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreuveImplCopyWith<_$PreuveImpl> get copyWith =>
      __$$PreuveImplCopyWithImpl<_$PreuveImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreuveImplToJson(
      this,
    );
  }
}

abstract class _Preuve implements Preuve {
  const factory _Preuve(
      {required final String livraisonId,
      final String? photoBase64,
      final String? signatureBase64,
      final String? pinCode,
      required final DateTime timestamp}) = _$PreuveImpl;

  factory _Preuve.fromJson(Map<String, dynamic> json) = _$PreuveImpl.fromJson;

  @override
  String get livraisonId;
  @override
  String? get photoBase64;
  @override // ou photoUrl selon votre backend
  String? get signatureBase64;
  @override
  String? get pinCode;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$PreuveImplCopyWith<_$PreuveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
