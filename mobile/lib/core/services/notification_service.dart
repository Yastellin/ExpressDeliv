import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 1. Demander les permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('Permission FCM refusée');
      return;
    }

    print('Permission FCM accordée');

    // 2. Récupérer le token
    final token = await getToken();
    print('Token FCM : $token');

    // 3. Écouter les messages en premier plan
    FirebaseMessaging.onMessage.listen((message) {
      print('Notification reçue : ${message.notification?.title}');
    });

    // 4. Écouter les messages en arrière‑plan
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Notification en arrière‑plan : ${message.notification?.title}');
  }
}


/* import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Demander les permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('Permission FCM refusée');
      return;
    }

    print('Permission FCM accordée');

    // 2. Initialiser les notifications locales (avec les bons constructeurs)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // 3. Récupérer le token
    final token = await getToken();
    print('Token FCM : $token');

    // 4. Écouter les messages en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Écouter les messages en arrière-plan (fonction statique)
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // 6. Gérer l'ouverture via notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage.data);
    }

   // 7. Gérer les clics sur notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigationFromData(message.data);
    });
  }

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Notification reçue en premier plan : ${message.notification?.title}');
    _showLocalNotification(message);
    _handleNavigation(message.data);
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Notification reçue en arrière‑plan : ${message.notification?.title}');
    // On peut afficher une notification locale ici aussi
    // Mais pour le background, on utilise flutter_local_notifications
    // avec un plugin qui gère le background, mais c'est plus complexe.
    // Pour l'instant, on laisse la notification système s'afficher.
  }

  static void _handleNavigationFromData(Map<String, dynamic> data) {
    print('Notification cliquée : $data');
    // À implémenter pour naviguer vers la page concernée
  }

  static void _handleNavigation(Map<String, dynamic> data) {
    print('Navigation depuis notification : $data');
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'expressdeliv_channel',
      'ExpressDeliv',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  // Méthode pour enregistrer le token sur le backend (appelée depuis AuthCubit)
  static Future<void> registerToken(String token) async {
    print(' Enregistrement du token FCM : $token');
    // Cette méthode sera utilisée par le repository.
    // On la déplace vers le repository pour rester cohérent.
  }
}

*/