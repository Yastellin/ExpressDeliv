import '../../data/models/auth_request.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<void> logout();
  Future<UserDto> updateProfile(Map<String, dynamic> data);
  Future<void> registerFcmToken(String token); 
}