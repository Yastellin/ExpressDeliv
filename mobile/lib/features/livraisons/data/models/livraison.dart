import 'package:freezed_annotation/freezed_annotation.dart';

part 'livraison.freezed.dart';
part 'livraison.g.dart';

@freezed
class Livraison with _$Livraison {
  const factory Livraison({
    required String id,
    required String statut, // AFFECTEE, ACCEPTEE, EN_COURS, LIVREE, ECHEC
    required int tentatives,
    required DateTime date_affectation,
    DateTime? date_debut,
    DateTime? date_fin,
    required DateTime created_at,
    DateTime? updated_at,
    required String adresse_livraison,
    required String montant_total,
    String? client_nom,
    String? client_prenom,
    String? livreur_nom,
    String? livreur_prenom,
  }) = _Livraison;

  factory Livraison.fromJson(Map<String, dynamic> json) =>
      _$LivraisonFromJson(json);
}