import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../models/message.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';

class MessageScreenArguments {
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;

  MessageScreenArguments({
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
  });
}

class MessagingScreen extends StatefulWidget {
  final MessageScreenArguments args;

  const MessagingScreen({required this.args, super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final uuid = Uuid();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add sample messages for demo
    _addSampleMessages();
  }

  void _addSampleMessages() {
    _messages.addAll([
      Message(
        id: uuid.v4(),
        senderId: widget.args.sellerId,
        senderName: widget.args.sellerName,
        recipientId: widget.args.buyerId,
        recipientName: widget.args.buyerName,
        content: 'Hello! Thanks for your interest in our products.',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        isRead: true,
      ),
      Message(
        id: uuid.v4(),
        senderId: widget.args.buyerId,
        senderName: widget.args.buyerName,
        recipientId: widget.args.sellerId,
        recipientName: widget.args.sellerName,
        content: 'Hi! I have a question about the spice quality.',
        timestamp: DateTime.now().subtract(Duration(minutes: 25)),
        isRead: true,
      ),
      Message(
        id: uuid.v4(),
        senderId: widget.args.sellerId,
        senderName: widget.args.sellerName,
        recipientId: widget.args.buyerId,
        recipientName: widget.args.buyerName,
        content:
            'Of course! All our spices are premium quality and sourced directly from farmers.',
        timestamp: DateTime.now().subtract(Duration(minutes: 20)),
        isRead: true,
      ),
    ]);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final buyerId = auth.user?.id ?? widget.args.buyerId;

    final newMessage = Message(
      id: uuid.v4(),
      senderId: buyerId,
      senderName: widget.args.buyerName,
      recipientId: widget.args.sellerId,
      recipientName: widget.args.sellerName,
      content: messageText,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // Save message to Firebase
    try {
      print('💬 Saving message to Firebase...');
      await FirebaseService.sendMessage(
        buyerId,
        widget.args.buyerName,
        widget.args.sellerId,
        widget.args.sellerName,
        messageText,
      );
      print('✅ Message saved to Firebase');
    } catch (e) {
      print('❌ Failed to save message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Colors.red),
      );
    }

    // Scroll to bottom
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.args.sellerName,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Online',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Color(0xFF1B5E4B),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isSender = message.senderId == widget.args.buyerId;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSender ? Color(0xFF1B5E4B) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: isSender
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSender
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            padding: EdgeInsets.all(12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1B5E4B),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
