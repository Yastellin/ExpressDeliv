import '../../data/models/livraison.dart';

abstract class LivraisonRepository {
  Future<List<Livraison>> getMesMissions();
  Future<void> accepterMission(String id);
  Future<void> refuserMission(String id);
  Future<void> mettreAJourStatut(String id, String statut);
  Future<void> soumettrePreuve(String livraisonId, Map<String, dynamic> preuveData); // <-- AJOUT
}