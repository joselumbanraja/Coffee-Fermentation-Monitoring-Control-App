// main.dart
// main.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tugasakhir/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiService();
  final user = await api.getLoggedInUser();
  runApp(MyRootApp(initialUser: user));
}

class MyRootApp extends StatelessWidget {
  final Map<String, dynamic>? initialUser;
  const MyRootApp({super.key, required this.initialUser});

  @override
  Widget build(BuildContext context) {
    final start = initialUser != null;
    return MaterialApp(
      title: 'Fermentation IoT',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: start ? const MainMenuPage() : const LoginPage(),
    );
  }
}

// ===========================================================
// ======================= LOGIN PAGE ========================
// ===========================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  bool showPass = false;

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      final res = await api.login(_username.text.trim(), _password.text.trim());
      if (res['success'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainMenuPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text(res['error']?.toString() ?? 'Login gagal'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade400,
        content: Text('Login error: $e'),
      ));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6F4E37), Color(0xFFD7B89C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.coffee_rounded, color: Colors.brown, size: 60),
                    const SizedBox(height: 12),
                    const Text('Fermentation IoT',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: !showPass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => showPass = !showPass),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: loading ? null : _submitLogin,
                      child: loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Masuk'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: const Text('Belum punya akun? Daftar sekarang', style: TextStyle(color: Colors.brown)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// ====================== REGISTER PAGE ======================
// ===========================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  bool showPass = false;

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      final res = await api.register(_username.text.trim(), _email.text.trim(), _password.text.trim());
      if (res['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi berhasil, silakan login')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text(res['error']?.toString() ?? 'Registrasi gagal'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade400,
        content: Text('Registrasi error: $e'),
      ));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD7B89C), Color(0xFF6F4E37)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add_alt_1, color: Colors.brown, size: 60),
                    const SizedBox(height: 12),
                    const Text('Buat Akun Baru',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: !showPass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => showPass = !showPass),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: loading ? null : _submitRegister,
                      child: loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Daftar'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sudah punya akun? Login di sini', style: TextStyle(color: Colors.brown)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// ==================== MAIN MENU + LOGOUT ===================
// ===========================================================
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _index = 0;
  final ApiService api = ApiService();

  final List<Widget> pages = const [
    SensorDashboard(),
    ControlPage(),
    AddProfilePage(),
    HistoryPage(),
    ProfileListPage(),
  ];

  Future<void> _logout() async {
    await api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fermentation IoT", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.ssid_chart), label: 'Sensor'),
          NavigationDestination(icon: Icon(Icons.settings_remote), label: 'Kontrol'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Profil'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'), //
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Profil Rasa'),
        ],
      ),
    );
  }
}

// ========================= SENSOR DASHBOARD =========================
class SensorDashboard extends StatefulWidget {
  const SensorDashboard({super.key});
  @override
  State<SensorDashboard> createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  final ApiService api = ApiService();
  List<FlSpot> phData = [];
  List<FlSpot> tempData = [];
  List<FlSpot> humData = [];
  Timer? _timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await api.fetchSensor(limit: 30);
    if (data.isNotEmpty) {
      setState(() {
        phData = _toSpots(data, 'pH');
        tempData = _toSpots(data, 'temperature');
        humData = _toSpots(data, 'humidity');
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  List<FlSpot> _toSpots(List<dynamic> list, String key) {
    final spots = <FlSpot>[];
    for (int i = 0; i < list.length; i++) {
      final v = list[i][key];
      if (v != null) {
        final dbl = double.tryParse(v.toString()) ?? 0;
        spots.add(FlSpot(i.toDouble(), dbl));
      }
    }
    return spots.reversed.toList();
  }

  Widget chartCard(String title, List<FlSpot> spots) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: spots.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 2,
                            belowBarData: BarAreaData(show: true, color: Colors.brown.withOpacity(0.15)),
                            dotData: FlDotData(show: false),
                          )
                        ],
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            chartCard("pH", phData),
            chartCard("Suhu (°C)", tempData),
            chartCard("Kelembapan (%)", humData),
            if (loading) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

// ---------------------- CONTROL PAGE ------------------------
class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final ApiService api = ApiService();

  List<dynamic> profiles = [];
  int? selectedProfileId;
  Map<String, dynamic>? selectedProfile;

  bool running = false;
  DateTime? startTime;
  double latestPh = 0;
  double latestTemp = 0;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final p = await api.fetchProfiles();
    final ids = <int>{};
    profiles = p.where((e) => ids.add(int.tryParse(e['id'].toString()) ?? -1)).toList();

    setState(() {
      selectedProfileId = null;
      selectedProfile = null;
    });
  }

