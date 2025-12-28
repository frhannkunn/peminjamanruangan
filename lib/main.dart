import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:penru_mobile/peminjaman/notifikasi.dart'; // Pastikan path ini benar
import 'splash.dart'; // Pastikan path ini benar
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 1. TAMBAHAN PENTING: Handler Background
// Fungsi ini harus berada DI LUAR main() dan class apapun (Top Level Function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Jika Anda butuh akses database di background, init Firebase di sini juga
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. TAMBAHAN PENTING: Registrasi Handler Background
  // Baris ini wajib ada sebelum aplikasi dijalankan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _requestPermission();
  _setupFCMListeners();
  _checkInitialMessage(); // Cek jika aplikasi dibuka dari notifikasi (Terminated state)

  // Cek token (Hanya untuk debug, nanti dipindah ke Login)
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("✅ CEK TOKEN DI CONSOLE: $token");
    // Nanti token ini yang dikirim ke API Laravel saat Login
  } catch (e) {
    print("⚠️ Gagal dapat token: $e");
  }

  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

Future<void> _requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("User mengizinkan notifikasi");
  } else {
    print("User menolak notifikasi");
  }
}

void _setupFCMListeners() {
  // 1. Foreground (Aplikasi sedang dibuka)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    if (message.notification != null) {
      // Anda menggunakan Dialog (Popup), ini oke.
      // Alternatif yang lebih halus adalah menggunakan 'flutter_local_notifications' (Banner atas).
      _showForegroundDialog(
        message.notification!.title, 
        message.notification!.body,
      );
    }
  });

  // 2. Background -> Opened (Aplikasi diminimize, lalu notif diklik)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Aplikasi dibuka dari notifikasi background');
    _handleMessage(message);
  });
}

void _handleMessage(RemoteMessage message) {
  // Navigasi ke halaman notifikasi
  // Pastikan widget NotifikasiScreen menerima parameter message/body
  navigatorKey.currentState?.push(
    MaterialPageRoute( 
      builder: (context) { 
        return NotifikasiScreen(
          message: message.notification?.body ?? "No Message",
        );
      },
    ),
  ); 
}

// 3. Terminated -> Opened (Aplikasi mati total, lalu notif diklik)
void _checkInitialMessage() async {
  RemoteMessage? initialMessage = 
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
}

void _showForegroundDialog(String? title, String? body) {
  if (navigatorKey.currentState?.overlay?.context == null) return;
  
  showDialog(
    context: navigatorKey.currentState!.overlay!.context,
    builder: (context) {
      return AlertDialog( 
        title: Text(title ?? "Pemberitahuan"),
        content: Text(body ?? "Ada pesan baru"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            child: const Text("OK"), 
          ),
        ],
      );
    },
  );
}
    
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Peminjaman Ruangan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}