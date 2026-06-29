import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/admin_cubit.dart';
import '../../../auth/data/models/auth_request.dart';
import '../../../../core/widgets/custom_text_field.dart';

class GestionUtilisateursPage extends StatefulWidget {
  const GestionUtilisateursPage({super.key});

  @override
  State<GestionUtilisateursPage> createState() =>
      _GestionUtilisateursPageState();
}

class _GestionUtilisateursPageState extends State<GestionUtilisateursPage> {
  late AdminCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AdminCubit();
    _cubit.chargerUsers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showCreateUserDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'LIVREUR';

    showDialog(
      context: context,
      builder: (dialogContext) {
        // État local pour l'affichage du mot de passe
        bool obscurePassword = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Créer un utilisateur'),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Nom',
                          controller: nomCtrl,
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Prénom',
                          controller: prenomCtrl,
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Email',
                          controller: emailCtrl,
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Téléphone',
                          controller: telCtrl,
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Mot de passe',
                          controller: passCtrl,
                          obscureText: obscurePassword, // ✅ lié à l'état local
                          validator: (v) =>
                              (v == null || v.length < 8) ? 'Min 8 caractères' : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          items: const [
                            DropdownMenuItem(value: 'LIVREUR', child: Text('Livreur')),
                            DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                            DropdownMenuItem(value: 'CLIENT', child: Text('Client')),
                          ],
                          onChanged: (v) => setState(() => selectedRole = v!),
                          decoration: const InputDecoration(labelText: 'Rôle'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext);
                      try {
                        await _cubit.createUserByAdmin(
                          nomCtrl.text,
                          prenomCtrl.text,
                          emailCtrl.text,
                          telCtrl.text,
                          passCtrl.text,
                          selectedRole,
                        );
                        CustomSnackBar.showSuccess(context, 'Utilisateur créé avec succès');
                        _cubit.chargerUsers(); // Recharger la liste
                      } catch (e) {
                        CustomSnackBar.showError(context, e.toString());
                      }
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
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
                  'Gestion des utilisateurs',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Activez ou désactivez les comptes',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary));
                      } else if (state is AdminUsersSuccess) {
                        final users = state.users;
                        if (users.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return _buildUserCard(user);
                          },
                        );
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.tertiary,
          onPressed: () => _showCreateUserDialog(context),
          child: const Icon(LucideIcons.plus),
        ),
      ),
    );
  }

  Widget _buildUserCard(UserDto user) {
    final isActive = user.statut == 'ACTIF';
    final fullName = '${user.prenom} ${user.nom}'.trim();
    final email = user.email;
    final role = user.role;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? LucideIcons.userCheck : LucideIcons.userX,
              color: isActive ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : 'Utilisateur',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                Text(email,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : user.statut == 'SUSPENDU'
                                ? AppColors.warning.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive
                            ? 'ACTIF'
                            : user.statut == 'SUSPENDU'
                                ? 'SUSPENDU'
                                : 'INACTIF',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? AppColors.success
                              : user.statut == 'SUSPENDU'
                                  ? AppColors.warning
                                  : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (role != 'SUPER_ADMIN') _ToggleButton(user: user, cubit: _cubit),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users, size: 48, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun utilisateur',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Aucun compte n\'a été trouvé.',
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
          Text('Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(message, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => _cubit.chargerUsers(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ─── Widget séparé pour le bouton avec état local ───
class _ToggleButton extends StatefulWidget {
  final UserDto user;
  final AdminCubit cubit;

  const _ToggleButton({required this.user, required this.cubit});

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.user.statut == 'ACTIF';
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await widget.cubit.toggleUserStatus(
                    widget.user.id, widget.user.statut ?? 'ACTIF');
                // Le Cubit recharge la liste, donc ce widget sera recréé avec _isLoading = false
              } catch (e) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.error : AppColors.success,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(80, 36),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(isActive ? 'Désactiver' : 'Activer'),
    );
  }
}
