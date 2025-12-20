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

  // Factory constructor to create a Spice with sample reviews and comments
  factory Spice.withSampleData({
    required String id,
    required String name,
    required double price,
    required String sellerId,
    String? description,
    String? category,
    String? imageUrl,
  }) {
    return Spice(
      id: id,
      name: name,
      price: price,
      sellerId: sellerId,
      description: description,
      category: category,
      imageUrl: imageUrl,
      reviews: [
        {
          'userId': 'user1',
          'userName': 'John Doe',
          'rating': 5,
          'comment': 'Excellent quality spice! Highly recommended.',
          'date': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
          'helpful': 12,
          'daysAgo': '5 days ago',
        },
        {
          'userId': 'user2',
          'userName': 'Sarah Smith',
          'rating': 4,
          'comment': 'Great flavor and aroma. Packaging could be better.',
          'date': DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
          'helpful': 8,
          'daysAgo': '10 days ago',
        },
        {
          'userId': 'user3',
          'userName': 'Mike Johnson',
          'rating': 5,
          'comment': 'Premium quality, fresh and aromatic.',
          'date': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
          'helpful': 15,
          'daysAgo': '15 days ago',
        },
      ],
      comments: [
        {
          'userId': 'user4',
          'userName': 'Emma Wilson',
          'question': 'Is this organic?',
          'text': 'Is this organic?',
          'answer':
              'Yes, all our spices are 100% organic and sourced from certified farms.',
          'date': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
          'daysAgo': '3 days ago',
        },
        {
          'userId': 'user5',
          'userName': 'David Brown',
          'question': 'What is the expiry date?',
          'text': 'What is the expiry date?',
          'answer':
              'Each pack has a 2-year shelf life from the manufacturing date.',
          'date': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
          'daysAgo': '7 days ago',
        },
      ],
      averageRating: 4.7,
    );
  }

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
