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

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localSessionKey, true);
    await prefs.setString(_localUserKey, jsonEncode(user.toJson()));
  }

  // Register user
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final AuthResponse res = await client.auth.signUp(
          email: email,
          password: password,
          data: {'username': username},
        );
        final user = res.user;
        if (user == null) {
          throw Exception('Registration failed. Please try again.');
        }

        UserModel profile;
        try {
          final profileData = await client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single()
              .timeout(const Duration(seconds: 5));
          profile = UserModel.fromJson(profileData);
        } catch (_) {
          profile = UserModel(id: user.id, username: username);
          await client.from('profiles').upsert(profile.toJson()).timeout(const Duration(seconds: 5));
        }
        await _saveSession(profile);
        return profile;
      } on AuthException catch (e) {
        final isUnconfirmed = e.code == 'email_not_confirmed' ||
            e.message.toLowerCase().contains('email not confirmed');
        final isRateLimit =
            e.code == 'over_email_send_rate_limit' || e.statusCode == '429';
        if (isUnconfirmed || isRateLimit) {
          return _registerLocally(email: email, username: username);
        }
        rethrow;
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('SocketException') ||
            errStr.contains('Failed host lookup') ||
            errStr.contains('ClientException')) {
          return _registerLocally(email: email, username: username);
        }
        rethrow;
      }
    } else {
      return _registerLocally(email: email, username: username);
    }
  }

  // Local mode registration helper
  Future<UserModel> _registerLocally({
    required String email,
    required String username,
  }) async {
    final newId = const Uuid().v4();
    final localUser = UserModel(
      id: newId,
      username: username.isEmpty ? email.split('@').first : username,
      level: 1,
      experience: 250, // Starting bonus XP
    );
    await _saveSession(localUser);
    return localUser;
  }

  // Login user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final AuthResponse res = await client.auth
            .signInWithPassword(
              email: email,
              password: password,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw Exception('Login timed out. Check your connection.'),
            );
        final user = res.user;
        if (user == null) {
          throw Exception('Login failed. Check your credentials.');
        }

        UserModel profile;
        try {
          final profileData = await client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single()
              .timeout(const Duration(seconds: 5));
          profile = UserModel.fromJson(profileData);
        } catch (_) {
          final username =
              (user.userMetadata?['username'] as String?) ??
              email.split('@').first;
          profile = UserModel(id: user.id, username: username);
          await client.from('profiles').upsert(profile.toJson()).timeout(const Duration(seconds: 5));
        }
        await _saveSession(profile);
        return profile;
      } on AuthException catch (e) {
        final isUnconfirmed = e.code == 'email_not_confirmed' ||
            e.message.toLowerCase().contains('email not confirmed');
        final isRateLimit =
            e.code == 'over_email_send_rate_limit' || e.statusCode == '429';
        if (isUnconfirmed || isRateLimit) {
          return _loginLocally(email: email);
        }
        rethrow;
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('SocketException') ||
            errStr.contains('Failed host lookup') ||
            errStr.contains('ClientException') ||
            errStr.contains('timed out')) {
          return _loginLocally(email: email);
        }
        rethrow;
      }
    } else {
      return _loginLocally(email: email);
    }
  }

  Future<UserModel> _loginLocally({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_localUserKey);
    if (userJson != null) {
      await prefs.setBool(_localSessionKey, true);
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return _registerLocally(email: email, username: email.split('@').first);
  }

  // Fetch Current Profile
  Future<UserModel?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final localJson = prefs.getString(_localUserKey);
    UserModel? localProfile;
    if (localJson != null) {
      try {
        localProfile = UserModel.fromJson(jsonDecode(localJson));
      } catch (_) {}
    }

    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      final user = client.auth.currentUser!;
      try {
        final profileData = await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single()
            .timeout(const Duration(seconds: 3));
        final remoteProfile = UserModel.fromJson(profileData);

        // Keep whichever profile has higher level/experience to prevent level resets
        UserModel merged = remoteProfile;
        if (localProfile != null) {
          int localTotalXp = (localProfile.level * 1000) + localProfile.experience;
          int remoteTotalXp = (remoteProfile.level * 1000) + remoteProfile.experience;
          if (localTotalXp > remoteTotalXp) {
            merged = localProfile;
            try {
              client.from('profiles').upsert(localProfile.toJson());
            } catch (_) {}
          }
        }
        await prefs.setString(_localUserKey, jsonEncode(merged.toJson()));
        return merged;
      } catch (_) {
        if (localProfile != null) {
          return localProfile;
        }
        final username = (user.userMetadata?['username'] as String?) ??
            user.email?.split('@').first ??
            'Shadow Hunter';
        final newProfile = UserModel(id: user.id, username: username, level: 1, experience: 250);
        await prefs.setString(_localUserKey, jsonEncode(newProfile.toJson()));
        try {
          await client.from('profiles').upsert(newProfile.toJson()).timeout(const Duration(seconds: 5));
        } catch (_) {}
        return newProfile;
      }
    } else {
      return localProfile;
    }
  }

  // Update Profile XP / Level
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    // 1. ALWAYS persist to local disk immediately so level and XP are never lost
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUserKey, jsonEncode(updatedUser.toJson()));

    // 2. Sync to Supabase in background
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client
            .from('profiles')
            .update(updatedUser.toJson())
            .eq('id', updatedUser.id)
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        try {
          await client.from('profiles').upsert(updatedUser.toJson()).timeout(const Duration(seconds: 5));
        } catch (_) {}
      }
    }
    return updatedUser;
  }

  // Reset User Level & XP back to Level 1 (0 XP) for Day 1 Fresh Start
  Future<UserModel> resetUserXpToDayOne(UserModel currentUser) async {
    final resetUser = currentUser.copyWith(
      level: 1,
      experience: 0,
    );

    // Save to local SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUserKey, jsonEncode(resetUser.toJson()));

    // Force update Supabase profiles table synchronously
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client
            .from('profiles')
            .update({'level': 1, 'experience': 0})
            .eq('id', currentUser.id)
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        try {
          await client.from('profiles').upsert(resetUser.toJson()).timeout(const Duration(seconds: 5));
        } catch (_) {}
      }
    }
    return resetUser;
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
