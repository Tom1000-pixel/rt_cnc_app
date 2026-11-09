import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/offset_model.dart';
import '../services/auth_service.dart'; // <-- Import AuthService

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeLine = 1;
  bool _chipEnabled = false;
  String _chipCondition = 'r4';
  
  // Data dari Supabase
  List<OffsetItem> _allData = [];
  List<String> _availableTypes = [];
  String? _selectedMaster;
  String? _selectedTarget;
  bool _isLoading = true;
  String _userRole = 'operator'; // <-- State buat nyimpen role

  // Warna tema
  final Color goldColor = const Color(0xFFF5C451);
  final Color bgColor = const Color(0xFF070B1C);
  final Color cardColor = const Color(0xFF0E1738);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Cek role dulu
    final role = await AuthService.getUserRole();
    setState(() => _userRole = role);
    
    // Baru ambil data offset
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
      
      // Ambil tipe unik
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatusPlaque(),
                  const SizedBox(height: 24),
                  _buildLineSelectorPanel(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: goldColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: goldColor.withOpacity(0.5), blurRadius: 10)],
              ),
              child: const Icon(Icons.precision_manufacturing, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OFFSET', style: GoogleFonts.montserrat(
                  fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                  color: goldColor, height: 1
                )),
                Text('ANALYZER PRO', style: GoogleFonts.cinzel(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2
                )),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Tombol Admin (Cuma muncul kalau role admin)
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

  Widget _buildStatusPlaque() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: goldColor.withOpacity(0.1), blurRadius: 15)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(Icons.cloud_done, 'Online', Colors.greenAccent),
          Container(width: 1, height: 30, color: Colors.white12),
          _buildStatusItem(Icons.sync, '14:14', Colors.blueAccent),
          Container(width: 1, height: 30, color: Colors.white12),
          _buildStatusItem(Icons.workspace_premium, 'PRO', goldColor),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLineSelectorPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: goldColor.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_input_component, color: Color(0xFFF5C451), size: 24),
              const SizedBox(width: 10),
              Text('Pilihan Garis Produksi', style: TextStyle(color: goldColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          
          _buildDropdownLabel('LINE'),
          DropdownButtonFormField<int>(
            value: _activeLine,
            dropdownColor: cardColor,
            style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 18),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: [1, 2, 3, 4].map((l) => DropdownMenuItem(value: l, child: Text('LINE $l'))).toList(),
            onChanged: (val) {
              setState(() => _activeLine = val!);
              _fetchDataFromSupabase();
            },
          ),
          const SizedBox(height: 12),

          _buildDropdownLabel('Tipe Master (Referensi)'),
          _buildTypeDropdown(
            value: _selectedMaster,
            hint: 'Pilih Tipe Master...',
            color: Colors.blueAccent,
            onChanged: (val) => setState(() => _selectedMaster = val),
          ),
          const SizedBox(height: 12),

          _buildDropdownLabel('Tipe Target (Analisis)'),
          _buildTypeDropdown(
            value: _selectedTarget,
            hint: 'Pilih Tipe Target...',
            color: Colors.purpleAccent,
            onChanged: (val) => setState(() => _selectedTarget = val),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: _fetchDataFromSupabase,
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text('SEGARKAN CLOUD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypeDropdown({required String? value, required String hint, required Color color, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: cardColor,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      decoration: InputDecoration(
        filled: true, fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: hint,
        hintStyle: TextStyle(color: color.withOpacity(0.5), fontSize: 13),
      ),
      items: _availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChipRepairPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0A3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.1), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.memory, color: Colors.purpleAccent, size: 30),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('CHIP REPAIR — TR404 SUMBU X OP2', 
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Switch(
                value: _chipEnabled,
                activeColor: Colors.purpleAccent,
                onChanged: (val) => setState(() => _chipEnabled = val),
              )
            ],
          ),
          if (_chipEnabled) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _chipCondition,
              dropdownColor: const Color(0xFF1B0A3A),
              style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
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
        final m2 = targetData.firstWhere(
          (x) => x.tool == m1.tool && x.op == m1.op, 
          orElse: () => OffsetItem(id: '', line: 0, type: '', op: '', tool: '', x: 0, z: 0)
        );
        
        if (m2.id.isNotEmpty) {
          final dx = (m2.x - m1.x);
          final dz = (m2.z - m1.z);
          
          if (dx != 0 || dz != 0) {
            final opStr = m1.op.toUpperCase();
            final item = {
              'tool': m1.tool,
              'op': m1.op,
              'dx': dx > 0 ? '+${dx.toStringAsFixed(3)}' : dx.toStringAsFixed(3),
              'dz': dz > 0 ? '+${dz.toStringAsFixed(3)}' : dz.toStringAsFixed(3),
              'sev': dx.abs() > 0.05 || dz.abs() > 0.05 ? 2 : 1,
            };
            
            if (opStr.contains('1')) {
              op1List.add(item);
            } else {
              op2List.add(item);
            }
          }
        }
      }
    }

    return Column(
      children: [
        _buildOpCard('OP 1', Colors.blueAccent, op1List),
        const SizedBox(height: 16),
        _buildOpCard('OP 2', goldColor, op2List),
      ],
    );
  }

  Widget _buildOpCard(String title, Color color, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SELISIH $title', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${items.length} ITEM', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Tidak ada selisih / data belum dipilih', style: TextStyle(color: Colors.white38, fontSize: 12))
          else
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 40,
                    decoration: BoxDecoration(
                      color: item['sev'] == 2 ? Colors.redAccent : Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['tool']} (${item['op']})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('X: ${item['dx']}  |  Z: ${item['dz']}', 
                          style: TextStyle(color: item['sev'] == 2 ? Colors.redAccent : Colors.amber, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  )
                ],
              ),
            ))
        ],
      ),
    );
  }
}
