class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'recipientId': recipientId,
        'recipientName': recipientName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };
}

class Conversation {
  final String id;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final List<Message> messages;
  final DateTime lastMessageTime;

  Conversation({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.messages,
    required this.lastMessageTime,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'messages': messages.map((m) => m.toMap()).toList(),
        'lastMessageTime': lastMessageTime.toIso8601String(),
      };
}
