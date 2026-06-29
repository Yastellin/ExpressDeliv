import '../../data/models/dashboard_stats.dart';
import '../../../auth/data/models/auth_request.dart';
import '../../../commandes/data/models/commande.dart';

abstract class AdminRepository {
  Future<DashboardStats> getStats();
  Future<List<UserDto>> getUsers();
  Future<void> toggleUserStatus(String userId, String statut);
  
  // ═══ NOUVEAUTÉS ═══
  Future<List<Commande>> getPendingOrders(); // Commandes en attente
  Future<List<UserDto>> getLivreurs();       // Livreurs actifs
  Future<void> assignerLivraison(String commandeId, String livreurId);
  Future<void> createUserByAdmin(String nom, String prenom, String email, String telephone, String password, String role);
}