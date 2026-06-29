import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../../../commandes/data/models/commande.dart';

class AdminCreateOrderPage extends StatefulWidget {
  const AdminCreateOrderPage({super.key});

  @override
  State<AdminCreateOrderPage> createState() => _AdminCreateOrderPageState();
}

class _AdminCreateOrderPageState extends State<AdminCreateOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Client ---
  final _clientEmailController = TextEditingController();
  String? _clientId;
  String? _clientNom;
  bool _clientFound = false;

  // --- Expéditeur ---
  final _expediteurNomController = TextEditingController();
  final _expediteurPrenomController = TextEditingController();
  final _expediteurTelController = TextEditingController();

  // --- Adresse & colis ---
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _poidsController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();

  final List<Map<String, dynamic>> _colisList = [];
  bool _isAddingColis = false;
  bool _isLoading = false;

  Future<void> _searchClient() async {
    final email = _clientEmailController.text.trim();
    if (email.isEmpty) {
      CustomSnackBar.showError(context, 'Veuillez saisir un email');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = DioClient.instance;
      // Filtrer par rôle CLIENT
      print('📤 [Search] Envoi de la requête /users?email=$email&role=CLIENT');
      final response = await dio.get('/users?email=$email&role=CLIENT');
      print('📥 [Search] Réponse brute : ${response.data}');
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final list = data['data'] as List;
        if (list.isNotEmpty) {
          final user = list.first as Map<String, dynamic>;
          _clientId = user['id'];
          _clientNom = '${user['prenom']} ${user['nom']}';
          _clientFound = true;
          CustomSnackBar.showSuccess(context, 'Client trouvé : $_clientNom');
        } else {
          _clientFound = false;
          CustomSnackBar.showError(context, 'Aucun client trouvé avec cet email');
        }
      }
    } catch (e) {
      CustomSnackBar.showError(context, 'Erreur de recherche');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addColis() {
    final desc = _descriptionController.text.trim();
    final poids = double.tryParse(_poidsController.text.trim().replaceAll(',', '.'));
    final quantite = int.tryParse(_quantiteController.text.trim());
    final prix = double.tryParse(_prixController.text.trim().replaceAll(',', '.'));

    if (desc.isEmpty || poids == null || quantite == null || prix == null) {
      CustomSnackBar.showError(context, 'Veuillez remplir correctement tous les champs du colis');
      return;
    }
    setState(() {
      _colisList.add({
        'description': desc,
        'poids': poids,
        'quantite': quantite,
        'prix_unitaire': prix,
      });
      _isAddingColis = false;
      _descriptionController.clear();
      _poidsController.clear();
      _quantiteController.clear();
      _prixController.clear();
    });
  }

  Future<void> _submitOrder() async {
  // Vérifications
  final clientId = _clientId;
  final clientNom = _clientNom;
  if (clientId == null || !_clientFound) {
    CustomSnackBar.showError(context, 'Veuillez rechercher un client valide');
    return;
  }

  final adresse = _adresseController.text.trim();
  if (adresse.isEmpty) {
    CustomSnackBar.showError(context, 'Adresse de livraison requise');
    return;
  }
  if (_colisList.isEmpty) {
    CustomSnackBar.showError(context, 'Ajoutez au moins un colis');
    return;
  }

  final expediteurNom = _expediteurNomController.text.trim();
  final expediteurPrenom = _expediteurPrenomController.text.trim();
  final expediteurTel = _expediteurTelController.text.trim();
  if (expediteurNom.isEmpty || expediteurPrenom.isEmpty || expediteurTel.isEmpty) {
    CustomSnackBar.showError(context, 'Veuillez remplir les informations de l\'expéditeur');
    return;
  }

  //  Construire les données complètes
  final data = {
    'adresse_livraison': adresse,
    'expediteur_nom': expediteurNom,
    'expediteur_prenom': expediteurPrenom,
    'expediteur_telephone': expediteurTel,
    'colis': _colisList,
    'client_id': clientId,
  };
  print('[AdminCreateOrder] Données envoyées : $data');
  setState(() => _isLoading = true);
  try {
    final dio = DioClient.instance;
    final response = await dio.post('/commandes', data: data);
    final responseData = response.data;

    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final commande = Commande.fromJson(responseData['data'] as Map<String, dynamic>);
      CustomSnackBar.showSuccess(
        context,
        'Commande #${commande.id.substring(0, 8)} créée pour $clientNom !',
      );
      Navigator.pop(context, true);
    } else {
      throw Exception('Format de réponse inattendu');
    }
  } on DioException catch (e) {
  String errorMsg = 'Erreur lors de la création';
  if (e.response?.data != null) {
    final data = e.response?.data as Map<String, dynamic>?;
    if (data != null && data.containsKey('error')) {
      final error = data['error'] as Map<String, dynamic>?;
      if (error != null) {
        // Si le backend renvoie un message direct
        if (error.containsKey('message')) {
          errorMsg = error['message'] as String;
        }
        // Si le backend renvoie une liste de détails (comme pour 422)
        if (error.containsKey('details') && error['details'] is List) {
          final details = error['details'] as List;
          if (details.isNotEmpty) {
            final first = details.first as Map<String, dynamic>;
            errorMsg = '${first['field']} : ${first['message']}';
          }
        }
      }
    } else if (data != null && data.containsKey('message')) {
      errorMsg = data['message'] as String;
    }
  }
  CustomSnackBar.showError(context, errorMsg);
  }catch (e) {
    CustomSnackBar.showError(context, 'Erreur inattendue : $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer une commande (Admin)'),
        backgroundColor: AppColors.card,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Recherche client ---
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Email du client',
                          controller: _clientEmailController,
                          validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _searchClient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(80, 48),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Rechercher'),
                      ),
                    ],
                  ),
                  if (_clientFound) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.checkCircle, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text('Client : $_clientNom', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  // --- Expéditeur ---
                  Text('Informations de l\'expéditeur', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Nom de l\'expéditeur',
                    controller: _expediteurNomController,
                    validator: (v) => v == null || v.length < 2 ? 'Nom invalide' : null,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Prénom de l\'expéditeur',
                    controller: _expediteurPrenomController,
                    validator: (v) => v == null || v.length < 2 ? 'Prénom invalide' : null,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Téléphone de l\'expéditeur',
                    controller: _expediteurTelController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.length < 8 ? 'Téléphone invalide' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // --- Adresse ---
                  CustomTextField(
                    label: 'Adresse de livraison',
                    controller: _adresseController,
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // --- Section colis ---
                  Row(
                    children: [
                      Text('Colis (${_colisList.length})', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const Spacer(),
                      if (!_isAddingColis)
                        GestureDetector(
                          onTap: () => setState(() => _isAddingColis = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                Icon(LucideIcons.plus, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ---- Formulaire d'ajout ----
                  if (_isAddingColis)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                      child: Column(
                        children: [
                          CustomTextField(label: 'Description', controller: _descriptionController),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: CustomTextField(label: 'Poids (kg)', controller: _poidsController, keyboardType: TextInputType.numberWithOptions(decimal: true))),
                              const SizedBox(width: 8),
                              Expanded(child: CustomTextField(label: 'Quantité', controller: _quantiteController, keyboardType: TextInputType.number)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(label: 'Prix unitaire (Ar)', controller: _prixController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: PrimaryButton(label: 'Ajouter', onPressed: _addColis)),
                              const SizedBox(width: 8),
                              Expanded(child: PrimaryButton(label: 'Annuler', onPressed: () => setState(() { _isAddingColis = false; _descriptionController.clear(); _poidsController.clear(); _quantiteController.clear(); _prixController.clear(); }))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // ---- Liste des colis ajoutés ----
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _colisList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _colisList[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Row(
                          children: [
                            Icon(LucideIcons.package, size: 24, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['description'], style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text('${item['quantite']} x ${item['prix_unitaire']} Ar', style: TextStyle(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
                              onPressed: () => setState(() => _colisList.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ---- Valider ----
                  PrimaryButton(
                    label: _isLoading ? 'Création...' : 'Créer la commande',
                    isLoading: _isLoading,
                    isEnabled: !_isLoading && _clientFound,
                    onPressed: _submitOrder,
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