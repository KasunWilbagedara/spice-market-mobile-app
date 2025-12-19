import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  // Initialize auth state (called from splash screen)
  Future<void> initializeAuth() async {
    // In a real app, you would load persisted user data here
    // For now, we'll just mark as initialized
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final u = await _authService.login(email, password);
    if (u != null) {
      _user = u;
      // In a real app, save to local storage here
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<User> register(
      String name, String email, String password, String role) async {
    final u = await _authService.register(name, email, password, role);
    _user = u;
    // In a real app, save to local storage here
    notifyListeners();
    return u;
  }

  void logout() {
    _user = null;
    // In a real app, clear local storage here
    notifyListeners();
  }
}
