import 'package:freezed_annotation/freezed_annotation.dart';

part 'commande.freezed.dart';
part 'commande.g.dart';

@freezed
class Commande with _$Commande {
  const factory Commande({
    required String id,
    required String statut,
    required String adresse_livraison,
    required String montant_total,
    required DateTime created_at,
    DateTime? updated_at,
    String? notes,
    String? client_nom,
    String? client_prenom,
    String? livraisonId,
    @Default([]) List<Colis> colis,
  }) = _Commande;

  factory Commande.fromJson(Map<String, dynamic> json) =>
      _$CommandeFromJson(json);
}

@freezed
class Colis with _$Colis {
  const factory Colis({
    required String id,
    required String description,
    required String poids,
    required String prix_unitaire,
    @Default('1') String quantite, // ✅ valeur par défaut si absent
    String? dimensions,
    bool? fragile,
    DateTime? created_at, // ✅ optionnel
  }) = _Colis;

  factory Colis.fromJson(Map<String, dynamic> json) => _$ColisFromJson(json);
}