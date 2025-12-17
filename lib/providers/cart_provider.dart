import 'package:flutter/material.dart';
import '../models/spice.dart';

class CartProvider with ChangeNotifier {
  final List<Spice> _items = [];
  List<Spice> get items => List.unmodifiable(_items);

  // Backwards-compatible aliases expected by callers
  List<Spice> get cartItems => items;

  void addToCart(Spice s) => add(s);

  void removeFromCart(Spice s) => remove(s);

  void add(Spice s) {
    _items.add(s);
    notifyListeners();
  }

  void remove(Spice s) {
    _items.remove(s);
    notifyListeners();
  }

  double get total => _items.fold(0, (v, s) => v + s.price);
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
