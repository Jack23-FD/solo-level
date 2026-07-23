import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://frhulkngqcooojxjsxji.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZyaHVsa25ncWNvb29qeGpzeGppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3MzgzNDQsImV4cCI6MjEwMDMxNDM0NH0.GVrfEzn7ROozsWa7hFmp5pNvnPc6wMPU5EpiYdrOc08';

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  static Future<void> init() async {
    if (!isConfigured) {
      debugPrint('[Solo-Level] Supabase credentials not set. Running in Local Demo Mode.');
      return;
    }
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
      debugPrint('[Solo-Level] Supabase initialized successfully.');
    } catch (e) {
      debugPrint('[Solo-Level] Supabase initialization error: $e');
    }
  }

  static SupabaseClient? get client {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
