import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
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

  // State buat Upload Gambar
  File? _selectedImage;
  bool _isUploading = false;
  String _uploadLine = '1';
  String _uploadOp = 'op1';

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
          _buildTabGambar(), // Tab upload gambar baru
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
              const Text('Status: Terhubung', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Text('URL: https://qwwtawqidgwiabenkuwk.supabase.co', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
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
            labelText: 'Judul Pesan', labelStyle: const TextStyle(color: Colors.white54),
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
            labelText: 'Isi Pesan', labelStyle: const TextStyle(color: Colors.white54),
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
                  'title': titleCtrl.text, 'body': bodyCtrl.text, 'sender': 'Admin',
                  'created_at': DateTime.now().toIso8601String(),
                });
                if (context.mounted) {
                  titleCtrl.clear(); bodyCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesan Terkirim!')));
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

  // ═══ TAB 4: UPLOAD GAMBAR ═══
  Widget _buildTabGambar() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Upload Gambar (Line & OP)', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _uploadLine,
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Line', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                items: ['1', '2', '3', '4'].map((e) => DropdownMenuItem(value: e, child: Text('LINE $e'))).toList(),
                onChanged: (val) => setState(() => _uploadLine = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _uploadOp,
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'OP', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                items: ['op1', 'op2'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => _uploadOp = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Tombol Pilih Gambar
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withOpacity(0.3), style: BorderStyle.solid),
          ),
          child: _selectedImage == null
            ? TextButton(
                onPressed: _pickImage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: goldColor.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    const Text('PILIH GAMBAR', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_selectedImage!, fit: BoxFit.cover)),
                  Positioned(
                    top: 8, right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ),
                  )
                ],
              ),
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
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      final file = _selectedImage!;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = 'line$_uploadLine/$_uploadOp/$fileName';

      final supabase = Supabase.instance.client;

      // 1. Upload ke Storage
      await supabase.storage.from('line-images').upload(filePath, file);

      // 2. Dapetin URL Publik
      final publicUrl = supabase.storage.from('line-images').getPublicUrl(filePath);

      // 3. Simpan Metadata ke Tabel line_images
      await supabase.from('line_images').insert({
        'line': int.parse(_uploadLine),
        'op': _uploadOp,
        'image_url': publicUrl,
        'file_path': filePath,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gambar Berhasil Diupload!')));
        setState(() => _selectedImage = null);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }
}
