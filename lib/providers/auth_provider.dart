import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _safeNotifyListeners() {
    if (hasListeners) {
      Future.microtask(() => notifyListeners());
    }
  }

  // Initialize and check current session
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _safeNotifyListeners();
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        // Single call with a 5-second timeout — no infinite retry on slow networks
        _currentUser = await _authService.getProfile().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
        if (_currentUser == null) {
          _isLoggedIn = false;
        }
      }
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();
    try {
      _currentUser = await _authService.register(
        email: email,
        password: password,
        username: username,
      ).timeout(const Duration(seconds: 15));
      _isLoggedIn = true;
      return true;
    } on AuthException catch (e) {
      if (e.code == 'over_email_send_rate_limit' || e.statusCode == '429') {
        _errorMessage =
            'Email rate limit exceeded (429). Supabase restricts email frequency on default SMTP. Please wait a few minutes or disable "Confirm email" in Supabase Auth Settings.';
      } else {
        _errorMessage = e.message;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Connection timed out. Check your network or Supabase config.';
      }
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();
    try {
      _currentUser = await _authService.login(email: email, password: password).timeout(const Duration(seconds: 15));
      _isLoggedIn = true;
      return true;
    } on AuthException catch (e) {
      if (e.code == 'over_email_send_rate_limit' || e.statusCode == '429') {
        _errorMessage =
            'Email rate limit exceeded (429). Please wait a few minutes before retrying.';
      } else {
        _errorMessage = e.message;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Connection timed out. Check your network or Supabase config.';
      }
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    _safeNotifyListeners();
    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Award XP and handle Level Up system logic
  // Returns true if a Level Up occurred!
  Future<bool> addXp(int xpGained) async {
    if (_currentUser == null) return false;

    int currentLvl = _currentUser!.level;
    int currentXp = _currentUser!.experience + xpGained;
    bool didLevelUp = false;

    // Check level up threshold
    int requiredXp = currentLvl * 1000;
    while (currentXp >= requiredXp) {
      currentXp -= requiredXp;
      currentLvl += 1;
      didLevelUp = true;
      requiredXp = currentLvl * 1000;
    }

    // Handle case where XP drops below 0 (if task un-completed)
    if (currentXp < 0) {
      if (currentLvl > 1) {
        currentLvl -= 1;
        currentXp = (currentLvl * 1000) + currentXp;
      } else {
        currentXp = 0;
      }
    }

    final updated = _currentUser!.copyWith(
      level: currentLvl,
      experience: currentXp,
    );

    _currentUser = updated;
    _safeNotifyListeners();

    _authService.updateProfile(updated).catchError((_) => updated);

    return didLevelUp;
  }

  // Sync user XP with completed task rewards if user profile is out of sync
  Future<void> syncXpWithCompletedTasks(List<TaskModel> tasks) async {
    if (_currentUser == null) return;

    int totalCompletedTaskXp = 0;
    for (final task in tasks) {
      if (task.isCompleted) {
        totalCompletedTaskXp += task.xpReward;
      }
    }

    int currentStoredTotalXp =
        ((_currentUser!.level - 1) * 1000) + _currentUser!.experience;

    if (totalCompletedTaskXp > currentStoredTotalXp) {
      int newLevel = 1 + (totalCompletedTaskXp ~/ 1000);
      int newXp = totalCompletedTaskXp % 1000;

      final updated = _currentUser!.copyWith(
        level: newLevel,
        experience: newXp,
      );

      _currentUser = updated;
      _safeNotifyListeners();
      await _authService.updateProfile(updated);
    }
  }

  // Reset progress to Level 1, 0 XP for Day 1 fresh start
  Future<void> resetProgressToDayOne() async {
    if (_currentUser == null) return;
    _currentUser = await _authService.resetUserXpToDayOne(_currentUser!);
    _safeNotifyListeners();
  }
}
