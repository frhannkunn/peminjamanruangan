// login.dart
import 'package:flutter/material.dart';
import '../widgets/footbar_peminjaman.dart';
import '../widgets/footbar_pj.dart';
import '../widgets/footbar_pic.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart'; 

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

  // BUAT INSTANCE DARI AUTH SERVICE
  final AuthService _authService = AuthService();

  // FUNGSI _login()
  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil service
      final user = await _authService.login(username, password);

      // 
      // ⬇️=================================================⬇️
      //         ** INI ADALAH BARIS YANG DIPERBAIKI **
      //    Menyimpan semua data user (NIK/NIM, Nama, Email, dll)
      //    ke SharedPreferences agar bisa dibaca oleh halaman Profil.
      //
      await UserSession.saveUserData(user);
      // ⬆️=================================================⬆️
      //

      // Jika service sukses, 'user' akan berisi data
      // Key 'roles' dan 'name' harus sesuai dengan JSON dari Laravel
      final String userRole = user['roles'] ?? 'Mahasiswa'; // Default jika null
      final String userName = user['name'] ?? 'User';      // Default jika null

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login berhasil sebagai $userRole ✅")),
      );

      // Arahkan berdasarkan role
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
        // Default (jika rolenya tidak dikenal, arahkan ke suatu tempat)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FootbarPic()),
        );
      }
    } catch (e) {
      // Tangkap error yang dilempar dari service
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        // Tampilkan pesan error dari service
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
    // (Build method Anda SAMA PERSIS, tidak perlu diubah)
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