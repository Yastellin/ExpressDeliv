import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/auth_request.dart';   // <-- Chemin relatif correct

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio = DioClient.instance;

@override
Future<AuthResponse> login(LoginRequest request) async {
  try {
    final response = await _dio.post('/auth/login', data: request.toJson());
    
    print('Réponse brute login : ${response.data}');
    // On parse le wrapper
    final wrapper = LoginResponseWrapper.fromJson(response.data);
    
    // On vérifie si la connexion a réussi (au cas où)
    if (!wrapper.success) {
      throw Exception(wrapper.message);
    }
    
    // On extrait les données
    final data = wrapper.data;
    
    // Sauvegarde des tokens
    await StorageService.saveTokens(data.accessToken, data.refreshToken);
    await StorageService.saveUser(jsonEncode(data.user.toJson()));
    
    // On retourne un objet AuthResponse (si vous voulez garder le même type)
    // Sinon, on peut retourner directement les données.
    // Pour simplifier, on va créer un AuthResponse à partir de data.
    return AuthResponse(
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
      user: data.user,
    );
  } on DioException catch (e) {
    // Gestion d'erreur améliorée (comme avant)
    String errorMessage = 'Identifiants incorrects';
    if (e.response?.data != null) {
      try {
        final data = e.response?.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          errorMessage = data['message'] as String;
        } else if (data.containsKey('error')) {
          errorMessage = data['error'] as String;
        }
      } catch (_) {
        errorMessage = e.response?.data.toString() ?? 'Erreur serveur';
      }
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Impossible de joindre le serveur.';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Délai de connexion dépassé.';
    }
    throw Exception(errorMessage);
  } catch (e) {
    throw Exception('Erreur inattendue : ${e.toString()}');
  }
}

@override
Future<void> logout() async {
  try {
    final refreshToken = await StorageService.getRefreshToken();
    if (refreshToken != null) {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    }
  } catch (e) {
    // On ignore les erreurs de logout coté serveur
    // car on veut quand même supprimer les tokens localement
  } finally {
    await StorageService.clearTokens();
  }
}

@override
Future<UserDto> updateProfile(Map<String, dynamic> data) async {
  try {
    final response = await _dio.put('/users/me', data: data);
    final userData = response.data['data'] ?? response.data;
    return UserDto.fromJson(userData);
  } on DioException catch (e) {
    final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
    throw Exception('Erreur : $errorMsg');
  } catch (e) {
    throw Exception('Erreur inattendue');
  }
}

@override
Future<void> registerFcmToken(String token) async {
  try {
    await _dio.post('/notifications/token', data: {'token': token});
    print('Token FCM enregistré');
  } catch (e) {
    print('Erreur enregistrement token FCM : $e');
  }
}
}