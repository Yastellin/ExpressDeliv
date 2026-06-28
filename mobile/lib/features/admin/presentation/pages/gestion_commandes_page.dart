import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/admin_cubit.dart';
import '../../../commandes/data/models/commande.dart';
class GestionCommandesPage extends StatefulWidget {
  const GestionCommandesPage({super.key});

  @override
  State<GestionCommandesPage> createState() => _GestionCommandesPageState();
}

class _GestionCommandesPageState extends State<GestionCommandesPage> {
  late AdminCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AdminCubit();
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
                  'Affectation des livraisons',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Assignez une commande à un livreur',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: BlocConsumer<AdminCubit, AdminState>(
                    listener: (context, state) {
                      if (state is AdminError) {
                        CustomSnackBar.showError(context, state.message);
                      }
                      if (state is AdminAssignmentSuccess) {
                        CustomSnackBar.showSuccess(context, 'Livraison assignée avec succès !');
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminOrdersLoading || state is AdminLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      } else if (state is AdminOrdersSuccess) {
                        final commandes = state.commandes;
                        if (commandes.isEmpty) {
                          return _buildEmptyState();
                        }
                        // ✅ Passer l'état courant à la liste
                        return _buildOrderList(commandes, state);
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

  // ✅ Recevoir l'état courant en paramètre
  Widget _buildOrderList(List<Commande> commandes, AdminState currentState) {
    return ListView.separated(
      itemCount: commandes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final commande = commandes[index];
        // ✅ Passer l'état à la carte
        return _buildOrderCard(commande, currentState);
      },
    );
  }

  // ✅ Recevoir l'état courant en paramètre
  Widget _buildOrderCard(Commande commande, AdminState currentState) {
    // ✅ Utiliser l'état passé au lieu de context.watch
    final isAssigning = currentState is AdminAssignmentLoading &&
        currentState.commandeId == commande.id;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${commande.id.substring(0, 8)}',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  commande.statut,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  commande.adresse_livraison,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.user, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${commande.client_prenom ?? ''} ${commande.client_nom ?? ''}',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${double.parse(commande.montant_total).toStringAsFixed(0)} Ar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: isAssigning ? 'Assignation...' : 'Assigner à un livreur',
            isLoading: isAssigning,
            isEnabled: !isAssigning,
            onPressed: isAssigning ? null : () => _showAssignDialog(commande.id),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(String commandeId) {
    // Charger la liste des livreurs avant d'ouvrir le dialogue
    _cubit.chargerLivreurs();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // ✅ Fournir le cubit existant au dialogue
        return BlocProvider.value(
          value: _cubit,
          child: AlertDialog(
            title: const Text('Choisir un livreur'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: BlocConsumer<AdminCubit, AdminState>(
                listener: (context, state) {
                  if (state is AdminError) {
                    Navigator.pop(context);
                    CustomSnackBar.showError(context, state.message);
                  }
                  if (state is AdminAssignmentSuccess) {
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  // ✅ Ce contexte a accès au cubit via le BlocProvider.value
                  if (state is AdminDriversLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  } else if (state is AdminDriversSuccess) {
                    final livreurs = state.livreurs;
                    if (livreurs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.userX, size: 48, color: AppColors.error),
                            const SizedBox(height: AppSpacing.sm),
                            const Text('Aucun livreur disponible'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: livreurs.length,
                      itemBuilder: (context, index) {
                        final livreur = livreurs[index];
                        return ListTile(
                          leading: Icon(LucideIcons.user, color: AppColors.primary),
                          title: Text('${livreur.prenom} ${livreur.nom}'),
                          subtitle: Text(livreur.email),
                          onTap: () {
                            print('🚚 [UI] Livreur sélectionné : ${livreur.id}');
                            _cubit.assignerLivraison(commandeId, livreur.id);
                          },
                        );
                      },
                    );
                  } else if (state is AdminError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.alertCircle, size: 48, color: AppColors.error),
                          const SizedBox(height: AppSpacing.sm),
                          Text(state.message, textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('Chargement...'));
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                _cubit.chargerCommandes();
                },
                child: const Text('Annuler'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageCheck, size: 64, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune commande en attente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Toutes les commandes ont déjà été assignées.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
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
          Text(message, style: TextStyle(color: AppColors.textSecondary)),
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