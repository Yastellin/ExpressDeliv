import 'package:freezed_annotation/freezed_annotation.dart';

part 'preuve.freezed.dart';
part 'preuve.g.dart';

@freezed
class Preuve with _$Preuve {
  const factory Preuve({
    required String livraisonId,
    String? photoBase64,      // ou photoUrl selon votre backend
    String? signatureBase64,
    String? pinCode,
    required DateTime timestamp,
  }) = _Preuve;

  factory Preuve.fromJson(Map<String, dynamic> json) => _$PreuveFromJson(json);
}