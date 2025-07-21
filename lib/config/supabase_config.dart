import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ihoumeuczixerqaybris.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlob3VtZXVjeml4ZXJxYXlicmlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1OTgxMjMsImV4cCI6MjA2ODE3NDEyM30.A8432hudc8fk0AW_70_IZMGM_wiqFgCqf2sikN3C7Fg';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
