import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/livraison.dart';
import '../../domain/repositories/livraison_repository.dart';
import '../../data/repositories/livraison_repository_impl.dart';
import 'dart:async';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/socket_service.dart';
import 'package:geolocator/geolocator.dart';

// ─── States ────────────────────────────────────────────────
abstract class MissionsState extends Equatable {
  const MissionsState();
  @override
  List<Object?> get props => [];
}

class MissionsInitial extends MissionsState {}
class MissionsLoading extends MissionsState {}
class MissionsSuccess extends MissionsState {
  final List<Livraison> missions;
  const MissionsSuccess(this.missions);
  @override
  List<Object?> get props => [missions];
}
class MissionsEmpty extends MissionsState {}
class MissionsError extends MissionsState {
  final String message;
  const MissionsError(this.message);
  @override
  List<Object?> get props => [message];
}

// États pour les actions (Accepter/Refuser)
class MissionActionLoading extends MissionsState {
  final String missionId;
  const MissionActionLoading(this.missionId);
  @override
  List<Object?> get props => [missionId];
}

// ─── Cubit ──────────────────────────────────────────────────
class MissionsCubit extends Cubit<MissionsState> {
  final LivraisonRepository _repository;
  StreamSubscription<Position>? _positionSubscription;
  String? _currentLivraisonId;
  MissionsCubit() : _repository = LivraisonRepositoryImpl(), super(MissionsInitial());

  Future<void> chargerMissions() async {
    print('🔵 [Cubit] chargerMissions appelé');
    emit(MissionsLoading());
    try {
      final missions = await _repository.getMesMissions();
      print('📦 [Cubit] Missions reçues : ${missions.length}');
      if (missions.isEmpty) {
        print('📭 [Cubit] Aucune mission, émet Empty');
        emit(MissionsEmpty());
      } else {
        print('✅ [Cubit] Émet Success avec ${missions.length} missions');
        emit(MissionsSuccess(missions));
      }
    } catch (e) {
      print('❌ [Cubit] Erreur : $e');
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> accepterMission(String id) async {
    emit(MissionActionLoading(id));
    try {
      await _repository.accepterMission(id);
      await chargerMissions(); // recharge la liste
    } catch (e) {
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> refuserMission(String id) async {
    emit(MissionActionLoading(id));
    try {
      await _repository.refuserMission(id);
      await chargerMissions();
    } catch (e) {
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> updateStatut(String id, String statut) async {
    emit(MissionActionLoading(id));
    try {
      await _repository.mettreAJourStatut(id, statut);
      await chargerMissions();
    } catch (e) {
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> soumettrePreuve(String livraisonId, Map<String, dynamic> preuveData) async {
  emit(MissionActionLoading(livraisonId));
  print('[Cubit] Soumission preuve pour $livraisonId');
  try {
    await _repository.soumettrePreuve(livraisonId, preuveData);
    stopTracking();
    // Recharger la liste des missions pour mettre à jour le statut
    await chargerMissions();
    print('[Cubit] Preuve soumise, missions rechargées');
  } catch (e) {
    emit(MissionsError(e.toString()));
    print(' [Cubit] Erreur : $e');
  }
}

  // Nouvelle méthode pour démarrer le tracking sur une livraison
  Future<void> startTracking(String livraisonId) async {
    _currentLivraisonId = livraisonId;
    final hasPermission = await LocationService.requestPermission();
    if (!hasPermission) {
      emit(MissionsError('Permission GPS refusée'));
      return;
    }

    _positionSubscription = LocationService.getPositionStream().listen((position) {
      if (_currentLivraisonId != null) {
        SocketService.sendGpsUpdate(
          _currentLivraisonId!,
          position.latitude,
          position.longitude,
        );
        print('📍 Position envoyée : (${position.latitude}, ${position.longitude})');
      }
    });
  }

  // Nouvelle méthode pour arrêter le tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _currentLivraisonId = null;
    print('📍 Tracking GPS arrêté');
  }

  @override
  Future<void> close() {
    stopTracking();
    return super.close();
  }
}