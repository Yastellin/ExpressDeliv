import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  static IO.Socket? _socket;
  static String? _currentRoom;

  // Initialisation et connexion au serveur
  static void init(String userId, String role) {
    if (_socket != null && _socket!.connected) {
      print('🔌 Socket déjà connecté');
      return;
    }

    final uri = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    _socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {
        'userId': userId,
        'role': role,
      },
    });

    _socket!.onConnect((_) {
      print('✅ Socket.IO connecté');
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket.IO déconnecté');
    });

    _socket!.onError((error) {
      print('⚠️ Erreur Socket.IO : $error');
    });
  }

  // Rejoindre une room (ex: pour le suivi d'une livraison)
  static void joinRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      _currentRoom = roomId;
      _socket!.emit('join_room', roomId);
      print('📡 Rejoint la room : $roomId');
    }
  }

  // Quitter la room actuelle
  static void leaveRoom() {
    if (_socket != null && _socket!.connected && _currentRoom != null) {
      _socket!.emit('leave_room', _currentRoom);
      print('📡 Quitté la room : $_currentRoom');
      _currentRoom = null;
    }
  }

  // Écouter les mises à jour de position GPS
  static void listenToGpsUpdates(Function(Map<String, dynamic>) onUpdate) {
    if (_socket != null) {
      _socket!.on('gps_update', (data) {
        print('📍 Mise à jour GPS reçue : $data');
        onUpdate(data as Map<String, dynamic>);
      });
    }
  }

  // Écouter les messages du chat
  static void listenToChatMessages(Function(Map<String, dynamic>) onMessage) {
    if (_socket != null) {
      _socket!.on('chat_message', (data) {
        print('💬 Message chat reçu : $data');
        onMessage(data as Map<String, dynamic>);
      });
    }
  }

  // Envoyer une position GPS (par le livreur)
  static void sendGpsUpdate(String livraisonId, double lat, double lng) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('gps_update', {
        'livraisonId': livraisonId,
        'lat': lat,
        'lng': lng,
      });
      print('📍 Position envoyée : ($lat, $lng)');
    }
  }

  // Envoyer un message chat
  static void sendChatMessage(String livraisonId, String message, String senderRole) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat_message', {
        'livraisonId': livraisonId,
        'message': message,
        'senderRole': senderRole,
      });
    }
  }

  // Déconnexion propre
  static void disconnect() {
    leaveRoom();
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      print('🔌 Socket déconnecté proprement');
    }
  }
}