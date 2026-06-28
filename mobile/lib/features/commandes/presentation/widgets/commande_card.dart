import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../livraisons/presentation/pages/suivi_carte_page.dart';
import '../../data/models/commande.dart';

class CommandeCard extends StatelessWidget {
  final Commande commande;
  final VoidCallback? onTap;

  const CommandeCard({super.key, required this.commande, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppColors.textSecondary;
    String statusText = commande.statut;

    switch (commande.statut) {
      case 'LIVREE':
        statusColor = AppColors.success;
        break;
      case 'ANNULEE':
        statusColor = AppColors.error;
        break;
      case 'LIVRAISON_EN_COURS':
      case 'EN_COURS':
        statusColor = AppColors.primary;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    final nbColis = commande.colis.length;

    return GestureDetector(
      onTap: onTap,
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
                        : commande.statut == 'LIVRAISON_EN_COURS' ||
                                commande.statut == 'EN_COURS'
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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
                          Icon(LucideIcons.calendar, size: 14,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${commande.created_at.day}/${commande.created_at.month}/${commande.created_at.year}',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(LucideIcons.box, size: 14,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '$nbColis article${nbColis > 1 ? 's' : ''}',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
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
            // --- Bouton "Suivre en direct" (si EN_COURS) ---
            if (commande.statut == 'EN_COURS' ||
                commande.statut == 'LIVRAISON_EN_COURS') ...[
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
}