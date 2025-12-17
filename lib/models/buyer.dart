import 'user.dart';

class Buyer extends User {
  List<String> cartItems;

  Buyer({required super.id, required super.name, required super.email, required super.password, List<String>? cartItems})
      : cartItems = cartItems ?? [],
        super(role: 'buyer');

  void addToCart(String item) => cartItems.add(item);
  void removeFromCart(String item) => cartItems.remove(item);

  @override
  String toString() => 'Buyer{${super.toString()}, cartItems: $cartItems}';
}
