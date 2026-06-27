import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/livraison_repository.dart';
import '../models/livraison.dart';

class LivraisonRepositoryImpl implements LivraisonRepository {
  final Dio _dio = DioClient.instance;

  @override
  Future<List<Livraison>> getMesMissions() async {
    print('[Repository] getMesMissions appelé');
    try {
      final response = await _dio.get('/livraisons/mes-missions');
      print('Réponse brute : ${response.data}');
      final data = response.data;

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final list = data['data'] as List;
        return list.map((e) => Livraison.fromJson(e)).toList();
      } else {
        throw Exception('Format de réponse inattendu');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau : ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue');
    }
  }

    @override
Future<void> accepterMission(String id) async {
  try {
    await _dio.patch('/livraisons/$id/accepter');
  } on DioException catch (e) {
    String errorMsg = 'Erreur lors de l\'acceptation';
    if (e.response?.data != null) {
      try {
        final errorData = e.response?.data as Map<String, dynamic>;
        if (errorData.containsKey('error')) {
          final errorObj = errorData['error'] as Map<String, dynamic>;
          if (errorObj.containsKey('message')) {
            errorMsg = errorObj['message'] as String;
          }
        }
      } catch (_) {}
    }
    throw Exception(errorMsg);
  } catch (e) {
    throw Exception('Erreur inattendue');
  }
}

@override
Future<void> refuserMission(String id) async {
  try {
    await _dio.patch('/livraisons/$id/refuser');
  } on DioException catch (e) {
    String errorMsg = 'Erreur lors du refus';
    if (e.response?.data != null) {
      try {
        final errorData = e.response?.data as Map<String, dynamic>;
        if (errorData.containsKey('error')) {
          final errorObj = errorData['error'] as Map<String, dynamic>;
          if (errorObj.containsKey('message')) {
            errorMsg = errorObj['message'] as String;
          }
        }
      } catch (_) {}
    }
    throw Exception(errorMsg);
  } catch (e) {
    throw Exception('Erreur inattendue');
  }
}

@override
Future<void> mettreAJourStatut(String id, String statut) async {
  try {
    await _dio.patch('/livraisons/$id/statut', data: {'statut': statut});
  } on DioException catch (e) {
    String errorMsg = 'Erreur lors de la mise à jour du statut';
    if (e.response?.data != null) {
      try {
        final errorData = e.response?.data as Map<String, dynamic>;
        if (errorData.containsKey('error')) {
          final errorObj = errorData['error'] as Map<String, dynamic>;
          if (errorObj.containsKey('message')) {
            errorMsg = errorObj['message'] as String;
          }
        }
      } catch (_) {}
    }
    throw Exception(errorMsg);
  } catch (e) {
    throw Exception('Erreur inattendue');
  }
}

@override
Future<void> soumettrePreuve(String livraisonId, Map<String, dynamic> preuveData) async {
  try {
    print('[Repository] Soumission preuve pour livraison $livraisonId');
    final response = await _dio.post('/livraisons/$livraisonId/preuve', data: preuveData);
    print('[Repository] Preuve soumise avec succès : ${response.data}');
  } on DioException catch (e) {
    print('[Repository] Erreur Dio : ${e.response?.data}');
    String errorMsg = 'Erreur lors de la soumission';
    if (e.response?.data != null) {
      try {
        final data = e.response?.data as Map<String, dynamic>;
        if (data.containsKey('error') && data['error'] is Map) {
          errorMsg = data['error']['message'] ?? errorMsg;
        }
      } catch (_) {}
    }
    throw Exception(errorMsg);
  } catch (e) {
    print('[Repository] Erreur inattendue : $e');
    throw Exception('Erreur inattendue');
  }
}
}