import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://tkuwylszkymvdcvcnrwu.supabase.co';
  static const String anonKey =
      'sb_publishable_-lKqWasq6b9czKxYwlN3Uw_YJ4FINj6';

  static Future<void> initialize() async {
    if (url.isEmpty || anonKey.isEmpty) {
      return;
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
}
