import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../services/storage_service.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String home = '/home';

  static final router = GoRouter(
    initialLocation: splash,
    redirect: (context, state) {
      final bool isLogged = StorageService.getAccessToken() != null;
      final bool isAuthRoute = state.matchedLocation.startsWith('/auth');
      final bool isSplash = state.matchedLocation == splash;

      if (!isLogged && !isAuthRoute) {
        return login;
      }
      if (isLogged && (isAuthRoute || isSplash)) {
        return home;
      }
      return null;
    },
    routes: [
      GoRoute(path: splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: login, builder: (_, __) => const LoginPage()),
      GoRoute(path: home, builder: (_, __) => const HomePage()),
    ],
  );
}