import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/commande.dart';
import '../../domain/repositories/commande_repository.dart';
import '../../data/repositories/commande_repository_impl.dart';

// ─── States ────────────────────────────────────────────────
abstract class DetailOrderState extends Equatable {
  const DetailOrderState();
  @override
  List<Object?> get props => [];
}

class DetailOrderInitial extends DetailOrderState {}

class DetailOrderLoading extends DetailOrderState {}

class DetailOrderCancelLoading extends DetailOrderState {}

class DetailOrderSuccess extends DetailOrderState {
  final Commande commande;
  const DetailOrderSuccess(this.commande);
  @override
  List<Object?> get props => [commande];
}

class DetailOrderError extends DetailOrderState {
  final String message;
  const DetailOrderError(this.message);
  @override
  List<Object?> get props => [message];
}

class DetailOrderCancelSuccess extends DetailOrderState {
  final Commande commande;
  const DetailOrderCancelSuccess(this.commande);
  @override
  List<Object?> get props => [commande];
}


// ─── Cubit ──────────────────────────────────────────────────
class DetailOrderCubit extends Cubit<DetailOrderState> {
  final CommandeRepository _repository;

  DetailOrderCubit() : _repository = CommandeRepositoryImpl(), super(DetailOrderInitial());

  Future<void> loadCommande(String id) async {
    emit(DetailOrderLoading());
    try {
      final commande = await _repository.getCommande(id);
      emit(DetailOrderSuccess(commande));
    } catch (e) {
      emit(DetailOrderError(e.toString()));
    }
  }

    Future<void> annulerCommande(String id) async {
    emit(DetailOrderCancelLoading());
    try {
      final commande = await _repository.annulerCommande(id);
      emit(DetailOrderCancelSuccess(commande));
      // Recharger la commande après annulation
      await loadCommande(id);
    } catch (e) {
      emit(DetailOrderError(e.toString()));
    }
  }
}