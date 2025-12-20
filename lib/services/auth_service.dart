import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final uuid = Uuid();
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> register(
      String name, String email, String password, String role) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null)
        throw Exception('Failed to create Firebase user');

      print('👤 Creating Firebase user: ${firebaseUser.uid}');

      // Save user data to Firestore
      final user = User(
        id: firebaseUser.uid,
        name: name,
        email: email,
        password: password,
        role: role,
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'id': firebaseUser.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ User saved to Firestore: ${firebaseUser.uid}');
      return user;
    } catch (e) {
      print('❌ Registration failed: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Get user data from Firestore
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) {
        print('❌ User data not found in Firestore');
        return null;
      }

      final userData = doc.data()!;
      print('✅ User logged in: ${firebaseUser.uid}');

      return User(
        id: firebaseUser.uid,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        password: password,
        role: userData['role'] ?? 'buyer',
      );
    } catch (e) {
      print('❌ Login failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('❌ Failed to get user data: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    print('✅ User logged out');
  }
}
