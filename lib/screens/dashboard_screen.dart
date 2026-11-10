import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/offset_model.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeLine = 1;
  bool _chipEnabled = false;
  String _chipCondition = 'r4';
  
  List<OffsetItem> _allData = [];
  List<String> _availableTypes = [];
  String? _selectedMaster;
  String? _selectedTarget;
  bool _isLoading = true;
  String _userRole = 'operator';

  // Warna Tema (Presisi dari HTML)
  final Color goldColor = const Color(0xFFF5C451);
  final Color goldDark = const Color(0xFF7A5214);
  final Color bgColor = const Color(0xFF070B1C);
  final Color cardColor = const Color(0xFF0E1738);
  final Color textMuted = const Color(0xFF748096);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final role = await AuthService.getUserRole();
    setState(() => _userRole = role);
    _fetchDataFromSupabase();
  }

  Future<void> _fetchDataFromSupabase() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('offset_db')
          .select()
          .eq('line', _activeLine)
          .order('type');

      final data = (response as List).map((e) => OffsetItem.fromJson(e)).toList();
      final types = data.map((e) => e.type).toSet().toList()..sort();

      setState(() {
        _allData = data;
        _availableTypes = types;
        _selectedMaster = null;
        _selectedTarget = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5C451)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumHeader(),
                  const SizedBox(height: 20),
                  _buildGoldPlaque(),
                  const SizedBox(height: 24),
                  _buildLineSelectorPanel(), // UI masih sederhana, nanti kita poles
                  const SizedBox(height: 16),
                  _buildChipRepairPanel(),
                  const SizedBox(height: 24),
                  _buildComparisonPanels(),
                ],
              ),
            ),
      ),
    );
  }

  // 1. HEADER PRESISI (Logo Hexagon & Font Cinzel/Montserrat)
  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Logo Hexagon
            CustomPaint(
              size: const Size(50, 55),
              painter: HexagonPainter(goldColor, goldDark),
              child: const Center(
                child: Icon(Icons.precision_manufacturing, color: Color(0xFF5CC8FF), size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OFFSET', style: GoogleFonts.montserrat(
                  fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                  color: goldColor, height: 0.9,
                  shadows: [Shadow(color: goldColor.withOpacity(0.5), blurRadius: 10)],
                )),
                const SizedBox(height: 2),
                Text('ANALYZER PRO', style: GoogleFonts.cinzel(
                  fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3
                )),
                const SizedBox(height: 2),
                Text('PRECISION · INSIGHT · PROFIT', style: GoogleFonts.plusJakartaSans(
                  fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.5
                )),
              ],
            ),
          ],
        ),
        Row(
          children: [
            if (_userRole == 'admin')
              IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFF5C451)),
                onPressed: () => Navigator.pushNamed(context, '/admin'),
              ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white54),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            )
          ],
        )
      ],
    );
  }

  // 2. PLAKAT STATUS EMAS (Custom Shape & Border Gradient)
  Widget _buildGoldPlaque() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: goldColor.withOpacity(0.15), blurRadius: 20, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPlaqueItem(Icons.cloud_done, 'Online', Colors.greenAccent, true),
          Container(width: 1, height: 30, color: goldColor.withOpacity(0.2)),
          _buildPlaqueItem(Icons.sync, '14:14', Colors.blueAccent, false),
          Container(width: 1, height: 30, color: goldColor.withOpacity(0.2)),
          _buildPlaqueItem(Icons.workspace_premium, 'PRO', goldColor, false),
        ],
      ),
    );
  }

  Widget _buildPlaqueItem(IconData icon, String text, Color color, bool isGlowing) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24, shadows: isGlowing ? [Shadow(color: color, blurRadius: 10)] : null),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          shadows: isGlowing ? [Shadow(color: color, blurRadius: 5)] : null,
        )),
      ],
    );
  }

  // SEMENTARA PAKAI UI SIMPEL DULU (Nanti kita poles satu-satu)
  Widget _buildLineSelectorPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilihan Garis Produksi', style: TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _activeLine,
            dropdownColor: cardColor,
            style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 18),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            items: [1, 2, 3, 4].map((l) => DropdownMenuItem(value: l, child: Text('LINE $l'))).toList(),
            onChanged: (val) {
              setState(() => _activeLine = val!);
              _fetchDataFromSupabase();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChipRepairPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0A3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.memory, color: Colors.purpleAccent, size: 30),
          const SizedBox(width: 10),
          const Expanded(child: Text('CHIP REPAIR', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold))),
          Switch(value: _chipEnabled, activeColor: Colors.purpleAccent, onChanged: (v) => setState(() => _chipEnabled = v)),
        ],
      ),
    );
  }

  Widget _buildComparisonPanels() {
    // Logika persis kayak sebelumnya
    return const Center(child: Text('Panel Selisih (Siap dipoles)', style: TextStyle(color: Colors.white54)));
  }
}

// CLASS CUSTOM PAINTER BUAT LOGO HEXAGON
class HexagonPainter extends CustomPainter {
  final Color goldColor;
  final Color goldDark;
  HexagonPainter(this.goldColor, this.goldDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    final w = size.width;
    final h = size.height;
    
    // Gambar bentuk hexagon
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    // Efek Glow
    final glowPaint = Paint()
      ..color = goldColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
