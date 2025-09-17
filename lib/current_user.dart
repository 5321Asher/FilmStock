// ignore_for_file: non_constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';

class Currentuser {
  static final Currentuser instance = Currentuser._internal();

  String? id;
  String? email;
  String? username;
  String? bio;
  DateTime? created_at;

  Currentuser._internal();

  Future<void> loadUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    final id = user?.id;

    if (id != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .eq('user_id', id)
          .single();

      email = response['email'] as String?;
      username = response['username'] as String?;
      bio = response['bio'] as String?;
      created_at = DateTime.parse(response['created_at'] as String);
      //print(username);
    }
  }
}
