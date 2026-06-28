import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository_impl.dart'; // ✅ Chemin corrigé
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await StorageService.init();

  // Initialiser Firebase seulement si ce n'est pas le web
  if (!kIsWeb) {
    await Firebase.initializeApp();
    await NotificationService.init();
  } else {
    print('🔵 Mode web : Firebase désactivé');
  }

  final AuthRepository authRepository = AuthRepositoryImpl();
  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepository),
      child: MaterialApp.router(
        title: 'ExpressDeliv',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF2EC4B6),
            onPrimary: Colors.white,
            secondary: Color(0xFF111827),
            onSecondary: Colors.white,
            error: Color(0xFFEF4444),
            onError: Colors.white,
            surface: Color(0xFFF9FAFB),
            onSurface: Color(0xFF111827),
          ),
        ),
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                print('🔴 Déconnexion détectée, redirection vers login');
                // Redirection directe via l'instance du routeur
                AppRouter.router.go(AppRouter.login);
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}