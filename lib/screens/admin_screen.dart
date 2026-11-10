import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // State Upload Gambar
  File? _selectedImage;
  bool _isUploading = false;
  String _uploadLine = '1';
  String _uploadOp = 'op1';

  // State Connect Code
  String? _generatedCode;
  bool _isGeneratingCode = false;

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

  // ═══ TAB 1: KONEKSI (Connect Code) ═══
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
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Konek Device Baru', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Generate kode 6 digit untuk menghubungkan device lain tanpa perlu setting manual.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 16),
        
        // Tombol Generate
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isGeneratingCode ? null : _generateCode,
            icon: _isGeneratingCode ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.vpn_key, color: Colors.black),
            label: Text(_isGeneratingCode ? 'MEMPROSES...' : 'GENERATE KODE KONEKSI', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: goldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),

        // Tampilan Kode
        if (_generatedCode != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 2),
            ),
            child: Column(
              children: [
                const Text('KODE KONEKSI ANDA:', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 10),
                SelectableText(
                  _generatedCode!,
                  style: GoogleFonts.jetBrainsMono(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 8),
                ),
                const SizedBox(height: 10),
                const Text('Masukkan kode ini di device baru.', style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          )
        ]
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
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCrudScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('BUKA MENU CRUD', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ═══ TAB 3: PESAN ═══
  Widget _buildTabPesan() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Kirim Pemberitahuan ke User', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Judul Pesan', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 12),
        TextField(controller: bodyCtrl, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Isi Pesan', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              try {
                await Supabase.instance.client.from('app_messages').insert({'id': 'm${DateTime.now().millisecondsSinceEpoch}', 'title': titleCtrl.text, 'body': bodyCtrl.text, 'sender': 'Admin', 'created_at': DateTime.now().toIso8601String()});
                if (context.mounted) { titleCtrl.clear(); bodyCtrl.clear(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesan Terkirim!'))); }
              } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'))); }
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Upload Gambar (Line & OP)', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: DropdownButtonFormField<String>(value: _uploadLine, dropdownColor: cardColor, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Line', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), items: ['1', '2', '3', '4'].map((e) => DropdownMenuItem(value: e, child: Text('LINE $e'))).toList(), onChanged: (val) => setState(() => _uploadLine = val!))),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(value: _uploadOp, dropdownColor: cardColor, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'OP', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), items: ['op1', 'op2'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(), onChanged: (val) => setState(() => _uploadOp = val!))),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 150, width: double.infinity,
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: goldColor.withOpacity(0.3))),
          child: _selectedImage == null
            ? TextButton(onPressed: _pickImage, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate, size: 40, color: goldColor.withOpacity(0.5)), const SizedBox(height: 8), const Text('PILIH GAMBAR', style: TextStyle(color: Colors.white54))]))
            : Stack(fit: StackFit.expand, children: [ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_selectedImage!, fit: BoxFit.cover)), Positioned(top: 8, right: 8, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 20), onPressed: () => setState(() => _selectedImage = null))))]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadImage,
            icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.cloud_upload, color: Colors.black),
            label: Text(_isUploading ? 'MENGUPLOAD...' : 'UPLOAD SEKARANG', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: goldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        )
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);
    try {
      final file = _selectedImage!;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = 'line$_uploadLine/$_uploadOp/$fileName';
      final supabase = Supabase.instance.client;
      await supabase.storage.from('line-images').upload(filePath, file);
      final publicUrl = supabase.storage.from('line-images').getPublicUrl(filePath);
      await supabase.from('line_images').insert({'line': int.parse(_uploadLine), 'op': _uploadOp, 'image_url': publicUrl, 'file_path': filePath});
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gambar Berhasil Diupload!'))); setState(() => _selectedImage = null); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
    } finally { setState(() => _isUploading = false); }
  }

  // ── LOGIKA CONNECT CODE (JSONBIN) ──
  Future<void> _generateCode() async {
    setState(() => _isGeneratingCode = true);
    try {
      // Generate 6 digit random
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final rnd = Random();
      final code = String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

      // Data yang mau dikirim
      final payload = {
        'code': code,
        'sb_url': 'https://qwwtawqidgwiabenkuwk.supabase.co',
        'sb_key': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3d3Rhd3FpZGd3aWFiZW5rdXdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1MzkzOTUsImV4cCI6MjA5ODExNTM5NX0.Q05_kZrzbL7n4FRlVsYOKyh7xrQ2ykPfnMFi6LiLGvg',
        'ts': DateTime.now().millisecondsSinceEpoch,
      };

      // Kirim ke JSONBin (Ganti URL & Key ini kalau lu punya akun JSONBin sendiri)
      // Untuk demo, kita pakai endpoint public bin kosongan
      final res = await http.post(
        Uri.parse('https://api.jsonbin.io/v3/b'),
        headers: {
          'Content-Type': 'application/json',
          'X-Bin-Name': 'offset-$code',
          'X-Bin-Private': 'false',
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        setState(() {
          _generatedCode = code;
        });
      } else {
        throw Exception('Gagal HTTP: ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Generate: $e')));
    } finally {
      setState(() => _isGeneratingCode = false);
    }
  }
}
