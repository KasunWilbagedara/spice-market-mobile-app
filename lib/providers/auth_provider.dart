import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    final u = await _authService.login(email, password);
    if (u != null) {
      _user = u;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<User> register(String name, String email, String password, String role) async {
    final u = await _authService.register(name, email, password, role);
    _user = u;
    notifyListeners();
    return u;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
