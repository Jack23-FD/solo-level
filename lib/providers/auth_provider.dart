import 'package:flutter/foundation.dart';
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

  // Initialize and check current session
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await _authService.getProfile();
      }
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    notifyListeners();
    try {
      _currentUser = await _authService.register(
        email: email,
        password: password,
        username: username,
      );
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
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
    notifyListeners();

    try {
      await _authService.updateProfile(updated);
    } catch (_) {}

    return didLevelUp;
  }
}
