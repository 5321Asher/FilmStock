import 'package:supabase_flutter/supabase_flutter.dart';

class Currentuser  {
  static final Currentuser instance = Currentuser._internal();

  String? id;
  String? email;
  String? username;

  Currentuser._internal();

  Future<void> loadUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    id = user?.id;
    email = user?.email;

    if (id != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .eq('user_id', id!)
          .single();
      username = response['username'] as String?;
    }
  
  }
}
