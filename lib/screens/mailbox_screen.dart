import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MailboxScreen extends StatefulWidget {
  const MailboxScreen({super.key});

  @override
  State<MailboxScreen> createState() => _MailboxScreenState();
}

class _MailboxScreenState extends State<MailboxScreen> {
  final Color goldColor = const Color(0xFFF5C451);
  final Color bgColor = const Color(0xFF070B1C);
  final Color cardColor = const Color(0xFF0E1738);

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final res = await Supabase.instance.client
          .from('app_messages')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _messages = List<Map<String, dynamic>>.from(res);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('KOTAK PESAN', style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: goldColor)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5C451)))
          : _messages.isEmpty
              ? const Center(child: Text('Belum ada pesan', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: goldColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mail, color: Color(0xFFF5C451), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  msg['title'] ?? 'Tanpa Judul',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            msg['body'] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            msg['sender'] ?? 'Admin',
                            style: const TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
