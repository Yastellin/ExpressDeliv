import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/create_order_cubit.dart';
import '../../../home/presentation/pages/home_page.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _poidsController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();

  final List<Map<String, dynamic>> _colisList = [];
  bool _isAddingColis = false;

  @override
  void dispose() {
    _adresseController.dispose();
    _descriptionController.dispose();
    _poidsController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateOrderCubit(),
      child: BlocListener<CreateOrderCubit, CreateOrderState>(
        listener: (context, state) {
          if (state is CreateOrderSuccess) {
            CustomSnackBar.showSuccess(
              context,
              'Commande #${state.commande.id.substring(0, 8)} créée avec succès !',
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          } else if (state is CreateOrderError) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.card,
            elevation: 0.5,
            title: const Text(
              'Nouvelle commande',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<CreateOrderCubit, CreateOrderState>(
            builder: (context, state) {
              final isLoading = state is CreateOrderLoading;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Adresse ---
                      CustomTextField(
                        label: 'Adresse de livraison',
                        hint: 'Ex: 123 Rue de Paris, 75001 Paris',
                        controller: _adresseController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'adresse est requise';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<CreateOrderCubit>().updateAdresse(value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // --- En-tête colis ---
                      Row(
                        children: [
                          Text(
                            'Colis (${_colisList.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (!_isAddingColis)
                            GestureDetector(
                              onTap: () => setState(() => _isAddingColis = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      LucideIcons.plus,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ajouter',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // --- Formulaire d'ajout de colis ---
                      if (_isAddingColis) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                label: 'Description',
                                hint: 'Ex: Smartphone',
                                controller: _descriptionController,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Poids (kg)',
                                      hint: '0.5',
                                      controller: _poidsController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: CustomTextField(
                                      label: 'Quantité',
                                      hint: '1',
                                      controller: _quantiteController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              CustomTextField(
                                label: 'Prix unitaire (Ar)',
                                hint: '699.99',
                                controller: _prixController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryButton(
                                      label: 'Ajouter',
                                      isEnabled: true,
                                      onPressed: _addColis,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: PrimaryButton(
                                      label: 'Annuler',
                                      isEnabled: true,
                                      onPressed: () {
                                        setState(() {
                                          _isAddingColis = false;
                                          _clearColisForm();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // --- Liste des colis ---
                      Expanded(
                        child: _colisList.isEmpty && !_isAddingColis
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.box,
                                      size: 48,
                                      color: AppColors.border,
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Aucun colis',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Ajoutez des articles à votre commande',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: _colisList.length,
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                                itemBuilder: (context, index) {
                                  final item = _colisList[index];
                                  return Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            LucideIcons.package,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['description'] ?? 'Sans description',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '${item['quantite']} x ${item['prix_unitaire']} Ar',
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _colisList.removeAt(index);
                                            });
                                          },
                                          child: const Icon(
                                            LucideIcons.trash2,
                                            color: AppColors.error,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      // --- Bouton Valider ---
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: isLoading ? 'Création en cours...' : 'Valider la commande',
                        isLoading: isLoading,
                        isEnabled: !isLoading && _colisList.isNotEmpty,
                        onPressed: () {
                          final adresse = _adresseController.text.trim();
                          if (adresse.isEmpty) {
                            CustomSnackBar.showError(
                              context,
                              'Veuillez saisir une adresse de livraison',
                            );
                            return;
                          }
                          if (_colisList.isEmpty) {
                            CustomSnackBar.showError(
                              context,
                              'Ajoutez au moins un colis',
                            );
                            return;
                          }
                          context.read<CreateOrderCubit>().submitOrder(
                                adresse,
                                _colisList,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _addColis() {
    final description = _descriptionController.text.trim();
    final poids = double.parse(_poidsController.text.trim());
    final quantite = int.parse(_quantiteController.text.trim());
    final prix = double.parse(_prixController.text.trim());

    if (description.isEmpty) {
      CustomSnackBar.showError(context, 'La description est requise');
      return;
    }
    if (poids <= 0) {
      CustomSnackBar.showError(context, 'Poids invalide');
      return;
    }
    if (quantite == null || quantite <= 0) {
      CustomSnackBar.showError(context, 'Quantité invalide');
      return;
    }
    if (prix == null || prix <= 0) {
      CustomSnackBar.showError(context, 'Prix unitaire invalide');
      return;
    }

    setState(() {
      _colisList.add({
        'description': description,
        'poids': poids,
        'quantite': quantite,
        'prix_unitaire': prix,
      });
      _isAddingColis = false;
      _clearColisForm();
    });

    CustomSnackBar.showSuccess(context, 'Colis ajouté !');
  }

  void _clearColisForm() {
    _descriptionController.clear();
    _poidsController.clear();
    _quantiteController.clear();
    _prixController.clear();
  }
}