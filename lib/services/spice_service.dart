import 'package:uuid/uuid.dart';
import '../models/spice.dart';

class SpiceService {
  final List<Spice> _spices = [];
  final uuid = Uuid();

  SpiceService() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final spices = [
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Cayenne Pepper',
        price: 12.99,
        sellerId: 'seller1',
        description: 'Hot and spicy',
        category: 'Spicy',
      ),
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Turmeric Powder',
        price: 8.99,
        sellerId: 'seller1',
        description: 'Golden yellow color',
        category: 'Mild',
      ),
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Cumin Seeds',
        price: 9.99,
        sellerId: 'seller2',
        description: 'Warm and nutty',
        category: 'Mild',
      ),
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Black Cardamom',
        price: 15.99,
        sellerId: 'seller2',
        description: 'Smoky flavor',
        category: 'Exotic',
      ),
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Cinnamon Sticks',
        price: 11.99,
        sellerId: 'seller1',
        description: 'Sweet and aromatic',
        category: 'Sweet',
      ),
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Red Chili Powder',
        price: 10.99,
        sellerId: 'seller3',
        description: 'Fiery hot',
        category: 'Spicy',
      ),
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Clove Buds',
        price: 14.99,
        sellerId: 'seller2',
        description: 'Strong and pungent',
        category: 'Exotic',
      ),
      Spice.withSampleData(
        id: uuid.v4(),
        name: 'Fennel Seeds',
        price: 9.49,
        sellerId: 'seller3',
        description: 'Sweet licorice taste',
        category: 'Sweet',
      ),
    ];
    _spices.addAll(spices);
  }

  Future<List<Spice>> getAllSpices() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_spices);
  }

  Future<Spice> addSpice(
      {required String name,
      required double price,
      required String sellerId,
      String? description,
      String? category}) async {
    final spice = Spice(
        id: uuid.v4(),
        name: name,
        price: price,
        sellerId: sellerId,
        description: description,
        category: category);
    _spices.add(spice);
    return spice;
  }

  Future<void> removeSpice(String id) async {
    _spices.removeWhere((s) => s.id == id);
  }
}
