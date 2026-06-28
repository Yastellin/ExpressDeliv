import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import './commandes_cubit.dart';
import '../widgets/commande_card.dart';
import './commande_detail_page.dart';
import '../../data/models/commande.dart';

class CommandesPage extends StatefulWidget {
  final List<String>? statutsFiltre;
  final String title;

  const CommandesPage({
    super.key,
    this.statutsFiltre,
    this.title = 'Mes commandes',
  });

  @override
  State<CommandesPage> createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> {
  late CommandesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CommandesCubit();
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Consultez vos commandes',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: BlocConsumer<CommandesCubit, CommandesState>(
                    listener: (context, state) {
                      if (state is CommandesError) {
                        CustomSnackBar.showError(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is CommandesLoading) {
                        return _buildShimmer();
                      } else if (state is CommandesSuccess) {
                        final commandes = state.commandes;
                        // Filtrer selon les statuts demandés
                        List<Commande> commandesFiltrees = commandes;
                        if (widget.statutsFiltre != null && widget.statutsFiltre!.isNotEmpty) {
                          commandesFiltrees = commandes
                              .where((c) => widget.statutsFiltre!.contains(c.statut))
                              .toList();
                        }
                        if (commandesFiltrees.isEmpty) {
                          return _buildEmptyState();
                        }
                        return _buildList(commandesFiltrees);
                      } else if (state is CommandesEmpty) {
                        return _buildEmptyState();
                      } else if (state is CommandesError) {
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

  Widget _buildShimmer() {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100, height: 16, color: AppColors.border),
            const SizedBox(height: 8),
            Container(width: double.infinity, height: 12, color: AppColors.border),
            Container(width: 200, height: 12, color: AppColors.border),
            const Spacer(),
            Container(width: 60, height: 8, color: AppColors.border),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Commande> commandes) {
    return RefreshIndicator(
      onRefresh: () => _cubit.chargerCommandes(),
      child: ListView.separated(
        itemCount: commandes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final commande = commandes[index];
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
                _cubit.chargerCommandes();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.package, size: 64, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune commande',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.statutsFiltre?.contains('LIVREE') == true
                ? 'Vous n\'avez pas encore de commandes terminées.'
                : 'Vous n\'avez pas encore passé de commande.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

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
          Text(message, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Réessayer',
            onPressed: () => _cubit.chargerCommandes(),
          ),
        ],
      ),
    );
  }
}