import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../data/models/dashboard_stats.dart';
import '../../../auth/data/models/auth_request.dart';
import '../../../commandes/data/models/commande.dart';


class AdminRepositoryImpl implements AdminRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<DashboardStats> getStats() async {
    try {
      print('[AdminRepo] Récupération des statistiques...');
      final response = await _dio.get('/stats/dashboard');
      print('[AdminRepo] Réponse stats : ${response.data}');
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return DashboardStats.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Format de réponse inattendu');
      }
    } on DioException catch (e) {
      print('[AdminRepo] Erreur Dio stats : ${e.response?.data}');
      throw Exception('Erreur réseau : ${e.message}');
    } catch (e) {
      print('[AdminRepo] Erreur inattendue stats : $e');
      throw Exception('Erreur inattendue');
    }
  }

@override
Future<List<UserDto>> getUsers() async {
  try {
    print('👥 [AdminRepo] Appel API /users');
    final response = await _dio.get('/users');
    print('📦 [AdminRepo] Réponse brute : ${response.data}');
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final list = data['data'] as List?;
      if (list != null) {
        return list.map((e) => UserDto.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    // Si le format est inattendu, on throw
    throw Exception('Format de réponse inattendu');
  } on DioException catch (e) {
    print('❌ [AdminRepo] Erreur Dio : ${e.response?.statusCode} - ${e.response?.data}');
    // Fallback explicite
    print('📦 [AdminRepo] Utilisation des données factices');
    return _getMockUsers();
  } catch (e) {
    print('❌ [AdminRepo] Erreur inattendue : $e');
    return _getMockUsers();
  }
}

List<UserDto> _getMockUsers() {
  return [
    UserDto(
      id: '1',
      nom: 'Admin',
      prenom: 'Super',
      email: 'admin@test.com',
      role: 'ADMIN',
      telephone: '0324567890',
      adresse_defaut: 'Adresse admin',
      statut: 'ACTIF',
    ),
    UserDto(
      id: '2',
      nom: 'Rakoto',
      prenom: 'Jean',
      email: 'livreur@test.com',
      role: 'LIVREUR',
      telephone: '0324567891',
      adresse_defaut: 'Adresse livreur',
      statut: 'ACTIF',
    ),
    UserDto(
      id: '3',
      nom: 'Rabe',
      prenom: 'Jean',
      email: 'client@test.com',
      role: 'CLIENT',
      telephone: '0324567892',
      adresse_defaut: 'Adresse client',
      statut: 'ACTIF',
    ),
  ];
}

  @override
  Future<void> toggleUserStatus(String userId, String statut) async {
    try {
      print('🔄 [AdminRepo] PATCH /users/$userId/statut avec statut=$statut');
      final response = await _dio.patch('/users/$userId/statut', data: {'statut': statut});
      print('✅ [AdminRepo] Réponse : ${response.data}');
    } on DioException catch (e) {
      print('❌ [AdminRepo] Erreur Dio : ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Erreur réseau : ${e.message}');
    } catch (e) {
      print('❌ [AdminRepo] Erreur inattendue : $e');
      throw Exception('Erreur inattendue');
    }
  }

    @override
    Future<List<Commande>> getPendingOrders() async {
      try {
        print('📦 [AdminRepo] Récupération des commandes en attente...');
        final response = await _dio.get('/commandes');
        print('📦 [AdminRepo] Réponse brute : ${response.data}');
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final list = data['data'] as List;
          // Filtrer uniquement les commandes en attente (statut = 'EN_ATTENTE' ou 'VALIDEE' selon votre backend)
          final allOrders = list.map((e) => Commande.fromJson(e as Map<String, dynamic>)).toList();
          final pending = allOrders.where((c) => c.statut == 'EN_ATTENTE' || c.statut == 'VALIDEE').toList();
          print('✅ [AdminRepo] ${pending.length} commandes en attente trouvées');
          return pending;
        } else {
          throw Exception('Format de réponse inattendu');
        }
      } on DioException catch (e) {
        print('❌ [AdminRepo] Erreur Dio orders : ${e.response?.data}');
        throw Exception('Erreur réseau : ${e.message}');
      } catch (e) {
        print('❌ [AdminRepo] Erreur inattendue orders : $e');
        throw Exception('Erreur inattendue');
      }
    }

    @override
    Future<List<UserDto>> getLivreurs() async {
      try {
        print('👥 [AdminRepo] Récupération des livreurs...');
        final response = await _dio.get('/users/livreurs');
        print('👥 [AdminRepo] Réponse brute : ${response.data}');
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final list = data['data'] as List;
          final livreurs = list.map((e) => UserDto.fromJson(e as Map<String, dynamic>)).toList();
          // ✅ Filtrer les livreurs actifs (si le champ statut existe, sinon on les garde)
          final actifs = livreurs.where((u) => u.statut == 'ACTIF' || u.statut.isEmpty).toList();
          print('✅ [AdminRepo] ${actifs.length} livreurs actifs trouvés');
          return actifs;
        } else {
          throw Exception('Format de réponse inattendu');
        }
      } on DioException catch (e) {
        print('❌ [AdminRepo] Erreur Dio livreurs : ${e.response?.data}');
        throw Exception('Erreur réseau : ${e.message}');
      } catch (e) {
        print('❌ [AdminRepo] Erreur inattendue livreurs : $e');
        throw Exception('Erreur inattendue');
      }
    }

    @override
    Future<void> assignerLivraison(String commandeId, String livreurId) async {
      try {
        print('🚚 [AdminRepo] Assignation commande $commandeId au livreur $livreurId');
        final response = await _dio.post('/livraisons', data: {
          'commande_id': commandeId,
          'livreur_id': livreurId,
        });
        print('✅ [AdminRepo] Assignation réussie : ${response.data}');
      } on DioException catch (e) {
        print('❌ [AdminRepo] Erreur assignation : ${e.response?.data}');
        throw Exception('Erreur lors de l\'assignation');
      } catch (e) {
        print('❌ [AdminRepo] Erreur inattendue assignation : $e');
        throw Exception('Erreur inattendue');
      }
    }

}