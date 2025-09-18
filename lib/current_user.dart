// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Currentuser extends ChangeNotifier {
  static final Currentuser instance = Currentuser._internal();

  String? id;
  String? email;
  String? username;
  String? bio;
  DateTime? created_at;

  Currentuser._internal();

  Future<void> loadUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('No user logged in');
      return;
    }
    final id = user.id;
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .eq('user_id', id)
          .single();
      print('Supabase response: $response');

      this.id = response['user_id'] as String?;
      email = response['email'] as String?;
      username = response['username'] as String?;
      bio = response['bio'] as String?;
      final createdAt = response['created_at'] as String?;
      if (createdAt != null) {
        created_at = DateTime.parse(createdAt);
      }
      notifyListeners();
    } catch (e, stack) {
      print('Error loading user info: $e');
      print('Stack trace: $stack');
    }
  }
}
