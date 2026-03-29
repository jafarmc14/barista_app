import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

Future<Map<String, String>> getHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final storedToken = prefs.getString('auth_token') ?? '';
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $storedToken',
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pavilijon Coffee',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN tidak boleh kosong')));
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
        final token = data['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          final user = data['user'];
          if (user != null && user['name'] != null) {
            await prefs.setString('user_name', user['name'].toString());
          }
          await prefs.setString('user_pin', pin);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
                    'Pavilijon Coffee',
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
                    'Pav app',
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _todoList = [];
  final List<Map<String, dynamic>> _doneList = [];
  bool _isLoading = false;
  bool _isSyncingDone = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchOrders();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name');
      });
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final pin = prefs.getString('user_pin') ?? '';

      // Menggunakan http.Request agar bisa mengirim body JSON pada method GET
      final request = http.Request(
        'GET',
        Uri.parse('https://pavilijoncoffee.com/api/to-go/orders?status=PAID'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'pin': pin});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> orders = data is List ? data : (data['data'] ?? []);

        if (mounted) {
          setState(() {
            _todoList = orders.map((o) => o as Map<String, dynamic>).toList();
            _doneList
                .clear(); // Opsional: bersihkan completed item saat refresh
          });
        }
      } else {
        _showError('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Terjadi kesalahan jaringan saat mengambil data');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _markAsDone(Map<String, dynamic> item) {
    setState(() {
      _todoList.remove(item);
      _doneList.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task berhasil diselesaikan!')),
    );
  }

  Future<void> _syncDoneOrders() async {
    if (_doneList.isEmpty) return;

    setState(() {
      _isSyncingDone = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      for (var item in _doneList) {
        final id = item['id'];
        if (id == null) continue;

        try {
          await http.patch(
            Uri.parse(
              'https://pavilijoncoffee.com/api/to-go/orders/$id/status',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'status': 'COMPLETED'}),
          );
        } catch (innerE) {
          debugPrint('Gagal sync item $id: $innerE');
        }
      }

      if (mounted) {
        setState(() {
          _doneList.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua pesanan telah diselesaikan ke server'),
          ),
        );
      }
    } catch (e) {
      _showError('Terjadi kesalahan sinkronisasi data');
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingDone = false;
        });
      }
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> item, {required bool isDone}) {
    final title =
        item['orderHash']?.toString() ??
        item['id']?.toString() ??
        'Unknown Order';

    // Cek format customer, bisa dari obyek {"customer": {"name": ...}} atau string langsung
    String customerName = 'Customer';
    if (item['customer'] is Map && item['customer']['name'] != null) {
      customerName = item['customer']['name'].toString();
    } else if (item['customerName'] != null) {
      customerName = item['customerName'].toString();
    } else if (item['customer_name'] != null) {
      customerName = item['customer_name'].toString();
    }

    // Susun detail items Product
    String itemsDetail = '';
    if (item['items'] is List) {
      final List<dynamic> itemsList = item['items'];
      List<String> textItems = [];
      for (var p in itemsList) {
        if (p is Map) {
          final qty = p['quantity']?.toString() ?? '1';
          final name =
              p['productName']?.toString() ?? p['name']?.toString() ?? 'Produk';
          final variant = p['variantLabel']?.toString() ?? '';

          if (variant.isNotEmpty) {
            textItems.add('${qty}x $name ($variant)');
          } else {
            textItems.add('${qty}x $name');
          }
        }
      }
      itemsDetail = textItems.join(', ');
    }

    if (itemsDetail.isEmpty) {
      itemsDetail = '0 items';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #$title',
                        style: TextStyle(
                          fontFamily:
                              'Manrope', // Sesuai dengan instruksi supaya menonjol
                          fontSize: 16,
                          fontWeight: FontWeight.w800, // Extrabold
                          color: const Color(0xFF2C2F30),
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customerName,
                        style: const TextStyle(
                          color: Color(0xFF595C5D),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDone)
                  const Icon(Icons.check_circle, color: Colors.green, size: 28)
                else
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF005E9F),
                      size: 28,
                    ),
                    onPressed: () => _markAsDone(item),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                itemsDetail,
                style: const TextStyle(
                  color: Color(0xFF595C5D),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7), // Surface
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F7), // Surface
        elevation: 0,
        title: const Text(
          'Tasks',
          style: TextStyle(
            color: Color(0xFF595C5D),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Color(0xFF005E9F),
            ), // Tombol ASK/Sync
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memanggil data API...')),
              );
              _fetchOrders();
            },
            tooltip: 'ASK Data',
          ),
          // Tombol Add "+" dihapus sesuai instruksi
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchOrders,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Judul Besar ---
                const Text(
                  'Pavilijon Coffee',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C2F30),
                    letterSpacing: -0.5,
                  ),
                ),
                // --- Nama User Opsional ---
                if (_userName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back, $_userName!',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF595C5D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // --- Section To Do ---
                const Text(
                  'To Do',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2F30),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_todoList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Tidak ada task (To Do)',
                      style: TextStyle(color: Color(0xFF595C5D)),
                    ),
                  )
                else
                  ..._todoList.map(
                    (item) => _buildTaskCard(item, isDone: false),
                  ),

                const SizedBox(height: 48),

                // --- Section Done ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2F30),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF005E9F,
                        ), // Menggunakan primary Tailwind (Biru)
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(60, 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: _isSyncingDone || _doneList.isEmpty
                          ? null
                          : _syncDoneOrders,
                      child: _isSyncingDone
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'DONE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_doneList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Belum ada task yang diselesaikan',
                      style: TextStyle(color: Color(0xFF595C5D)),
                    ),
                  )
                else
                  ..._doneList.map(
                    (item) => _buildTaskCard(item, isDone: true),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
