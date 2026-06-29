import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static String? _currentRoom;

  static void init(String userId, String role) {
    print('[Socket] init appelé avec userId: $userId, role: $role');
    
    final token = StorageService.getAccessToken();
    print('[Socket] Token récupéré : ${token != null ? 'OK (${token.substring(0, 20)}...)' : 'NULL'}');
    
    if (token == null) {
      print('[Socket] Token manquant, impossible de se connecter');
      return;
    }

    if (_socket != null && _socket!.connected) {
      print('[Socket] Déjà connecté');
      return;
    }

    // Supprimer le suffixe /api/v1 pour que le socket utilise la racine
    final rawUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    final baseUrl = rawUrl.replaceAll('/api/v1', '');
    print('[Socket] Tentative de connexion à $baseUrl');

    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
      'auth': {
        'token': token,
      },
      'query': {
        'userId': userId,
        'role': role,
      },
    });

    _socket!.onConnect((_) {
      print('✅ [Socket] Socket.IO connecté');
    });

  _socket!.onConnectError((error) {
    print('❌ [Socket] Erreur de connexion : $error');
    // Afficher plus de détails
    if (error is Exception) {
      print('❌ Détail : ${error.toString()}');
    }
  });


    _socket!.onDisconnect((_) {
      print('❌ [Socket] Socket.IO déconnecté');
    });

    _socket!.onError((error) {
      print('⚠️ [Socket] Erreur Socket.IO : $error');
    });
  }

  // ─── Chat ──────────────────────────────────────────────────
  static void joinChat(String livraisonId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:join', { 'livraison_id': livraisonId });
      print('💬 [Socket] Rejoint le chat de la livraison $livraisonId');
    } else {
      print('❌ [Socket] Socket non connecté');
    }
  }

  // ─── Chat ──────────────────────────────────────────────────
  static void listenToChatHistory(Function(Map<String, dynamic>) onHistory) {
    if (_socket != null) {
      _socket!.on('chat:history', (data) {
        print('📜 [Socket] chat:history reçu : $data');
        onHistory(data as Map<String, dynamic>);
      });
    }
  }

  static void listenToNewChatMessage(Function(Map<String, dynamic>) onMessage) {
    if (_socket != null) {
      _socket!.on('chat:message', (data) {
        print('💬 [Socket] chat:message reçu : $data');
        onMessage(data as Map<String, dynamic>);
      });
    }
  }

  static void listenToChatError(Function(Map<String, dynamic>) onError) {
    if (_socket != null) {
      _socket!.on('chat:error', (data) {
        print('⚠️ [Socket] chat:error reçu : $data');
        onError(data as Map<String, dynamic>);
      });
    }
  }

  static void sendChatMessage(String livraisonId, String contenu) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:message', {
        'livraison_id': livraisonId,
        'contenu': contenu,
      });
      print('💬 [Socket] chat:message envoyé');
    }
  }

  static void markChatAsRead(String livraisonId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:read', { 'livraison_id': livraisonId });
      print('👁️ [Socket] chat:read envoyé');
    }
  }

  // Rejoindre une room (ex: pour le suivi d'une livraison)
  static void joinRoom(String livraisonId) {
    if (_socket != null && _socket!.connected) {
      _currentRoom = livraisonId;
      _socket!.emit('gps:join', { 'livraison_id': livraisonId });
      print('Rejoint la room GPS pour la livraison : $livraisonId');
    }
  }

  // Quitter la room actuelle
  static void leaveRoom() {
    if (_socket != null && _socket!.connected && _currentRoom != null) {
      _socket!.emit('gps:leave', { 'livraison_id': _currentRoom });
      print('Quitté la room : $_currentRoom');
      _currentRoom = null;
    }
  }

  // Écouter les mises à jour de position GPS
  static void listenToGpsUpdates(Function(Map<String, dynamic>) onUpdate) {
    if (_socket != null) {
      _socket!.on('gps:position', (data) {
        print('Mise à jour GPS reçue : $data');
        onUpdate(data as Map<String, dynamic>);
      });
    }
  }

  // Écouter les messages du chat
  static void listenToChatMessages(Function(Map<String, dynamic>) onMessage) {
    if (_socket != null) {
      _socket!.on('chat:message', (data) {
        print('💬 Message chat reçu : $data');
        onMessage(data as Map<String, dynamic>);
      });
    }
  }

  // Envoyer une position GPS (par le livreur)
  static void sendGpsUpdate(String livraisonId, double lat, double lng) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('gps:update', {
        'livraison_id': livraisonId,
        'lat': lat,
        'lng': lng,
      });
      print('📍 Position envoyée : ($lat, $lng)');
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

  // Joindre une room pour le chat (différent de join_room générique)
  static void joinChatRoom(String livraisonId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:join', { 'livraison_id': livraisonId });
      print('📡 [Socket] Rejoint le chat de la livraison $livraisonId');
    }
  }

// Quitter le chat (optionnel)
  static void leaveChatRoom(String livraisonId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('chat:leave', { 'livraison_id': livraisonId });
    }
  }

}