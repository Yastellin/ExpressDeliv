// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preuve.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PreuveImpl _$$PreuveImplFromJson(Map<String, dynamic> json) => _$PreuveImpl(
      livraisonId: json['livraisonId'] as String,
      photoBase64: json['photoBase64'] as String?,
      signatureBase64: json['signatureBase64'] as String?,
      pinCode: json['pinCode'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$PreuveImplToJson(_$PreuveImpl instance) =>
    <String, dynamic>{
      'livraisonId': instance.livraisonId,
      'photoBase64': instance.photoBase64,
      'signatureBase64': instance.signatureBase64,
      'pinCode': instance.pinCode,
      'timestamp': instance.timestamp.toIso8601String(),
    };
