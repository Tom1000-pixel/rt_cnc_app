import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static Future<String> getUserRole() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return 'guest';

      final res = await Supabase.instance.client
          .from('app_users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (res != null && res['role'] != null) {
        return res['role'].toString();
      }
      return 'operator'; // Default kalau belum ada di tabel
    } catch (e) {
      return 'operator';
    }
  }
}
