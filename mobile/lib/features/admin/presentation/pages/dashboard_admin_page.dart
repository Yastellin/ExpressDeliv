import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/admin_cubit.dart';
import '../../data/models/dashboard_stats.dart'; // ✅ Import du modèle DashboardStats

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  late AdminCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AdminCubit();
    _cubit.chargerStats();
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Dashboard Admin',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Statistiques globales du système',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: BlocConsumer<AdminCubit, AdminState>(
                    listener: (context, state) {
                      if (state is AdminError) {
                        CustomSnackBar.showError(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return _buildShimmer();
                      } else if (state is AdminStatsSuccess) {
                        return _buildStatsGrid(state.stats);
                      } else if (state is AdminError) {
                        return _buildError(state.message);
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

  Widget _buildShimmer() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
      )),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    final items = [
      {'label': 'Commandes totales', 'value': stats.commandes.total_commandes, 'icon': LucideIcons.package},
      {'label': 'Livraisons totales', 'value': stats.livraisons.total_livraisons, 'icon': LucideIcons.truck},
      {'label': 'En cours', 'value': stats.livraisons.livraisons_en_cours, 'icon': LucideIcons.clock},
      {'label': 'Livraisons réussies', 'value': stats.livraisons.livraisons_reussies, 'icon': LucideIcons.checkCircle},
      {'label': 'Échec', 'value': stats.livraisons.livraisons_echouees, 'icon': LucideIcons.alertCircle},
      {'label': 'Clients', 'value': stats.utilisateurs.total_clients, 'icon': LucideIcons.users},
      {'label': 'Livreurs', 'value': stats.utilisateurs.total_livreurs, 'icon': LucideIcons.userCheck},
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, size: 28, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                '${item['value']}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                item['label'] as String,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Erreur de chargement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Réessayer',
            onPressed: () => _cubit.chargerStats(),
          ),
        ],
      ),
    );
  }
}