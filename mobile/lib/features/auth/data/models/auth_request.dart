import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request.freezed.dart';
part 'auth_request.g.dart';

// --- Requête de login ---
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

// --- Wrapper de la réponse (success, message, data) ---
@freezed
class LoginResponseWrapper with _$LoginResponseWrapper {
  const factory LoginResponseWrapper({
    required bool success,
    required String message,
    required LoginResponseData data,
  }) = _LoginResponseWrapper;

  factory LoginResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseWrapperFromJson(json);
}

// --- Données de la réponse (accessToken, refreshToken, user) ---
@freezed
class LoginResponseData with _$LoginResponseData {
  const factory LoginResponseData({
    required String accessToken,
    required String refreshToken,
    required UserDto user,
  }) = _LoginResponseData;

  factory LoginResponseData.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDataFromJson(json);
}

// --- Utilisateur (avec champs optionnels) ---
@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    required String role,
    String? telephone,          //  optionnel
    String? adresse_defaut,     //  optionnel
    String? zone_geographique,
    String? statut,
    String? created_at,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

// --- Classe simple pour le retour du repository (compatible avec le Cubit) ---
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}