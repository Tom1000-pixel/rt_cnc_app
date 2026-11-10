import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_crud_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color goldColor = const Color(0xFFF5C451);
  final Color bgColor = const Color(0xFF070B1C);
  final Color cardColor = const Color(0xFF0E1738);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('ADMIN PANEL', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: goldColor)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: goldColor,
          labelColor: goldColor,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.settings_input_antenna), text: 'Koneksi'),
            Tab(icon: Icon(Icons.edit_document), text: 'Data & CRUD'),
            Tab(icon: Icon(Icons.campaign), text: 'Pesan'),
            Tab(icon: Icon(Icons.image), text: 'Gambar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabKoneksi(),
          _buildTabData(),
          _buildTabPesan(),
          _buildTabGambar(),
        ],
      ),
    );
  }

  // ═══ TAB 1: KONEKSI ═══
  Widget _buildTabKoneksi() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_done, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  Text('Koneksi Supabase', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Status: Terhubung (Hardcoded)', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Text('URL: https://qwwtawqidgwiabenkuwk.supabase.co', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Connect Code segera hadir!'))),
            icon: const Icon(Icons.qr_code, color: Colors.black),
            label: const Text('CONNECT VIA CODE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: goldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        )
      ],
    );
  }

  // ═══ TAB 2: DATA ═══
  Widget _buildTabData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.table_chart, size: 60, color: Colors.white24),
          const SizedBox(height: 20),
          const Text('Kelola Data Offset CNC', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCrudScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor, 
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('BUKA MENU CRUD', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ═══ TAB 3: PESAN (BROADCAST) ═══
  Widget _buildTabPesan() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Kirim Pemberitahuan ke User', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        TextField(
          controller: titleCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Judul Pesan',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true, fillColor: cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: bodyCtrl,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Isi Pesan',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true, fillColor: cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              try {
                await Supabase.instance.client.from('app_messages').insert({
                  'id': 'm${DateTime.now().millisecondsSinceEpoch}',
                  'title': titleCtrl.text,
                  'body': bodyCtrl.text,
                  'sender': 'Admin',
                  'created_at': DateTime.now().toIso8601String(),
                });
                if (context.mounted) {
                  titleCtrl.clear();
                  bodyCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesan Broadcast Terkirim!')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            icon: const Icon(Icons.send, color: Colors.black),
            label: const Text('KIRIM BROADCAST', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: goldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        )
      ],
    );
  }

  // ═══ TAB 4: GAMBAR ═══
  Widget _buildTabGambar() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload, size: 60, color: Colors.white24),
          const SizedBox(height: 20),
          const Text('Upload Gambar ke Supabase Storage', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          const Text('(Fitur ini akan dibahas di Tahap 7)', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
