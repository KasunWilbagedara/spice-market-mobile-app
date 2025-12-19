class Review {
  final String id;
  final String spiceId;
  final String userId;
  final String userName;
  final double rating; // 1-5
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.spiceId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'spiceId': spiceId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  String toString() => 'Review{id: $id, spiceId: $spiceId, rating: $rating}';
}
