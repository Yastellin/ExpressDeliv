import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_stats.dart';
import '../../../auth/data/models/auth_request.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../../commandes/data/models/commande.dart';

// ─── États ────────────────────────────────────────────────
abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminStatsSuccess extends AdminState {
  final DashboardStats stats;
  const AdminStatsSuccess(this.stats);
  @override
  List<Object?> get props => [stats];
}
class AdminUsersSuccess extends AdminState {
  final List<UserDto> users;
  const AdminUsersSuccess(this.users);
  @override
  List<Object?> get props => [users];
}
class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
class AdminUserToggleLoading extends AdminState {
  final String userId;
  const AdminUserToggleLoading(this.userId);
  @override
  List<Object?> get props => [userId];
}

// ─── Nouveaux États ────────────────────────────────────────
class AdminOrdersLoading extends AdminState {}
class AdminOrdersSuccess extends AdminState {
  final List<Commande> commandes;
  const AdminOrdersSuccess(this.commandes);
  @override
  List<Object?> get props => [commandes];
}

class AdminDriversLoading extends AdminState {}
class AdminDriversSuccess extends AdminState {
  final List<UserDto> livreurs;
  const AdminDriversSuccess(this.livreurs);
  @override
  List<Object?> get props => [livreurs];
}

class AdminAssignmentLoading extends AdminState {
  final String commandeId;
  const AdminAssignmentLoading(this.commandeId);
  @override
  List<Object?> get props => [commandeId];
}
class AdminAssignmentSuccess extends AdminState {}

// ─── Cubit ──────────────────────────────────────────────────
class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit() : _repository = AdminRepositoryImpl(), super(AdminInitial());

  Future<void> chargerStats() async {
    emit(AdminLoading());
    print('[AdminCubit] Chargement des stats');
    try {
      final stats = await _repository.getStats();
      emit(AdminStatsSuccess(stats));
      print('[AdminCubit] Stats chargées');
    } catch (e) {
      emit(AdminError(e.toString()));
      print('[AdminCubit] Erreur stats : $e');
    }
  }

  Future<void> chargerUsers() async {
    emit(AdminLoading());
    print('👥 [AdminCubit] Chargement des utilisateurs');
    try {
      final users = await _repository.getUsers();
      // ✅ S'assurer que la liste n'est jamais null
      
      print('📦 [AdminCubit] Utilisateurs reçus : ${users.length}');
      emit(AdminUsersSuccess(users));
    } catch (e) {
      print('❌ [AdminCubit] Erreur : $e');
      emit(AdminError(e.toString()));
    }
  }

  Future<void> toggleUserStatus(String userId, String statutActuel) async {
    final nouveauStatut = statutActuel == 'ACTIF' ? 'INACTIF' : 'ACTIF';
    print('🔄 [AdminCubit] Toggle utilisateur $userId de $statutActuel vers $nouveauStatut');
    emit(AdminUserToggleLoading(userId));
    try {
      await _repository.toggleUserStatus(userId, nouveauStatut);
      print('✅ [AdminCubit] Toggle réussi, rechargement des utilisateurs');
      await chargerUsers();
    } catch (e) {
      print('❌ [AdminCubit] Erreur toggle : $e');
      emit(AdminError(e.toString()));
    }
  }

  // ─── Méthodes du Cubit ─────────────────────────────────────

  Future<void> chargerCommandes() async {
    emit(AdminOrdersLoading());
    print('📋 [AdminCubit] Chargement des commandes');
    try {
      final commandes = await _repository.getPendingOrders();
      emit(AdminOrdersSuccess(commandes));
      print('✅ [AdminCubit] ${commandes.length} commandes chargées');
    } catch (e) {
      emit(AdminError(e.toString()));
      print('❌ [AdminCubit] Erreur chargement commandes : $e');
    }
  }

  Future<void> chargerLivreurs() async {
    emit(AdminDriversLoading());
    print('👥 [AdminCubit] Chargement des livreurs');
    try {
      final livreurs = await _repository.getLivreurs();
      emit(AdminDriversSuccess(livreurs));
      print('✅ [AdminCubit] ${livreurs.length} livreurs chargés');
    } catch (e) {
      emit(AdminError(e.toString()));
      print('❌ [AdminCubit] Erreur chargement livreurs : $e');
    }
  }

  Future<void> assignerLivraison(String commandeId, String livreurId) async {
    emit(AdminAssignmentLoading(commandeId));
    print('🚚 [AdminCubit] Assignation commande $commandeId à $livreurId');
    try {
      await _repository.assignerLivraison(commandeId, livreurId);
      emit(AdminAssignmentSuccess());
      // Recharger les commandes pour enlever celle qui vient d'être assignée
      await chargerCommandes();
      print('✅ [AdminCubit] Assignation réussie, commandes rechargées');
    } catch (e) {
      emit(AdminError(e.toString()));
      print('❌ [AdminCubit] Erreur assignation : $e');
    }
  }

  Future<void> createUserByAdmin(String nom, String prenom, String email, String telephone, String password, String role) async {
    try {
      await _repository.createUserByAdmin(nom, prenom, email, telephone, password, role);
      // Recharger la liste des utilisateurs après création
      await chargerUsers();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}