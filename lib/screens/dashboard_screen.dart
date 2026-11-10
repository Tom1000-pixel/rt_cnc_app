import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/offset_model.dart';
import '../services/auth_service.dart';
import '../widgets/deviation_gauge.dart';

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

  List<Map<String, dynamic>> _op1Images = [];
  List<Map<String, dynamic>> _op2Images = [];

  Timer? _syncTimer;

  final Color goldColor = const Color(0xFFF5C451);
  final Color goldDark = const Color(0xFF7A5214);
  final Color bgColor = const Color(0xFF070B1C);
  final Color cardColor = const Color(0xFF0E1738);

  @override
  void initState() {
    super.initState();
    _initData();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchDataFromSupabase(isSilent: true);
        _fetchImages();
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    final role = await AuthService.getUserRole();
    setState(() => _userRole = role);
    _fetchDataFromSupabase();
    _fetchImages();
  }

  Future<void> _fetchDataFromSupabase({bool isSilent = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('offset_db').select().eq('line', _activeLine).order('type');
      final data = (response as List).map((e) => OffsetItem.fromJson(e)).toList();
      final types = data.map((e) => e.type).toSet().toList()..sort();

      setState(() {
        _allData = data;
        _availableTypes = types;
        if (!isSilent) { _selectedMaster = null; _selectedTarget = null; }
        _isLoading = false;
      });
    } catch (e) {
      if (!isSilent) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchImages() async {
    try {
      final res = await Supabase.instance.client.from('line_images').select().eq('line', _activeLine);
      final List<Map<String, dynamic>> allImgs = List<Map<String, dynamic>>.from(res);
      setState(() {
        _op1Images = allImgs.where((img) => img['op'] == 'op1').toList();
        _op2Images = allImgs.where((img) => img['op'] == 'op2').toList();
      });
    } catch (e) { debugPrint('Error fetch images: $e'); }
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
                  _buildLineSelectorPanel(),
                  const SizedBox(height: 16),
                  _buildChipRepairPanel(),
                  const SizedBox(height: 24),
                  _buildComparisonPanels(),
                  const SizedBox(height: 24),
                  _buildMatrixPanel(), // <-- Panel Matrix Baru
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomPaint(
              size: const Size(50, 55),
              painter: HexagonPainter(goldColor, goldDark),
              child: const Center(child: Icon(Icons.precision_manufacturing, color: Color(0xFF5CC8FF), size: 24)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OFFSET', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: goldColor, height: 0.9, shadows: [Shadow(color: goldColor.withOpacity(0.5), blurRadius: 10)])),
                const SizedBox(height: 2),
                Text('ANALYZER PRO', style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
                const SizedBox(height: 2),
                Text('PRECISION · INSIGHT · PROFIT', style: GoogleFonts.plusJakartaSans(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.5)),
              ],
            ),
          ],
        ),
        Row(
          children: [
            if (_userRole == 'admin')
              IconButton(icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFF5C451)), onPressed: () => Navigator.pushNamed(context, '/admin')),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white54),
              onPressed: () async { await Supabase.instance.client.auth.signOut(); if (mounted) Navigator.pushReplacementNamed(context, '/login'); },
            )
          ],
        )
      ],
    );
  }

  Widget _buildGoldPlaque() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: goldColor.withOpacity(0.15), blurRadius: 20, spreadRadius: 1)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPlaqueItem(Icons.cloud_done, 'Auto-Sync', Colors.greenAccent, true),
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
        Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, shadows: isGlowing ? [Shadow(color: color, blurRadius: 5)] : null)),
      ],
    );
  }

  Widget _buildLineSelectorPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: goldColor.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_input_component, color: Color(0xFFF5C451), size: 24),
              const SizedBox(width: 12),
              Text('Pilihan Garis Produksi', style: TextStyle(color: goldColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: goldColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          _buildDropdownLabel('LINE'),
          _buildCustomDropdown<int>(
            value: _activeLine,
            items: [1, 2, 3, 4].map((l) => DropdownMenuItem(value: l, child: Text('LINE $l'))).toList(),
            onChanged: (val) { setState(() => _activeLine = val!); _fetchDataFromSupabase(); _fetchImages(); },
            baseColor: goldColor,
          ),
          const SizedBox(height: 16),
          _buildDropdownLabel('Tipe Master (Referensi)'),
          _buildCustomDropdown<String>(
            value: _selectedMaster,
            hint: 'Pilih Tipe Master...',
            items: _availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) => setState(() => _selectedMaster = val),
            baseColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 16),
          _buildDropdownLabel('Tipe Target (Analisis)'),
          _buildCustomDropdown<String>(
            value: _selectedTarget,
            hint: 'Pilih Tipe Target...',
            items: _availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) => setState(() => _selectedTarget = val),
            baseColor: const Color(0xFFA855F7),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () { _fetchDataFromSupabase(); _fetchImages(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disegarkan!'), duration: Duration(seconds: 1))); },
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text('SEGARKAN CLOUD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(backgroundColor: goldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5, shadowColor: goldColor.withOpacity(0.5)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdownLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 6, left: 4), child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)));
  }

  Widget _buildCustomDropdown<T>({required T? value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged, required Color baseColor, String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: baseColor.withOpacity(0.1), blurRadius: 10)],
      ),
      child: DropdownButtonFormField<T>(
        value: value, dropdownColor: cardColor, icon: Icon(Icons.arrow_drop_down, color: baseColor),
        style: TextStyle(color: baseColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), hintText: hint, hintStyle: TextStyle(color: baseColor.withOpacity(0.4), fontSize: 14)),
        items: items, onChanged: onChanged,
      ),
    );
  }

  Widget _buildChipRepairPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0A3A), // Background ungu gelap
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 20, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.memory, color: Colors.purpleAccent, size: 30, shadows: [Shadow(color: Colors.purpleAccent, blurRadius: 10)]),
              const SizedBox(width: 10),
              const Expanded(child: Text('CHIP REPAIR — TR404 SUMBU X OP2', style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold))),
              Switch(value: _chipEnabled, activeColor: Colors.purpleAccent, onChanged: (val) => setState(() => _chipEnabled = val)),
            ],
          ),
          if (_chipEnabled) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _chipCondition, dropdownColor: const Color(0xFF1B0A3A),
              style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
              decoration: InputDecoration(filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              items: const [
                DropdownMenuItem(value: 'baru', child: Text('Chip Baru')),
                DropdownMenuItem(value: 'r1', child: Text('Repair 1x')),
                DropdownMenuItem(value: 'r2', child: Text('Repair 2x')),
                DropdownMenuItem(value: 'r3', child: Text('Repair 3x')),
                DropdownMenuItem(value: 'r4', child: Text('Repair 4x (Setting Awal)')),
              ],
              onChanged: (val) => setState(() => _chipCondition = val!),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildComparisonPanels() {
    final masterData = _allData.where((d) => d.type == _selectedMaster).toList();
    final targetData = _allData.where((d) => d.type == _selectedTarget).toList();

    List<Map<String, dynamic>> op1List = [];
    List<Map<String, dynamic>> op2List = [];

    if (_selectedMaster != null && _selectedTarget != null) {
      for (var m1 in masterData) {
        final m2 = targetData.firstWhere((x) => x.tool == m1.tool && x.op == m1.op, orElse: () => OffsetItem(id: '', line: 0, type: '', op: '', tool: '', x: 0, z: 0));
        if (m2.id.isNotEmpty) {
          final dx = (m2.x - m1.x);
          final dz = (m2.z - m1.z);
          if (dx != 0 || dz != 0) {
            final opStr = m1.op.toUpperCase();
            final item = {
              'tool': m1.tool, 'op': m1.op,
              'dx': dx > 0 ? '+${dx.toStringAsFixed(3)}' : dx.toStringAsFixed(3),
              'dz': dz > 0 ? '+${dz.toStringAsFixed(3)}' : dz.toStringAsFixed(3),
              'sev': dx.abs() > 0.05 || dz.abs() > 0.05 ? 2 : 1,
            };
            if (opStr.contains('1')) { op1List.add(item); } else { op2List.add(item); }
          }
        }
      }
    }

    return Column(
      children: [
        _buildOpCard('OP 1', Colors.blueAccent, op1List, _op1Images),
        const SizedBox(height: 16),
        _buildOpCard('OP 2', goldColor, op2List, _op2Images),
      ],
    );
  }

  Widget _buildOpCard(String title, Color color, List<Map<String, dynamic>> items, List<Map<String, dynamic>> images) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SELISIH $title', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  if (images.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(right: 8.0), child: TextButton.icon(onPressed: () => _showImageDialog(images, title), icon: Icon(Icons.image, color: color, size: 16), label: Text('LIHAT', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)), style: TextButton.styleFrom(backgroundColor: color.withOpacity(0.1), padding: const EdgeInsets.symmetric(horizontal: 8)))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text('${items.length} ITEM', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Semua nilai identik / data belum dipilih', style: TextStyle(color: Colors.white38, fontSize: 12))
          else
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(width: 3, height: 45, decoration: BoxDecoration(color: item['sev'] == 2 ? const Color(0xFFFB7185) : const Color(0xFFFBBF24), borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: item['sev'] == 2 ? Colors.redAccent : Colors.amber, blurRadius: 5)])),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['tool'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)), Text(item['op'], style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold))])),
                  Expanded(flex: 4, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [DeviationGauge(label: 'DEV X', value: item['dx']), const SizedBox(width: 12), DeviationGauge(label: 'DEV Z', value: item['dz'])])),
                ],
              ),
            ))
        ],
      ),
    );
  }

  // ─── MATRIX PANEL BARU ───
  Widget _buildMatrixPanel() {
    if (_selectedMaster == null || _selectedTarget == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: goldColor.withOpacity(0.2))),
        child: const Center(child: Text('Pilih Master & Target untuk melihat Matriks', style: TextStyle(color: Colors.white38, fontSize: 12))),
      );
    }

    final masterData = _allData.where((d) => d.type == _selectedMaster).toList();
    final targetData = _allData.where((d) => d.type == _selectedTarget).toList();

    List<Map<String, dynamic>> matrixData = [];
    for (var m1 in masterData) {
      final m2 = targetData.firstWhere((x) => x.tool == m1.tool && x.op == m1.op, orElse: () => OffsetItem(id: '', line: 0, type: '', op: '', tool: '', x: 0, z: 0));
      if (m2.id.isNotEmpty) {
        matrixData.add({
          'tool': m1.tool, 'op': m1.op,
          'mX': m1.x.toStringAsFixed(3), 'mZ': m1.z.toStringAsFixed(3),
          'tX': m2.x.toStringAsFixed(3), 'tZ': m2.z.toStringAsFixed(3),
          'dX': (m2.x - m1.x).toStringAsFixed(3), 'dZ': (m2.z - m1.z).toStringAsFixed(3),
        });
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MATRIKS DEVIASI', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
              dataRowMinHeight: 40,
              dataRowMaxHeight: 50,
              columns: const [
                DataColumn(label: Text('TOOL', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('M: X', style: TextStyle(color: Colors.blueAccent, fontSize: 10))),
                DataColumn(label: Text('M: Z', style: TextStyle(color: Colors.blueAccent, fontSize: 10))),
                DataColumn(label: Text('T: X', style: TextStyle(color: Colors.purpleAccent, fontSize: 10))),
                DataColumn(label: Text('T: Z', style: TextStyle(color: Colors.purpleAccent, fontSize: 10))),
                DataColumn(label: Text('DEV X', style: TextStyle(color: Colors.amber, fontSize: 10))),
                DataColumn(label: Text('DEV Z', style: TextStyle(color: Colors.amber, fontSize: 10))),
              ],
              rows: matrixData.map((row) {
                return DataRow(cells: [
                  DataCell(Text('${row['tool']}\n${row['op']}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                  DataCell(Text(row['mX'], style: const TextStyle(color: Colors.white70, fontSize: 10))),
                  DataCell(Text(row['mZ'], style: const TextStyle(color: Colors.white70, fontSize: 10))),
                  DataCell(Text(row['tX'], style: const TextStyle(color: Colors.white70, fontSize: 10))),
                  DataCell(Text(row['tZ'], style: const TextStyle(color: Colors.white70, fontSize: 10))),
                  DataCell(Text(row['dX'], style: TextStyle(color: double.parse(row['dX']) > 0.05 || double.parse(row['dX']) < -0.05 ? Colors.redAccent : Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))),
                  DataCell(Text(row['dZ'], style: TextStyle(color: double.parse(row['dZ']) > 0.05 || double.parse(row['dZ']) < -0.05 ? Colors.redAccent : Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(List<Map<String, dynamic>> images, String opTitle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gambar $opTitle', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: PageView.builder(itemCount: images.length, itemBuilder: (context, index) => ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(images[index]['image_url'], fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white24, size: 50))))),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: Colors.black), child: const Text('TUTUP', style: TextStyle(fontWeight: FontWeight.bold)))
            ],
          ),
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color goldColor;
  final Color goldDark;
  HexagonPainter(this.goldColor, this.goldDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = goldColor..style = PaintingStyle.stroke..strokeWidth = 3.0;
    final path = Path();
    final w = size.width; final h = size.height;
    path.moveTo(w * 0.5, 0); path.lineTo(w, h * 0.25); path.lineTo(w, h * 0.75); path.lineTo(w * 0.5, h); path.lineTo(0, h * 0.75); path.lineTo(0, h * 0.25); path.close();
    final glowPaint = Paint()..color = goldColor.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 8.0..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glowPaint); canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
