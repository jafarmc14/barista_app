import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Focused Editorial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menggunakan warna biru selaras dengan HTML
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005E9F)),
        useMaterial3: true,
        fontFamily:
            'Manrope', // Gunakan font Manrope jika sudah ditambahkan di pubspec.yaml
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://pavilijoncoffee.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // Asumsi response JSON punya field token

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          _showError('Gagal mengambil token');
        }
      } else {
        _showError('Login Gagal, periksa PIN Anda');
      }
    } catch (e) {
      _showError('Terjadi kesalahan jaringan');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold dengan warna background 'surface' dari Tailwind HTML
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Judul ---
                  const Text(
                    'The Focused Editorial',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800, // Extrabold
                      color: Color(0xFF2C2F30), // Warna hitam pekat
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- Sub-judul ---
                  const Text(
                    'Start focusing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF595C5D), // Warna abu-abu
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Form Container (Boks Putih) ---
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Label "PASSWORD" & Forgot Password ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF595C5D),
                                letterSpacing: 1.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Aksi saat Lupa Password ditekan
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF005E9F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // --- Input Field Password ---
                        TextField(
                          controller: _pinController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: const TextStyle(
                              color: Color(0xFFABADAE), // text-outline-variant
                            ),
                            filled: true,
                            fillColor: const Color(
                              0xFFEFF1F2,
                            ), // bg-surface-container-low
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide
                                  .none, // Tanpa border untuk kesan modern
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            // Border saat input sedang difokuskan
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(
                                  0xFF005E9F,
                                ), // Cincin warna biru (primary)
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Tombol Log In Biru ---
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF005E9F,
                            ), // Warna latar biru (primary)
                            foregroundColor: Colors.white, // Warna teks
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            // Sudut yang sangat melengkung / Stadium Border
                            shape: const StadiumBorder(),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: const Center(child: Text('Welcome!')),
    );
  }
}
