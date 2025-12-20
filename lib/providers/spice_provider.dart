import 'package:flutter/material.dart';
import 'dart:async';
import '../models/spice.dart';
import '../services/firebase_service.dart';

class SpiceProvider with ChangeNotifier {
  List<Spice> _spices = [];
  StreamSubscription? _spicesSubscription;

  SpiceProvider() {
    // Initialize and load spices when provider is created
    _initializeSpices();
  }

  List<Spice> get spices => _spices;

  void _initializeSpices() {
    print('🔄 Initializing SpiceProvider - loading spices from Firebase');
    loadSpices();
  }

  void loadSpices() {
    try {
      print('📥 Loading spices from Firebase...');
      // Cancel previous subscription if any
      _spicesSubscription?.cancel();
      // Listen to real-time updates from Firebase
      _spicesSubscription = FirebaseService.getAllSpices().listen((spices) {
        _spices = spices;
        notifyListeners();
        print('✅ Spices loaded from Firebase: ${spices.length} items');
      }, onError: (error) {
        print('❌ Error listening to spices: $error');
      });
    } catch (e) {
      print('❌ Error loading spices: $e');
    }
  }

  Future<void> addSpice(Spice spice) async {
    try {
      print('➕ Adding spice to Firebase: ${spice.name}');
      await FirebaseService.addSpice(spice);
      print('✅ Spice added to Firebase');
      // Reload spices to get the updated list
      await Future.delayed(Duration(milliseconds: 500));
      loadSpices();
    } catch (e) {
      print('❌ Error adding spice: $e');
      rethrow;
    }
  }

  Future<void> removeSpice(String id) async {
    try {
      print('🗑️ Removing spice: $id');
      // Remove from Firestore
      _spices.removeWhere((s) => s.id == id);
      notifyListeners();
      print('✅ Spice removed');
    } catch (e) {
      print('❌ Error removing spice: $e');
    }
  }

  @override
  void dispose() {
    // Cancel subscription when provider is disposed
    _spicesSubscription?.cancel();
    super.dispose();
  }
}
