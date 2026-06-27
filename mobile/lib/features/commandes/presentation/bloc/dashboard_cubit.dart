import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/commande.dart';
import '../../domain/repositories/commande_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final CommandeRepository _repository;

  DashboardCubit(this._repository) : super(DashboardInitial());

  Future<void> chargerCommandes() async {
    emit(DashboardLoading());
    try {
      final commandes = await _repository.getMesCommandes();
      if (commandes.isEmpty) {
        emit(DashboardEmpty());
      } else {
        emit(DashboardSuccess(commandes));
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  void reset() {
    emit(DashboardInitial());
  }
}