import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/missions_cubit.dart';
import '../../data/models/livraison.dart'; //Import du modèle
import './preuve_page.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../livraisons/presentation/pages/chat_page.dart';
class MissionsPage extends StatefulWidget {
  final List<String>? statutsFiltre;
  final String title;
  final MissionsCubit? cubit;

  const MissionsPage({super.key, this.statutsFiltre, this.title = 'Mes Missions', this.cubit,});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  late MissionsCubit _cubit;
  bool _isOwner = false;

  @override
    void initState() {
      super.initState();
      if (widget.cubit != null) {
        _cubit = widget.cubit!;
        _isOwner = false;
      } else {
        _cubit = MissionsCubit();
        _cubit.chargerMissions();
        _isOwner = true;
      }
    }

    @override
    void dispose() {
      if (_isOwner) {
        _cubit.close();
      }
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
                Text(
                  'Consultez les livraisons qui vous sont assignées',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: BlocConsumer<MissionsCubit, MissionsState>(
                    listener: (context, state) {
                      if (state is MissionsError) {
                        CustomSnackBar.showError(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      if (state is MissionsLoading) {
                        return _buildShimmer();
                      } else if (state is MissionsSuccess) {
                        return _buildList(state.missions, context, state);
                      } else if (state is MissionsEmpty) {
                        return _buildEmptyState();
                      } else if (state is MissionsError) {
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
        height: 140,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(width: 80, height: 32, color: AppColors.border),
                const SizedBox(width: 8),
                Container(width: 80, height: 32, color: AppColors.border),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // On reçoit le state pour gérer l'action en cours
  Widget _buildList(List<Livraison> missions, BuildContext context, MissionsState currentState) {
    // Filtrer selon les statuts demandés
    List<Livraison> missionsFiltrees = missions;
    if (widget.statutsFiltre != null && widget.statutsFiltre!.isNotEmpty) {
      missionsFiltrees = missions.where((m) => widget.statutsFiltre!.contains(m.statut)).toList();
    }

    // Si après filtrage il n'y a rien
    if (missionsFiltrees.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _cubit.chargerMissions(),
      child: ListView.separated(
        itemCount: missionsFiltrees.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final mission = missionsFiltrees[index];
          return _buildMissionCard(mission, context, currentState);
        },
      ),
    );
  }

  Widget _buildMissionCard(Livraison mission, BuildContext context, MissionsState currentState) {
    // Couleur selon le statut
    Color statusColor = AppColors.textSecondary;
    switch (mission.statut) {
      case 'AFFECTEE':
        statusColor = AppColors.textSecondary;
        break;
      case 'ACCEPTEE':
        statusColor = AppColors.primary;
        break;
      case 'EN_COURS':
        statusColor = AppColors.primary;
        break;
      case 'LIVREE':
        statusColor = AppColors.success;
        break;
      case 'ECHEC':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    final isPending = mission.statut == 'AFFECTEE';
    final isActionLoading = currentState is MissionActionLoading && currentState.missionId == mission.id;

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
                'Commande #${mission.id.substring(0, 8)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
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
                  mission.statut,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
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
                  mission.adresse_livraison,
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
                '${mission.client_prenom ?? ''} ${mission.client_nom ?? ''}',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${double.parse(mission.montant_total).toStringAsFixed(0)} Ar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: isActionLoading ? '...' : 'Accepter',
                    isLoading: isActionLoading,
                    isEnabled: !isActionLoading,
                    onPressed: isActionLoading ? null : () => _cubit.accepterMission(mission.id),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: PrimaryButton(
                    label: isActionLoading ? '...' : 'Refuser',
                    isLoading: false,
                    isEnabled: !isActionLoading,
                    onPressed: isActionLoading ? null : () {
                      _showRefusDialog(context, mission.id);
                    },
                  ),
                ),
              ],
            ),
          ],
          if (mission.statut == 'EN_COURS' || mission.statut == 'ACCEPTEE') ...[
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: 'Terminer la livraison',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreuvePage(livraisonId: mission.id),
                  ),
                );
              },
            ),

                        // --- Bouton Chat ---
            if (mission.statut == 'EN_COURS')
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: PrimaryButton(
                  label: 'Chat avec le client',
                  onPressed: () {
                    print('[MissionsPage] ouverture chat pour livraison ${mission.id}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          livraisonId: mission.id,
                          currentUserId: (context.read<AuthCubit>().state as AuthSuccess).user.id,
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (mission.statut == 'ACCEPTEE') ...[
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Démarrer le suivi (GPS)',
                onPressed: () async {
                  // Mettre à jour le statut de la livraison vers EN_COURS
                  await _cubit.updateStatut(mission.id, 'EN_COURS');
                  // Démarrer l'envoi de la position GPS
                  await _cubit.startTracking(mission.id);
                  // Recharger les missions pour mettre à jour l'affichage
                  await _cubit.chargerMissions();
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.clipboardList, size: 64, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune mission',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Vous n\'avez pas encore de livraison assignée.',
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Réessayer',
            onPressed: () => _cubit.chargerMissions(),
          ),
        ],
      ),
    );
  }

  void _showRefusDialog(BuildContext context, String missionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la mission'),
        content: const Text('Voulez-vous vraiment refuser cette livraison ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.refuserMission(missionId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }
}