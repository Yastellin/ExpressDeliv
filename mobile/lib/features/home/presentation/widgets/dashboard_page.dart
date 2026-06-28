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
import '../../../livraisons/presentation/pages/suivi_carte_page.dart';
import '../../../../core/widgets/primary_button.dart';

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
  Color statusColor = AppColors.textSecondary;
  String statusText = commande.statut;

  switch (commande.statut) {
    case 'LIVREE':
      statusColor = AppColors.success;
      break;
    case 'ANNULEE':
      statusColor = AppColors.error;
      break;
    case 'EN_COURS':
      statusColor = AppColors.primary;
      break;
    default:
      statusColor = AppColors.textSecondary;
  }

  final nbColis = commande.colis.length;

  return GestureDetector(
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
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Ligne supérieure : icône + détails ---
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  commande.statut == 'LIVREE'
                      ? LucideIcons.check
                      : commande.statut == 'EN_COURS'
                          ? LucideIcons.truck
                          : LucideIcons.package,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Commande #${commande.id.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${commande.created_at.day}/${commande.created_at.month}/${commande.created_at.year}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(LucideIcons.box, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '$nbColis article${nbColis > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${double.parse(commande.montant_total).toStringAsFixed(0)} Ar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // --- Bouton "Suivre en direct" (uniquement si statut = LIVRAISON_EN_COURS) ---
          if (commande.statut == 'EN_COURS') ...[
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: 'Suivre en direct',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SuiviCartePage(
                      livraisonId: commande.id,
                      adresseLivraison: commande.adresse_livraison,
                      initialLat: -18.8792,
                      initialLng: 47.5079,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    ),
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