// login.dart
import 'package:flutter/material.dart';
import '../widgets/footbar_peminjaman.dart';
import '../widgets/footbar_pj.dart';  
import '../widgets/footbar_pic.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart';
import '../services/fcm_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  
  final AuthService _authService = AuthService();
  final FCMService _fcmService = FCMService(); 

  // FUNGSI _login()
  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Panggil service login
      final user = await _authService.login(username, password);

      // 2. Simpan data session user
      await UserSession.saveUserData(user);

      // 3. Update Token FCM ke Server (Agar notifikasi jalan)
      // Kita bungkus try-catch kecil agar jika notifikasi gagal, login tetap jalan
      try {
        await _fcmService.getTokenAndSendToServer();
      } catch (e) {
        print("Warning: Gagal update FCM Token: $e");
      }

      // Ambil data role dan nama
      final String userRole = user['roles'] ?? 'Mahasiswa'; 
      final String userName = user['name'] ?? 'User';      

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login berhasil sebagai $userRole ✅")),
      );

      // 4. Arahkan berdasarkan role
      if (userRole == 'Mahasiswa') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FootbarPeminjaman(
              username: userName,
              role: userRole,
            ),
          ),
        );
      } else if (userRole == 'Laboran Jurusan') {
        // ✅ PERBAIKAN: Gunakan FootbarPj di sini agar import tidak warning
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FootbarPj()),
        );
      } else if (userRole == 'Dosen') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FootbarPic()),
        );
      } else {
        // Default (jika role tidak dikenal)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FootbarPic()),
        );
      }
    } catch (e) {
      // Tangkap error yang dilempar dari service
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Welcome to PENRU!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan login untuk mengakses layanan peminjaman ruangan Polibatam.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Username",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: "Enter your username",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Password",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // Nonaktifkan tombol saat loading
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A39D9), // biru
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      // Tampilkan loading spinner
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      // Tampilkan teks jika tidak loading
                      : const Text(
                          "Masuk",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}