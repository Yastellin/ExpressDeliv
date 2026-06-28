import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../widgets/dashboard_page.dart';
import '../widgets/profile_page.dart'; // ✅ Vérifiez que ProfilePage est bien importé
import '../../../commandes/presentation/pages/commandes_page.dart';
import '../../../livraisons/presentation/pages/missions_page.dart';
import '../../../livraisons/presentation/bloc/missions_cubit.dart';
import '../../../admin/presentation/pages/dashboard_admin_page.dart';
import '../../../admin/presentation/pages/gestion_utilisateurs_page.dart';
import '../../../admin/presentation/pages/gestion_commandes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late MissionsCubit _missionsCubit;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0; // forcer à 0
    _missionsCubit = MissionsCubit();
    _missionsCubit.chargerMissions();
  }

  @override
  void dispose() {
    _missionsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final role = authState.user.role;
    List<Widget> pages;
    List<Map<String, dynamic>> navItems;

    if (role == 'LIVREUR') {
      navItems = [
        {'label': 'Missions', 'icon': LucideIcons.clipboardList},
        {'label': 'En cours', 'icon': LucideIcons.truck},
        {'label': 'Profil', 'icon': LucideIcons.user},
      ];
      pages = [
        MissionsPage(
          statutsFiltre: ['AFFECTEE'],
          title: 'Missions à accepter',
          cubit: _missionsCubit,
        ),
        MissionsPage(
          statutsFiltre: ['EN_COURS', 'ACCEPTEE'],
          title: 'En cours',
          cubit: _missionsCubit,
        ),
        const ProfilePage(),
      ];
    } else if (role == 'ADMIN' || role == 'SUPER_ADMIN') {
      navItems = [
        {'label': 'Dashboard', 'icon': LucideIcons.layoutDashboard},
        {'label': 'Utilisateurs', 'icon': LucideIcons.users},
        {'label': 'Commandes', 'icon': LucideIcons.package},
        {'label': 'Profil', 'icon': LucideIcons.user},
      ];
      pages = [
        const DashboardAdminPage(),
        const GestionUtilisateursPage(),
        const GestionCommandesPage(),
        const ProfilePage(),
      ];
    } else {
      // Client
      navItems = [
        {'label': 'Accueil', 'icon': LucideIcons.home},
        {'label': 'Commandes', 'icon': LucideIcons.package},
        {'label': 'Historique', 'icon': LucideIcons.clock},
        {'label': 'Profil', 'icon': LucideIcons.user},
      ];
      pages = [
        const DashboardPage(),
        CommandesPage(statutsFiltre: null, title: 'Mes commandes'),
        CommandesPage(statutsFiltre: ['LIVREE', 'ANNULEE'], title: 'Historique'),
        const ProfilePage(),
      ];
    }

    // Sécurité : si l'index est hors limites, on le corrige
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    // Log pour déboguer
    print('🔵 Index: $_currentIndex, Page: ${pages[_currentIndex].runtimeType}');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        items: navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}