  Future<void> _fetchLatestSensor() async {
    final s = await api.fetchSensor(limit: 1);
    if (s.isNotEmpty) {
      final item = s.first;
      setState(() {
        latestPh = double.tryParse(item['pH']?.toString() ?? '') ?? latestPh;
        latestTemp = double.tryParse(item['temperature']?.toString() ?? '') ?? latestTemp;
      });
    }
  }

  Future<void> _toggle() async {
    if (selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih profil dulu sebelum memulai')));
      return;
    }

    if (!running) {
      // START
      await _fetchLatestSensor();
      setState(() {
        running = true;
        startTime = DateTime.now();
      });

      final profileId = selectedProfileId ?? 0;
      await api.toggleFermentation(profileId, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fermentasi dimulai untuk ${selectedProfile!['name']}')));
    } else {
      // STOP
      await _fetchLatestSensor();
      final endTime = DateTime.now();

      final hist = {
        "name": selectedProfile!['name'] ?? '',
        "coffee_type": selectedProfile!['coffee_type'] ?? '',
        "target_ph": double.tryParse(selectedProfile!['target_ph']?.toString() ?? '0') ?? 0,
        "target_temp_min": double.tryParse(selectedProfile!['target_temp_min']?.toString() ?? '0') ?? 0,
        "target_temp_max": double.tryParse(selectedProfile!['target_temp_max']?.toString() ?? '0') ?? 0,
        "final_ph": latestPh,
        "final_temp_min": latestTemp,
        "final_temp_max": latestTemp,
        "start_time": startTime?.toIso8601String() ?? '',
        "end_time": endTime.toIso8601String(),
        "status": "Selesai",
        "reason": "",
      };

      final ok = await api.addHistory(hist);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat fermentasi disimpan')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan riwayat')));
      }

      final profileId = selectedProfileId ?? 0;
      await api.toggleFermentation(profileId, false);

      setState(() {
        running = false;
        startTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          profiles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
                  value: selectedProfileId,
                  hint: const Text('Pilih Profil Rasa'),
                  items: profiles.map((e) {
                    final id = int.tryParse(e['id'].toString()) ?? 0;
                    final label = "${e['name']} — ${e['target_temp_min'] ?? '-'}°C to ${e['target_temp_max'] ?? '-'}°C";
                    return DropdownMenuItem<int>(value: id, child: Text(label));
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedProfileId = v;
                      selectedProfile = profiles.firstWhere((p) => int.tryParse(p['id'].toString()) == v, orElse: () => {});
                    });
                  },
                ),
          const SizedBox(height: 16),
          if (selectedProfile != null && selectedProfile!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profil: ${selectedProfile!['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Kopi: ${selectedProfile!['coffee_type'] ?? '-'}'),
                    Text('Target pH: ${selectedProfile!['target_ph'] ?? '-'}'),
                    Text('Target Suhu: ${selectedProfile!['target_temp_min'] ?? '-'}°C — ${selectedProfile!['target_temp_max'] ?? '-'}°C'),
                    const SizedBox(height: 12),
                    Text('Sensor terbaru — pH: ${latestPh.toStringAsFixed(2)} | Suhu: ${latestTemp.toStringAsFixed(1)}°C'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(running ? Icons.stop : Icons.play_arrow),
                          label: Text(running ? 'Stop Fermentasi' : 'Mulai Fermentasi'),
                          style: ElevatedButton.styleFrom(backgroundColor: running ? Colors.red : Colors.green),
                          onPressed: _toggle,
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Refresh Sensor'), onPressed: _fetchLatestSensor),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------- ADD PROFILE PAGE ------------------------
class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});
  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _coffee = TextEditingController();
  final _ph = TextEditingController();
  final _tmin = TextEditingController();
  final _tmax = TextEditingController();
  final _days = TextEditingController();
  final ApiService api = ApiService();

  @override
  void dispose() {
    _name.dispose();
    _coffee.dispose();
    _ph.dispose();
    _tmin.dispose();
    _tmax.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tmin = double.tryParse(_tmin.text) ?? 0;
    final tmax = double.tryParse(_tmax.text) ?? 0;
    if (tmin > tmax) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suhu min tidak boleh > max')));
      return;
    }
    final payload = {
      "name": _name.text,
      "coffee_type": _coffee.text,
      "target_ph": double.tryParse(_ph.text) ?? 0,
      "target_temp_min": tmin,
      "target_temp_max": tmax,
      "duration_days": int.tryParse(_days.text) ?? 0
    };
    final ok = await api.createProfile(payload);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil tersimpan')));
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan profil')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text('Tambah Profil Rasa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nama Profil'), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
            TextFormField(controller: _coffee, decoration: const InputDecoration(labelText: 'Jenis Kopi')),
            TextFormField(controller: _ph, decoration: const InputDecoration(labelText: 'Target pH'), keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _tmin, decoration: const InputDecoration(labelText: 'Suhu Min (°C)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v == null || v.isEmpty ? 'Wajib' : null)),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _tmax, decoration: const InputDecoration(labelText: 'Suhu Max (°C)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v == null || v.isEmpty ? 'Wajib' : null)),
              ],
            ),
            TextFormField(controller: _days, decoration: const InputDecoration(labelText: 'Durasi (hari)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            ElevatedButton.icon(icon: const Icon(Icons.save), label: const Text('Simpan'), onPressed: _save),
          ],
        ),
      ),
    );
  }
}

