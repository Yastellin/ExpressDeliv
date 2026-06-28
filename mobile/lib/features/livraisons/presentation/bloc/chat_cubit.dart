import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/socket_service.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatSuccess extends ChatState {
  final List<Map<String, dynamic>> messages;
  final int version; // ✅ Force le rebuild à chaque changement
  const ChatSuccess(this.messages, this.version);
  @override
  List<Object?> get props => [messages, version];
}
class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatCubit extends Cubit<ChatState> {
  final String livraisonId;
  final String currentUserId;
  List<Map<String, dynamic>> _messages = [];
  int _version = 0;
  bool _isClosed = false;

  ChatCubit({
    required this.livraisonId,
    required this.currentUserId,
  }) : super(ChatLoading()) {
    print('🟣 [ChatCubit] Initialisation pour livraison $livraisonId');
    _initChat();
  }

  void _initChat() {
    SocketService.listenToChatHistory((data) {
      if (_isClosed) return;
      print('📜 [ChatCubit] Historique reçu : $data');
      final history = data['messages'] as List? ?? [];
      _messages = history.map((e) => e as Map<String, dynamic>).toList();
      _version++;
      emit(ChatSuccess(_messages, _version));
      SocketService.markChatAsRead(livraisonId);
    });

    SocketService.listenToNewChatMessage((message) {
      if (_isClosed) return;
      print('💬 [ChatCubit] Nouveau message reçu : $message');
      _messages.add(message);
      _version++;
      emit(ChatSuccess(_messages, _version)); // ✅ Nouvelle liste + version
    });

    SocketService.listenToChatError((dynamic error) {
      if (_isClosed) return;
      String msg = 'Erreur de chat';
      if (error is Map) {
        msg = error['message']?.toString() ?? msg;
      } else if (error is String) {
        msg = error;
      }
      emit(ChatError(msg));
    });

    print('🟣 [ChatCubit] Appel de SocketService.joinChat');
    SocketService.joinChat(livraisonId);
  }

  void sendMessage(String contenu) {
    if (contenu.trim().isEmpty) return;
    print('💬 [ChatCubit] Envoi du message : $contenu');
    SocketService.sendChatMessage(livraisonId, contenu.trim());
  }

  void markAsRead() {
    SocketService.markChatAsRead(livraisonId);
  }

  @override
  Future<void> close() {
    _isClosed = true;
    print('🟣 [ChatCubit] Fermeture');
    return super.close();
  }
}