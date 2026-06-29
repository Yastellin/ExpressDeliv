import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0.5,
        title: const Text('Créer un compte'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
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
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v ?? '')) ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomTextField(
                    label: 'Téléphone',
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.length < 8) ? 'Téléphone invalide' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomTextField(
                    label: 'Mot de passe',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (v) => (v == null || v.length < 8) ? 'Min 8 caractères' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: _isLoading ? 'Inscription...' : 'S\'inscrire',
                    isLoading: _isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        try {
                          await context.read<AuthCubit>().register(
                            _nomController.text,
                            _prenomController.text,
                            _emailController.text,
                            _telephoneController.text,
                            _passwordController.text,
                            'CLIENT', // Rôle par défaut
                          );
                          if (mounted) {
                            CustomSnackBar.showSuccess(context, 'Compte créé ! Connectez-vous.');
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          CustomSnackBar.showError(context, e.toString());
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Déjà un compte ? Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}