import 'package:uuid/uuid.dart';
import '../models/spice.dart';

class SpiceService {
  final List<Spice> _spices = [];
  final uuid = Uuid();

  Future<List<Spice>> getAllSpices() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_spices);
  }

  Future<Spice> addSpice({required String name, required double price, required String sellerId, String? description, String? category}) async {
    final spice = Spice(id: uuid.v4(), name: name, price: price, sellerId: sellerId, description: description, category: category);
    _spices.add(spice);
    return spice;
  }

  Future<void> removeSpice(String id) async {
    _spices.removeWhere((s) => s.id == id);
  }
}
