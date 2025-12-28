// lib/services/fcm_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Wajib ada

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🛑 Pastikan IP ini SAMA dengan auth_service.dart
  // static const String _ipLaptop = "192.168.1.XX"; // Ganti jika pakai HP Fisik
  static const String _ipLaptop = "10.0.2.2";    // ✅ Emulator pakai ini
  final String _baseUrl = 'http://$_ipLaptop:8000/api/fcm-token'; 

  // 1. Inisialisasi
  Future<void> initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher'); 
    
    const InitializationSettings initSettings = 
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  // 2. Tampilkan Notif
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', 
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
    );
  }

  // 3. Update Token ke Server (YANG DIPERBAIKI)
  Future<void> getTokenAndSendToServer() async {
    try {
      // A. Ambil Token Auth User (Token Login) dari memory
      final prefs = await SharedPreferences.getInstance();
      final String? tokenAuth = prefs.getString('auth_token');

      if (tokenAuth == null) {
        print("❌ Gagal: User belum login (Token Auth kosong).");
        return;
      }

      // B. Ambil Token FCM (Token HP)
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken == null) return;
      
      print("📲 Token FCM HP: $fcmToken");

      // C. Kirim ke Laravel
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenAuth', // Kirim Token Login
        },
        body: jsonEncode({
          'token': fcmToken,
          'device_id': 'flutter_emulator', // Bisa diganti unik jika perlu
        }),
      );

      if (response.statusCode == 200) {
        print("✅ SUKSES: Token FCM tersimpan di Database!");
      } else {
        print("❌ GAGAL Server: ${response.body}");
      }
    } catch (e) {
      print("❌ ERROR Koneksi FCM: $e");
    }
  }
}

// Handler Background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.messageId}");
}