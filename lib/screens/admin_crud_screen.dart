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

  Future<void> _simpanData() async {
    if (_typeCtrl.text.isEmpty || _toolCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipe dan Tool wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      
      final existing = await supabase
          .from('offset_db')
          .select('id')
          .eq('line', 1)
          .eq('type', _typeCtrl.text.toUpperCase())
          .eq('op', _opCtrl.text.toUpperCase())
          .eq('tool', _toolCtrl.text.toUpperCase());

      if ((existing as List).isNotEmpty) {
        await supabase.from('offset_db').update({
          'x': double.tryParse(_xCtrl.text) ?? 0,
          'z': double.tryParse(_zCtrl.text) ?? 0,
        }).eq('id', existing[0]['id']);
      } else {
        await supabase.from('offset_db').insert({
          'id': 'id${DateTime.now().millisecondsSinceEpoch}',
          'line': 1,
          'type': _typeCtrl.text.toUpperCase(),
          'op': _opCtrl.text.toUpperCase(),
          'tool': _toolCtrl.text.toUpperCase(),
          'x': double.tryParse(_xCtrl.text) ?? 0,
          'z': double.tryParse(_zCtrl.text) ?? 0,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan!')));
        _typeCtrl.clear();
        _opCtrl.clear();
        _toolCtrl.clear();
        _xCtrl.clear();
        _zCtrl.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('KELOLA DATA OFFSET'),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INPUT DATA MANUAL', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildField('Tipe Master / Target', _typeCtrl),
            _buildField('OP (Contoh: OP10)', _opCtrl),
            _buildField('Tool (Contoh: T01)', _toolCtrl),
            _buildField('Nilai X', _xCtrl, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true)),
            _buildField('Nilai Z', _zCtrl, keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true)),
            const SizedBox(height: 20),
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
                  : const Text('SIMPAN DATA', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
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
