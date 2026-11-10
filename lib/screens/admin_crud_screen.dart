import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCrudScreen extends StatefulWidget {
  const AdminCrudScreen({super.key});

  @override
  State<AdminCrudScreen> createState() => _AdminCrudScreenState();
}

class _AdminCrudScreenState extends State<AdminCrudScreen> {
  final Color goldColor = const Color(0xFFF5C451);
  final Color bgColor = const Color(0xFF070B1C);
  final Color cardColor = const Color(0xFF0E1738);

  final _typeCtrl = TextEditingController();
  final _opCtrl = TextEditingController();
  final _toolCtrl = TextEditingController();
  final _xCtrl = TextEditingController();
  final _zCtrl = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _dataList = [];
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final res = await Supabase.instance.client
          .from('offset_db')
          .select()
          .order('tool');
      setState(() {
        _dataList = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      debugPrint('Error fetch: $e');
    }
  }

  Future<void> _simpanData() async {
    if (_typeCtrl.text.isEmpty || _toolCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipe dan Tool wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      
      final payload = {
        'type': _typeCtrl.text.toUpperCase(),
        'op': _opCtrl.text.toUpperCase(),
        'tool': _toolCtrl.text.toUpperCase(),
        'x': double.tryParse(_xCtrl.text) ?? 0,
        'z': double.tryParse(_zCtrl.text) ?? 0,
      };

      if (_editingId != null) {
        // Mode Edit
        await supabase.from('offset_db').update(payload).eq('id', _editingId!);
      } else {
        // Mode Insert
        await supabase.from('offset_db').insert({
          'id': 'id${DateTime.now().millisecondsSinceEpoch}',
          'line': 1, // Default line 1
          ...payload
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan!')));
        _resetForm();
        _fetchData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hapusData(String id) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text('Hapus Data?', style: TextStyle(color: Colors.white)),
        content: const Text('Data yang dihapus tidak bisa dikembalikan.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.from('offset_db').delete().eq('id', id);
        _fetchData();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data dihapus!')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  void _editData(Map<String, dynamic> data) {
    setState(() {
      _editingId = data['id'];
      _typeCtrl.text = data['type'];
      _opCtrl.text = data['op'];
      _toolCtrl.text = data['tool'];
      _xCtrl.text = data['x'].toString();
      _zCtrl.text = data['z'].toString();
    });
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _typeCtrl.clear();
      _opCtrl.clear();
      _toolCtrl.clear();
      _xCtrl.clear();
      _zCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('KELOLA DATA OFFSET'),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_editingId != null)
            TextButton(
              onPressed: _resetForm,
              child: const Text('BATAL EDIT', style: TextStyle(color: Colors.redAccent)),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editingId != null ? 'EDIT DATA' : 'INPUT DATA MANUAL', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildField('Tipe Master / Target', _typeCtrl),
            _buildField('OP (Contoh: OP10)', _opCtrl),
            _buildField('Tool (Contoh: T01)', _toolCtrl),
            Row(
              children: [
                Expanded(child: _buildField('Nilai X', _xCtrl, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Nilai Z', _zCtrl, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true))),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(_editingId != null ? 'UPDATE DATA' : 'SIMPAN DATA', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white12),
            const SizedBox(height: 10),
            Text('LIST DATA', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ..._dataList.map((d) => _buildDataItem(d)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(Map<String, dynamic> d) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${d['tool']} (${d['type']})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('X: ${d['x']} | Z: ${d['z']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _editData(d)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => _hapusData(d['id'])),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: goldColor)),
        ),
      ),
    );
  }
}
