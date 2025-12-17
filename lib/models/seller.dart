import 'user.dart';

class Seller extends User {
  List<String> listedSpices;

  Seller({required super.id, required super.name, required super.email, required super.password, List<String>? listedSpices})
      : listedSpices = listedSpices ?? [],
        super(role: 'seller');

  void addSpice(String spice) => listedSpices.add(spice);
  void removeSpice(String spice) => listedSpices.remove(spice);

  @override
  String toString() => 'Seller{${super.toString()}, listedSpices: $listedSpices}';
}
