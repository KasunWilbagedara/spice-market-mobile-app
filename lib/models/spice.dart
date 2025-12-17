class Spice {
  final String id;
  final String name;
  final double price;
  final String sellerId;
  final String? description;
  final String? category;

  Spice({required this.id, required this.name, required this.price, required this.sellerId, this.description, this.category});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'sellerId': sellerId,
        'description': description,
        'category': category,
      };

  @override
  String toString() => 'Spice{id: $id, name: $name, price: $price}';
}
