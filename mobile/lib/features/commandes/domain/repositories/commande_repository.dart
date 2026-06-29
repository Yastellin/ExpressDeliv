import '../../data/models/commande.dart';

abstract class CommandeRepository {
  Future<List<Commande>> getMesCommandes();
  Future<Commande> createCommande(String adresse, List<Map<String, dynamic>> colis, {String? clientId});
  Future<Commande> getCommande(String id);
  Future<Commande> annulerCommande(String id);   // <-- AJOUT
}