import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/auth_request.dart';
import '../../domain/repositories/auth_repository.dart';
import 'dart:convert';  // <-- pour jsonEncode
import '../../../../core/services/storage_service.dart';  // <-- pour StorageService
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/socket_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(LoginRequest(email: email, password: password));
      emit(AuthSuccess(response.user));
      print('[AuthCubit] Appel de SocketService.init avec userId: ${response.user.id}');
      SocketService.init(response.user.id, response.user.role);
      if (!kIsWeb) {
        final token = await NotificationService.getToken();
        if (token != null) {
          await _repository.registerFcmToken(token);
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(AuthUnauthenticated()); // ✅ L'état est bien émis
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = await _repository.updateProfile(data);
      // Mettre à jour le state avec le nouvel utilisateur
      final currentState = state;
      if (currentState is AuthSuccess) {
        emit(AuthSuccess(user));
      }
      // Mettre à jour le storage
      await StorageService.saveUser(jsonEncode(user.toJson()));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}