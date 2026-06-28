import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/commande.dart';
import '../../domain/repositories/commande_repository.dart';
import '../../data/repositories/commande_repository_impl.dart';

// ─── États ────────────────────────────────────────────────
abstract class CommandesState extends Equatable {
  const CommandesState();
  @override
  List<Object?> get props => [];
}

class CommandesInitial extends CommandesState {}
class CommandesLoading extends CommandesState {}
class CommandesSuccess extends CommandesState {
  final List<Commande> commandes;
  const CommandesSuccess(this.commandes);
  @override
  List<Object?> get props => [commandes];
}
class CommandesEmpty extends CommandesState {}
class CommandesError extends CommandesState {
  final String message;
  const CommandesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ──────────────────────────────────────────────────
class CommandesCubit extends Cubit<CommandesState> {
  final CommandeRepository _repository;

  CommandesCubit() : _repository = CommandeRepositoryImpl(), super(CommandesInitial());

  Future<void> chargerCommandes() async {
    emit(CommandesLoading());
    print('📋 [CommandesCubit] Chargement des commandes');
    try {
      final commandes = await _repository.getMesCommandes();
      if (commandes.isEmpty) {
        emit(CommandesEmpty());
      } else {
        emit(CommandesSuccess(commandes));
      }
    } catch (e) {
      emit(CommandesError(e.toString()));
    }
  }
}