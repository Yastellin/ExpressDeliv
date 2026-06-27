import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/commande.dart';
import '../../domain/repositories/commande_repository.dart';
import '../../data/repositories/commande_repository_impl.dart';

// ─── States ────────────────────────────────────────────────
abstract class CreateOrderState extends Equatable {
  const CreateOrderState();
  @override
  List<Object?> get props => [];
}

class CreateOrderInitial extends CreateOrderState {}

class CreateOrderLoading extends CreateOrderState {}

class CreateOrderSuccess extends CreateOrderState {
  final Commande commande;
  const CreateOrderSuccess(this.commande);
  @override
  List<Object?> get props => [commande];
}

class CreateOrderError extends CreateOrderState {
  final String message;
  const CreateOrderError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ──────────────────────────────────────────────────
class CreateOrderCubit extends Cubit<CreateOrderState> {
  final CommandeRepository _repository;

  CreateOrderCubit() : _repository = CommandeRepositoryImpl(), super(CreateOrderInitial());

  String adresse = '';

  void updateAdresse(String value) {
    adresse = value;
  }

  Future<void> submitOrder(String adresseFinal, List<Map<String, dynamic>> colisFinal) async {
    if (adresseFinal.isEmpty) {
      emit(CreateOrderError('L\'adresse de livraison est requise'));
      return;
    }
    if (colisFinal.isEmpty) {
      emit(CreateOrderError('Ajoutez au moins un colis'));
      return;
    }

    emit(CreateOrderLoading());
    try {
      final commande = await _repository.createCommande(adresseFinal, colisFinal);
      emit(CreateOrderSuccess(commande));
    } catch (e) {
      emit(CreateOrderError(e.toString()));
    }
  }

  void reset() {
    emit(CreateOrderInitial());
  }
}