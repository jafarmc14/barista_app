import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  runApp(const MyApp());
}

Future<Map<String, String>> getHeaders() async {
  const storage = FlutterSecureStorage();
  final storedToken = await storage.read(key: 'auth_token') ?? '';
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
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://pavilijoncoffee.com/api');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'auth_token', value: token);

          final user = data['user'];
          if (user != null && user['name'] != null) {
            await storage.write(key: 'user_name', value: user['name'].toString());
          }
          await storage.write(key: 'user_pin', value: pin);

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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final GlobalKey<_BaristaPageState> _baristaKey = GlobalKey<_BaristaPageState>();
  final GlobalKey<_KurirPageState> _kurirKey = GlobalKey<_KurirPageState>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabLabels = ['Barista', 'Kurir'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F7),
        elevation: 0,
        title: Text(
          tabLabels[_currentPage],
          style: const TextStyle(
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
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memanggil data API...')),
              );
              if (_currentPage == 0) {
                _baristaKey.currentState?._fetchOrders();
              } else {
                _kurirKey.currentState?._fetchOrders();
              }
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Tab Indicator ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: List.generate(tabLabels.length, (index) {
                final isActive = _currentPage == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(right: index == 0 ? 6 : 0, left: index == 1 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF005E9F) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive ? const Color(0xFF005E9F) : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabLabels[index],
                          style: TextStyle(
                            color: isActive ? Colors.white : const Color(0xFF595C5D),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // --- PageView ---
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                BaristaPage(key: _baristaKey),
                KurirPage(key: _kurirKey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BARISTA PAGE
// ============================================================
class BaristaPage extends StatefulWidget {
  const BaristaPage({super.key});

  @override
  State<BaristaPage> createState() => _BaristaPageState();
}

class _BaristaPageState extends State<BaristaPage> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _todoList = [];
  final List<Map<String, dynamic>> _doneList = [];
  bool _isLoading = false;
  bool _isSyncingDone = false;
  String? _userName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchOrders();
  }

  Future<void> _loadUserName() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: 'user_name');
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token') ?? '';

      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://pavilijoncoffee.com/api');
      final response = await http.get(
        Uri.parse('$baseUrl/to-go/orders?status=PAID'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

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
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token') ?? '';

      for (var item in _doneList) {
        final id = item['id'];
        if (id == null) continue;

        try {
          final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://pavilijoncoffee.com/api');
          await http.patch(
            Uri.parse(
              '$baseUrl/to-go/orders/$id/status',
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

    // Ambil note dari customer
    String? customerNote;
    if (item['customer'] is Map && item['customer']['note'] != null) {
      final note = item['customer']['note'].toString().trim();
      if (note.isNotEmpty) {
        customerNote = note;
      }
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
            // --- Note dari Customer ---
            if (customerNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), // Kuning muda untuk highlight note
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 16,
                      color: Color(0xFFF9A825),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customerNote,
                        style: const TextStyle(
                          color: Color(0xFF795548),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
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
    );
  }
}

// ============================================================
// KURIR PAGE
// ============================================================
class KurirPage extends StatefulWidget {
  const KurirPage({super.key});

  @override
  State<KurirPage> createState() => _KurirPageState();
}

class _KurirPageState extends State<KurirPage> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _todoList = [];
  final List<Map<String, dynamic>> _doneList = [];
  bool _isLoading = false;
  bool _isSyncingDone = false;
  String? _userName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchOrders();
  }

  Future<void> _loadUserName() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: 'user_name');
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token') ?? '';

      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://pavilijoncoffee.com/api');
      final response = await http.get(
        Uri.parse('$baseUrl/orders/delivery?status=PAID'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> orders = data is List ? data : (data['data'] ?? []);

        if (mounted) {
          setState(() {
            _todoList = orders.map((o) => o as Map<String, dynamic>).toList();
            _doneList.clear();
          });
        }
      } else {
        _showError('Gagal mengambil data kurir: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Terjadi kesalahan jaringan saat mengambil data kurir');
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
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token') ?? '';

      for (var item in _doneList) {
        final id = item['id'];
        if (id == null) continue;

        try {
          final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://pavilijoncoffee.com/api');
          await http.patch(
            Uri.parse(
              '$baseUrl/orders/$id/status',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'status': 'DELIVERED'}),
          );
        } catch (innerE) {
          debugPrint('Gagal sync item kurir $id: $innerE');
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
    // Menggunakan queueNumber sebagai judul kartu
    final queueNumber = item['queueNumber']?.toString() ?? item['id']?.toString() ?? 'N/A';

    // Ambil customerInfo
    String customerName = 'Customer';
    String? customerNote;
    String? phone;
    String? address;
    String? parcelCode;

    if (item['customerInfo'] != null) {
      dynamic infoRaw = item['customerInfo'];
      Map? info;
      if (infoRaw is String) {
        try {
          info = jsonDecode(infoRaw) as Map?;
        } catch (_) {}
      } else if (infoRaw is Map) {
        info = infoRaw;
      }

      if (info != null) {
        if (info['name'] != null) {
          customerName = info['name'].toString();
        }
        if (info['note'] != null && info['note'].toString().trim().isNotEmpty) {
          customerNote = info['note'].toString().trim();
        }
        if (info['phone'] != null && info['phone'].toString().trim().isNotEmpty) {
          phone = info['phone'].toString().trim();
        }
        if (info['address'] != null && info['address'].toString().trim().isNotEmpty) {
          address = info['address'].toString().trim();
        }
        if (info['parcelCode'] != null && info['parcelCode'].toString().trim().isNotEmpty) {
          parcelCode = info['parcelCode'].toString().trim();
        }
      }
    } else if (item['customer'] != null) {
      dynamic customerRaw = item['customer'];
      Map? customer;
      if (customerRaw is String) {
        try {
          customer = jsonDecode(customerRaw) as Map?;
        } catch (_) {}
      } else if (customerRaw is Map) {
        customer = customerRaw;
      }

      if (customer != null) {
        if (customer['name'] != null) {
          customerName = customer['name'].toString();
        }
        if (customer['note'] != null && customer['note'].toString().trim().isNotEmpty) {
          customerNote = customer['note'].toString().trim();
        }
        if (customer['phone'] != null && customer['phone'].toString().trim().isNotEmpty) {
          phone = customer['phone'].toString().trim();
        }
        if (customer['address'] != null && customer['address'].toString().trim().isNotEmpty) {
          address = customer['address'].toString().trim();
        }
        if (customer['parcelCode'] != null && customer['parcelCode'].toString().trim().isNotEmpty) {
          parcelCode = customer['parcelCode'].toString().trim();
        }
      }
    }

    // Memastikan ambil juga dari root kalau customerInfo kosong atau tidak ada
    phone ??= (item['phone'] != null && item['phone'].toString().trim().isNotEmpty) ? item['phone'].toString().trim() : null;
    address ??= (item['address'] != null && item['address'].toString().trim().isNotEmpty) ? item['address'].toString().trim() : null;
    parcelCode ??= (item['parcelCode'] != null && item['parcelCode'].toString().trim().isNotEmpty) ? item['parcelCode'].toString().trim() : null;

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
                        'Queue #$queueNumber',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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
            // --- Info Pengiriman: Phone, Address, ParcelCode ---
            if (phone != null || address != null || parcelCode != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF90CAF9), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (phone != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF1565C0)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                phone,
                                style: const TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (address != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF1565C0)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (parcelCode != null)
                      Row(
                        children: [
                          const Icon(Icons.qr_code_2_outlined, size: 15, color: Color(0xFF1565C0)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              parcelCode,
                              style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
            // --- Note dari Customer ---
            if (customerNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 16,
                      color: Color(0xFFF9A825),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customerNote,
                        style: const TextStyle(
                          color: Color(0xFF795548),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
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
                  'Kurir',
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
                        ),
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
    );
  }
}
