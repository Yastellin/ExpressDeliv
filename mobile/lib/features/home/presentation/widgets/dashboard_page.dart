import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../commandes/presentation/bloc/dashboard_cubit.dart';
import '../../../commandes/data/repositories/commande_repository_impl.dart';
import '../../../commandes/data/models/commande.dart';
import '../../../commandes/presentation/pages/create_order_page.dart';
import '../../../commandes/presentation/pages/commande_detail_page.dart';
import '../../../commandes/presentation/widgets/commande_card.dart'; // Ajout en haut

// ... puis dans la classe :
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    final repository = CommandeRepositoryImpl();
    _cubit = DashboardCubit(repository);
    _cubit.chargerCommandes();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- EN-TÊTE ---
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour 👋',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Suivez vos livraisons en temps réel',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateOrderPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.plus, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Commande',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // --- CONTENU PRINCIPAL ---
                Expanded(
                  child: BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoading) {
                        return _buildShimmerList();
                      } else if (state is DashboardSuccess) {
                        return _buildCommandeList(state.commandes);
                      } else if (state is DashboardEmpty) {
                        return _buildEmptyState();
                      } else if (state is DashboardError) {
                        return _buildErrorState(state.message);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SHIMMER LOADING (Respect des règles : multiples de 8) ---
  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 100, height: 16, color: Colors.white),
                  Container(width: 60, height: 16, color: Colors.white),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(width: double.infinity, height: 12, color: Colors.white),
              const SizedBox(height: AppSpacing.xs),
              Container(width: 80, height: 12, color: Colors.white),
              const Spacer(),
              Container(width: 60, height: 8, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // --- LISTE DES COMMANDES ---
  Widget _buildCommandeList(List<Commande> commandes) {
    return RefreshIndicator(
      onRefresh: () => _cubit.chargerCommandes(),
      child: ListView.separated(
        itemCount: commandes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final commande = commandes[index];
          return _buildCommandeCard(commande);
        },
      ),
    );
  }

  // --- CARTE INDIVIDUELLE (Radius 16, padding 16, couleurs strictes) ---
Widget _buildCommandeCard(Commande commande) {
  return CommandeCard(
    commande: commande,
    onTap: () async {
      final shouldRefresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommandeDetailPage(commandeId: commande.id),
        ),
      );
      if (shouldRefresh == true) {
        context.read<DashboardCubit>().chargerCommandes();
      }
    },
  );
}
  // --- ETAT VIDE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingBag, size: 64, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune commande',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Vous n\'avez pas encore passé de commande.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Explorer les produits',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // --- ETAT ERREUR ---
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () => _cubit.chargerCommandes(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.refreshCw, color: Colors.white, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  const Text(
                    'Réessayer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}