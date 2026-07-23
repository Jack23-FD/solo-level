import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _localUserKey = 'solo_level_local_user';
  static const String _localSessionKey = 'solo_level_is_logged_in';

  // Current session status
  Future<bool> isLoggedIn() async {
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentSession != null) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_localSessionKey) ?? false;
  }

  // Register user
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      final AuthResponse res = await client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      final user = res.user;
      if (user == null) {
        throw Exception('Registration failed. Please try again.');
      }
      
      // Fetch or initialize profile
      try {
        final profileData = await client.from('profiles').select().eq('id', user.id).single();
        return UserModel.fromJson(profileData);
      } catch (_) {
        final newProfile = UserModel(id: user.id, username: username);
        await client.from('profiles').upsert(newProfile.toJson());
        return newProfile;
      }
    } else {
      // Local Demo mode fallback
      final prefs = await SharedPreferences.getInstance();
      final newId = const Uuid().v4();
      final localUser = UserModel(
        id: newId,
        username: username.isEmpty ? email.split('@').first : username,
        level: 1,
        experience: 250, // Starting bonus XP
      );
      await prefs.setString(_localUserKey, jsonEncode(localUser.toJson()));
      await prefs.setBool(_localSessionKey, true);
      return localUser;
    }
  }

  // Login user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      final AuthResponse res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw Exception('Login failed. Check your credentials.');
      }
      
      try {
        final profileData = await client.from('profiles').select().eq('id', user.id).single();
        return UserModel.fromJson(profileData);
      } catch (_) {
        final username = (user.userMetadata?['username'] as String?) ?? email.split('@').first;
        final newProfile = UserModel(id: user.id, username: username);
        await client.from('profiles').upsert(newProfile.toJson());
        return newProfile;
      }
    } else {
      // Local Demo mode fallback
      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString(_localUserKey);
      UserModel userModel;
      if (existingJson != null) {
        userModel = UserModel.fromJson(jsonDecode(existingJson));
      } else {
        userModel = UserModel(
          id: const Uuid().v4(),
          username: email.split('@').first,
          level: 1,
          experience: 250,
        );
        await prefs.setString(_localUserKey, jsonEncode(userModel.toJson()));
      }
      await prefs.setBool(_localSessionKey, true);
      return userModel;
    }
  }

  // Fetch Current Profile
  Future<UserModel?> getProfile() async {
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      final user = client.auth.currentUser!;
      try {
        final profileData = await client.from('profiles').select().eq('id', user.id).single();
        return UserModel.fromJson(profileData);
      } catch (_) {
        final username = (user.userMetadata?['username'] as String?) ?? user.email?.split('@').first ?? 'Shadow Hunter';
        final newProfile = UserModel(id: user.id, username: username);
        await client.from('profiles').upsert(newProfile.toJson());
        return newProfile;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_localUserKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    }
  }

  // Update Profile XP / Level
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      await client.from('profiles').upsert(updatedUser.toJson());
      return updatedUser;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localUserKey, jsonEncode(updatedUser.toJson()));
      return updatedUser;
    }
  }

  // Sign out
  Future<void> logout() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      await client.auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localSessionKey, false);
  }
}
