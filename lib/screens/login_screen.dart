import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeLine = 1;
  bool _chipEnabled = false;
  String _chipCondition = 'r4';
  
  // Warna tema
  final Color goldColor = const Color(0xFFF5C451);
  final Color bgColor = const Color(0xFF070B1C);
  final Color cardColor = const Color(0xFF0E1738);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Logo & Nama)
              _buildHeader(),
              const SizedBox(height: 20),

              // 2. PLAKAT STATUS (Cloud, Sync, Pro)
              _buildStatusPlaque(),
              const SizedBox(height: 24),

              // 3. PANEL PILIHAN GARIS PRODUKSI
              _buildLineSelectorPanel(),
              const SizedBox(height: 16),

              // 4. PANEL CHIP REPAIR
              _buildChipRepairPanel(),
              const SizedBox(height: 24),

              // 5. PANEL SELISIH OP 1 & OP 2 (Placeholder dulu)
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
            // Logo Hexagon Emas
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: goldColor,
                shape: BoxShape.circle, // Nanti ganti jadi CustomPaint buat hexagon
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
        // Tombol Logout
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white54),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          },
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
          _buildStatusItem(Icons.cloud_off, 'Offline', Colors.redAccent),
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
          
          // Dropdown Line
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
            onChanged: (val) => setState(() => _activeLine = val!),
          ),
          const SizedBox(height: 12),

          // Dropdown Master
          _buildDropdownLabel('Tipe Master (Referensi)'),
          _buildFakeDropdown('Pilih Tipe Master...', Colors.blueAccent),
          const SizedBox(height: 12),

          // Dropdown Target
          _buildDropdownLabel('Tipe Target (Analisis)'),
          _buildFakeDropdown('Pilih Tipe Target...', Colors.purpleAccent),
          const SizedBox(height: 16),

          // Tombol Segarkan
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () {},
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

  Widget _buildDropdownLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFakeDropdown(String hint, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Icon(Icons.arrow_drop_down, color: color),
        ],
      ),
    );
  }

  Widget _buildChipRepairPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0A3A), // Warna ungu gelap
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
    return Column(
      children: [
        _buildOpCard('OP 1', Colors.blueAccent),
        const SizedBox(height: 16),
        _buildOpCard('OP 2', goldColor),
      ],
    );
  }

  Widget _buildOpCard(String title, Color color) {
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
                child: Text('0 ITEM', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('Belum ada data perbandingan', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
