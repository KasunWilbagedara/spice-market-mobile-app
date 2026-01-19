import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  // Initialize auth state
  Future<void> initializeAuth() async {
    try {
      // Check if user is already logged in via Firebase
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('🔄 Restoring Firebase session for: ${currentUser.email}');

        // Get full user data from Firestore
        final userDoc = await _authService.getCurrentUserData(currentUser.uid);
        if (userDoc != null) {
          _user = User(
            id: currentUser.uid,
            name: userDoc['name'] ?? 'User',
            email: userDoc['email'] ?? '',
            password: '',
            role: userDoc['role'] ?? 'buyer',
          );
          print('✅ User session restored: ${_user?.name}');
        }
      }
    } catch (e) {
      print('⚠️ Auth restoration failed: $e');
    }
    _isInitialized = true;
    // Defer notification to avoid calling it during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      final u = await _authService.login(email, password);
      if (u != null) {
        _user = u;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }

  Future<User?> register(
      String name, String email, String password, String role) async {
    try {
      final u = await _authService.register(name, email, password, role);
      _user = u;
      notifyListeners();
      return u;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }
}
