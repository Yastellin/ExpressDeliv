import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SingleChildScrollView( // ✅ Empêche le débordement
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Mon profil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (authState is AuthSuccess) ...[
                  // --- Carte d'information ---
                  Card(
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.user,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${authState.user.prenom} ${authState.user.nom}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      authState.user.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  authState.user.role,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // --- Formulaire d'édition ---
                  if (_isEditing) ...[
                    CustomTextField(
                      label: 'Nom',
                      controller: _nomController,
                      validator: (v) => (v == null || v.length < 2) ? 'Nom invalide' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CustomTextField(
                      label: 'Prénom',
                      controller: _prenomController,
                      validator: (v) => (v == null || v.length < 2) ? 'Prénom invalide' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CustomTextField(
                      label: 'Téléphone',
                      hint: '034 56 789 01',
                      controller: _telephoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Téléphone requis';
                        }
                        if (value.length < 8) {
                          return 'Min 8 chiffres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CustomTextField(
                      label: 'Adresse par défaut',
                      hint: 'Ex: 123 Rue de Paris, 75001 Paris',
                      controller: _adresseController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Adresse requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Enregistrer',
                            onPressed: _saveProfile,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Annuler',
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _clearControllers();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // --- Affichage des infos ---
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(LucideIcons.user, 'Nom', authState.user.nom),
                          const Divider(color: AppColors.border),
                          _buildInfoRow(LucideIcons.user, 'Prénom', authState.user.prenom),
                          const Divider(color: AppColors.border),
                          _buildInfoRow(LucideIcons.phone, 'Téléphone', authState.user.telephone ?? 'Non renseigné'),
                          const Divider(color: AppColors.border),
                          _buildInfoRow(LucideIcons.mapPin, 'Adresse', authState.user.adresse_defaut ?? 'Non renseignée'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: 'Modifier mes informations',
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          _nomController.text = authState.user.nom;
                          _prenomController.text = authState.user.prenom;
                          _telephoneController.text = authState.user.telephone ?? '';
                          _adresseController.text = authState.user.adresse_defaut ?? '';
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Se déconnecter',
                    onPressed: _showLogoutDialog,
                  ),
                ],
                const SizedBox(height: AppSpacing.md), // Espacement supplémentaire en bas
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    final context = this.context;

    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final telephone = _telephoneController.text.trim();
    final adresse = _adresseController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || telephone.isEmpty || adresse.isEmpty) {
      CustomSnackBar.showError(context, 'Veuillez remplir tous les champs');
      return;
    }

    final cubit = context.read<AuthCubit>();
    try {
      await cubit.updateProfile({
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'adresse_defaut': adresse,
      });
      setState(() {
        _isEditing = false;
        _clearControllers();
      });
      CustomSnackBar.showSuccess(context, 'Profil mis à jour avec succès');
    } catch (e) {
      CustomSnackBar.showError(context, e.toString());
    }
  }

  void _clearControllers() {
    _nomController.clear();
    _prenomController.clear();
    _telephoneController.clear();
    _adresseController.clear();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}