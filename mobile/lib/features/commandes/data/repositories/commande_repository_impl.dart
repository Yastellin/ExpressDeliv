import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/commande_repository.dart';
import '../models/commande.dart';

class CommandeRepositoryImpl implements CommandeRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<List<Commande>> getMesCommandes() async {
    try {
      final response = await _dio.get('/commandes');
      
      // Supposons que la réponse soit directe : { "data": [ { ... } ] }
      // ou un wrapper comme pour l'auth.
      // D'après le backend, c'est probablement un objet "data" contenant le tableau.
      final data = response.data;
      
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final list = data['data'] as List;
        return list.map((e) => Commande.fromJson(e)).toList();
      } else if (data is List) {
        return data.map((e) => Commande.fromJson(e)).toList();
      } else {
        throw Exception('Format de réponse inattendu');
      }
    } on DioException catch (e) {
      throw Exception('Erreur lors du chargement des commandes');
    } catch (e) {
      throw Exception('Erreur inattendue');
    }
  }

@override
Future<Commande> createCommande(String adresse, List<Map<String, dynamic>> colis) async {
  try {
    final response = await _dio.post('/commandes', data: {
      'adresse_livraison': adresse,
      'colis': colis,
    });
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      try {
        return Commande.fromJson(data['data'] as Map<String, dynamic>);
      } catch (e) {
        // Ajoute un log pour voir l'erreur exacte
        print('Erreur de parsing Commande : $e');
        print('Réponse reçue : ${data['data']}');
        throw Exception('Erreur de parsing des données : ${e.toString()}');
      }
    } else {
      throw Exception('Format de réponse inattendu');
    }
  } on DioException catch (e) {
    final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
    throw Exception('Erreur : $errorMsg');
  } catch (e) {
    throw Exception('Erreur inattendue : ${e.toString()}');
  }
}

@override
Future<Commande> getCommande(String id) async {
  try {
    print('[Repo] Récupération commande $id');
    final response = await _dio.get('/commandes/$id');
    print('[Repo] Réponse brute : ${response.data}'); // <-- AJOUT
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return Commande.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Format de réponse inattendu');
    }
  } on DioException catch (e) {
    print('[Repo] Erreur Dio : ${e.response?.data}');
    throw Exception('Erreur réseau : ${e.message}');
  } catch (e) {
    print('[Repo] Erreur inattendue : $e');
    throw Exception('Erreur inattendue');
  }
}

@override
Future<Commande> annulerCommande(String id) async {
  try {
    final response = await _dio.patch('/commandes/$id/annuler');
    final data = response.data;

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return Commande.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Format de réponse inattendu');
    }
  } on DioException catch (e) {
    final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
    throw Exception('Erreur : $errorMsg');
  } catch (e) {
    throw Exception('Erreur inattendue');
  }
}
}