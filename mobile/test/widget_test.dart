/*import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/data/models/auth_request.dart';

// Un repository factice pour les tests (ne fait rien)
class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Création du repository mock
    final authRepository = MockAuthRepository();

    // Construction de l'app avec le repository
    await tester.pumpWidget(MyApp(authRepository: authRepository));

    expect(find.text('ExpressDeliv'), findsOneWidget);
  });
} */