// ---------------------- PROFILE LIST PAGE (Edit/Delete) ------------------------
class ProfileListPage extends StatefulWidget {
  const ProfileListPage({super.key});
  @override
  State<ProfileListPage> createState() => _ProfileListPageState();
}

class _ProfileListPageState extends State<ProfileListPage> {
  final ApiService api = ApiService();
  List<dynamic> profiles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final p = await api.fetchProfiles();
    setState(() {
      profiles = p;
      loading = false;
    });
  }

  void _edit(dynamic p) {
    final name = TextEditingController(text: p['name'] ?? '');
    final coffee = TextEditingController(text: p['coffee_type'] ?? '');
    final ph = TextEditingController(text: p['target_ph']?.toString() ?? '0');
    final tmin = TextEditingController(text: p['target_temp_min']?.toString() ?? '0');
    final tmax = TextEditingController(text: p['target_temp_max']?.toString() ?? '0');
    final days = TextEditingController(text: p['duration_days']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: coffee, decoration: const InputDecoration(labelText: 'Jenis Kopi')),
              TextField(controller: ph, decoration: const InputDecoration(labelText: 'Target pH'), keyboardType: TextInputType.number),
              Row(
                children: [
                  Expanded(child: TextField(controller: tmin, decoration: const InputDecoration(labelText: 'Suhu Min'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: tmax, decoration: const InputDecoration(labelText: 'Suhu Max'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
              TextField(controller: days, decoration: const InputDecoration(labelText: 'Durasi (hari)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                "id": p['id'],
                "name": name.text,
                "coffee_type": coffee.text,
                "target_ph": double.tryParse(ph.text) ?? 0,
                "target_temp_min": double.tryParse(tmin.text) ?? 0,
                "target_temp_max": double.tryParse(tmax.text) ?? 0,
                "duration_days": int.tryParse(days.text) ?? 0
              };
              final ok = await api.updateProfile(payload);
              if (ok) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
                _load();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal update')));
              }
            },
            child: const Text('Simpan'),
          )
        ],
      ),
    );
  }

  Future<void> _delete(dynamic p) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Profil'),
        content: Text("Hapus '${p['name']}' ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (sure == true) {
      final ok = await api.deleteProfile(int.parse(p['id'].toString()));
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil dihapus')));
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (profiles.isEmpty) return const Center(child: Text('Belum ada profil'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: profiles.length,
        itemBuilder: (ctx, i) {
          final p = profiles[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(p['name'] ?? ''),
              subtitle: Text('Suhu: ${p['target_temp_min'] ?? '-'}°C — ${p['target_temp_max'] ?? '-'}°C\npH target: ${p['target_ph'] ?? '-'}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _edit(p)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(p)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------- HISTORY PAGE ------------------------
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService api = ApiService();
  List<dynamic> hist = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final h = await api.fetchHistory();
    setState(() {
      hist = h;
      loading = false;
    });
  }

  Future<void> _delete(dynamic item) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: Text("Hapus riwayat dari ${item['start_time'] ?? item['created_at'] ?? '-'} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (sure == true) {
      final id = int.tryParse(item['id'].toString()) ?? 0;
      final ok = await api.deleteHistory(id);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat dihapus')));
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus riwayat')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (hist.isEmpty) return const Center(child: Text('Belum ada riwayat'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: hist.length,
        itemBuilder: (ctx, i) {
          final h = hist[i];
          final start = h['start_time'] ?? h['created_at'] ?? '-';
          final end = h['end_time'] ?? '-';
          final tmin = h['target_temp_min'] ?? h['target_temp'] ?? '-';
          final tmax = h['target_temp_max'] ?? '-';
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text('${h['name'] ?? '-'} — ${h['status'] ?? '-'}'),
              subtitle: Text('Start: $start\nEnd: $end\nTarget Suhu: $tmin — $tmax °C\nFinal pH: ${h['final_ph'] ?? '-'}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(h)),
            ),
          );
        },
      ),
    );
  }
}
