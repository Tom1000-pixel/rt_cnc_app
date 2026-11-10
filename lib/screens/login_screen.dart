import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _isConnectMode = false; // Mode buat masukin kode device
  String? _errorMessage;

  Future<void> _handleAuth() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() { _isLoading = false; _errorMessage = 'Email dan password wajib diisi'; });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      if (_isLoginMode) {
        await supabase.auth.signInWithPassword(email: email, password: password);
      } else {
        final res = await supabase.auth.signUp(email: email, password: password, data: {'name': name});
        if (res.user != null) {
          await supabase.from('app_users').upsert({'id': res.user!.id, 'name': name, 'email': email, 'role': 'operator'});
        }
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() { _errorMessage = e.toString().replaceAll('AuthException', '').trim(); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleConnectCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Kode harus 6 digit');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // Cari bin berdasarkan nama "offset-{code}"
      // Karena JSONBin search by name butuh API key, kita pakai trik nembak ke endpoint baca
      // (Catatan: Di production, lu harus pakai Backend sendiri buat nyimpen mapping kode ke URL)
      
      // SIMULASI (Karena tanpa API Key JSONBin agak ribet):
      // Kita asumsikan kalau kode bener, dia narik data. 
      // Tapi karena ini demo, kita kasih notif aja.
      
      await Future.delayed(const Duration(seconds: 2)); // Simulasi loading
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Connect Code butuh API Key JSONBin. Hubungi Admin.')));
        setState(() { _isConnectMode = false; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'Gagal konek: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFF5C451);
    const bgColor = Color(0xFF0A0E1A);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 340, margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: goldColor.withOpacity(0.2)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 40)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: goldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: goldColor.withOpacity(0.2))),
                  child: const Icon(Icons.analytics_outlined, color: goldColor, size: 32),
                ),
                const SizedBox(height: 20),
                Text('Offset Analyzer Pro', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 5),
                Text('MANUFACTURING INTELLIGENCE', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2)),
                const SizedBox(height: 30),

                if (!_isConnectMode) ...[
                  // Tab Login/Daftar
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF0F1422), borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(child: _buildTabButton('Masuk', true)),
                        Expanded(child: _buildTabButton('Daftar', false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isLoginMode) ...[
                    _buildTextField(_nameController, 'Nama Lengkap', Icons.person),
                    const SizedBox(height: 12),
                  ],
                  _buildTextField(_emailController, 'Email', Icons.email, keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                  const SizedBox(height: 16),
                  // Tombol pindah ke mode connect code
                  TextButton(
                    onPressed: () => setState(() => _isConnectMode = true),
                    child: const Text('Punya kode device? Konek di sini', style: TextStyle(color: Colors.white54, fontSize: 12, decoration: TextDecoration.underline)),
                  ),
                ] else ...[
                  // Tampilan Connect Code
                  Text('Masukkan Kode Koneksi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: goldColor, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: 'XXXXXX',
                      hintStyle: TextStyle(color: goldColor.withOpacity(0.2), fontSize: 24, letterSpacing: 8),
                      filled: true, fillColor: const Color(0xFF141B2B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    maxLength: 6,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => _isConnectMode = false),
                    child: const Text('Kembali ke Login', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_isConnectMode ? _handleConnectCode : _handleAuth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isConnectMode ? Colors.greenAccent : (_isLoginMode ? goldColor : const Color(0xFF10B981)),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(
                            _isConnectMode ? 'HUBUNGKAN' : (_isLoginMode ? 'MASUK' : 'DAFTAR SEKARANG'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isLogin) {
    bool active = _isLoginMode == isLogin;
    return GestureDetector(
      onTap: () => setState(() => _isLoginMode = isLogin),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: active ? (isLogin ? const Color(0xFFF5C451) : const Color(0xFF10B981)) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(text, style: TextStyle(color: active ? Colors.black : Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller, obscureText: isPassword, keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true, fillColor: const Color(0xFF141B2B),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _isLoginMode ? const Color(0xFFF5C451) : const Color(0xFF10B981))),
      ),
    );
  }
}
