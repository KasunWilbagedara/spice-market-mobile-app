class Spice {
  final String id;
  final String name;
  final double price;
  final String sellerId;
  final String? description;
  final String? category;
  final String? imageUrl;
  final List<Map<String, dynamic>> reviews;
  final List<Map<String, dynamic>> comments;
  final double averageRating;

  Spice({
    required this.id,
    required this.name,
    required this.price,
    required this.sellerId,
    this.description,
    this.category,
    this.imageUrl,
    this.reviews = const [],
    this.comments = const [],
    this.averageRating = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'sellerId': sellerId,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'reviews': reviews,
        'comments': comments,
        'averageRating': averageRating,
      };

  @override
  String toString() => 'Spice{id: $id, name: $name, price: $price}';
}
