import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/missions_cubit.dart';

class PreuvePage extends StatefulWidget {
  final String livraisonId;

  const PreuvePage({super.key, required this.livraisonId});

  @override
  State<PreuvePage> createState() => _PreuvePageState();
}

class _PreuvePageState extends State<PreuvePage> {
  final _pinController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  Uint8List? _imageBytes; // ✅ Stocker les bytes pour Image.memory
  bool _isSubmitting = false;
  String? _imageName;

  @override
  void dispose() {
    _pinController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  // Sélection de l'image (caméra ou galerie)
Future<void> _pickImage(ImageSource source) async {
  print('[PreuvePage] Sélection d\'image depuis $source');
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
    print('[PreuvePage] Fichier sélectionné : ${pickedFile.path}');
    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageName = pickedFile.name;
    });
    print(' [PreuvePage] Image chargée (${bytes.length} bytes)');
  } else {
    print('[PreuvePage] Aucune image sélectionnée');
  }
}

  Future<void> _submit() async {
    print('📤 [PreuvePage] Tentative de soumission...');
    if (_imageBytes == null) {
      CustomSnackBar.showError(context, 'Veuillez prendre une photo');
      return;
    }

    final pngBytes = await _signatureController.toPngBytes();
    if (pngBytes == null) {
      CustomSnackBar.showError(context, 'Veuillez signer');
      return;
    }

    // Encodage en base64
    final imageBase64 = base64Encode(_imageBytes!);
    final signatureBase64 = base64Encode(pngBytes);
    final pin = _pinController.text.trim();

    // Préparer les données selon le schéma du backend
    // Type : on peut mettre PHOTO par défaut ou détecter selon ce qui est fourni
    // Ici on envoie tout, le backend validera les champs nécessaires
    final preuveData = {
      'type': 'PHOTO', // Valeur par défaut
      'photo': imageBase64,
      'signature': signatureBase64,
      'pin_code': pin,
    };

    print('📤 [PreuvePage] Données envoyées : type=${preuveData['type']}, pin_code=${preuveData['pin_code']}, photo length=${imageBase64.length}, signature length=${signatureBase64.length}');

    setState(() => _isSubmitting = true);
    try {
      await context.read<MissionsCubit>().soumettrePreuve(widget.livraisonId, preuveData);
      CustomSnackBar.showSuccess(context, 'Livraison terminée !');
      Navigator.pop(context, true);
    } catch (e) {
      print('❌ [PreuvePage] Erreur lors de la soumission : $e');
      CustomSnackBar.showError(context, e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preuve de livraison'),
        backgroundColor: AppColors.card,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Photo ---
            Text('Photo du colis', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              onLongPress: () => _pickImage(ImageSource.gallery), // Long press pour galerie
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover), // ✅ Image.memory
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.camera, size: 40, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          Text('Appuyez pour prendre une photo', style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('(appui long pour galerie)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            if (_imageName != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Fichier : $_imageName', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: AppSpacing.md),

            // --- Signature ---
            Text('Signature', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: AppColors.inputBackground,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    _signatureController.clear();
                    print('🔄 [PreuvePage] Signature effacée');
                  },
                  icon: Icon(Icons.clear, size: 16),
                  label: Text('Effacer'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // --- Code PIN ---
            CustomTextField(
              label: 'Code PIN (optionnel)',
              hint: 'Code communiqué par le client',
              controller: _pinController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),

            PrimaryButton(
              label: _isSubmitting ? 'Envoi en cours...' : 'Valider la livraison',
              isLoading: _isSubmitting,
              isEnabled: !_isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}