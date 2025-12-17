import 'package:flutter/material.dart';
import '../models/spice.dart';
import '../services/spice_service.dart';

class SpiceProvider with ChangeNotifier {
  final SpiceService _service = SpiceService();
  List<Spice> _spices = [];

  List<Spice> get spices => _spices;

  Future<void> loadSpices() async {
    _spices = await _service.getAllSpices();
    notifyListeners();
  }

  Future<void> addSpice(Spice s) async {
    await _service.addSpice(name: s.name, price: s.price, sellerId: s.sellerId, description: s.description, category: s.category);
    await loadSpices();
  }

  Future<void> removeSpice(String id) async {
    await _service.removeSpice(id);
    await loadSpices();
  }
}
