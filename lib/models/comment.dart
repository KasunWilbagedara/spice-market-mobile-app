class Comment {
  final String id;
  final String spiceId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.spiceId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'spiceId': spiceId,
        'userId': userId,
        'userName': userName,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  String toString() =>
      'Comment{id: $id, spiceId: $spiceId, userName: $userName}';
}
