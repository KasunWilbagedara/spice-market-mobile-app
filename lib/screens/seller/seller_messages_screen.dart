import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/message.dart';

class SellerMessagesScreen extends StatefulWidget {
  const SellerMessagesScreen({super.key});

  @override
  State<SellerMessagesScreen> createState() => _SellerMessagesScreenState();
}

class _SellerMessagesScreenState extends State<SellerMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final sellerId = auth.user?.id ?? '';

    if (sellerId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Messages'),
          backgroundColor: Colors.orange.shade700,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/seller_home'),
          ),
        ),
        body: Center(
          child: Text('Please log in to view messages'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages & Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/seller_home'),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.orange.shade700,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.orange.shade700,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail),
                      SizedBox(width: 8),
                      Text('Conversations'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications),
                      SizedBox(width: 8),
                      Text('Orders'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Conversations Tab
                  _buildConversationsTab(sellerId),
                  // Notifications Tab
                  _buildOrdersTab(sellerId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsTab(String sellerId) {
    return StreamBuilder<List<Message>>(
      stream: FirebaseService.getSellerConversations(sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 80,
                  color: Colors.orange.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data!;
        // Group messages by sender (buyer)
        final Map<String, List<Message>> groupedMessages = {};
        for (var msg in messages) {
          final buyerId = msg.senderId;
          if (!groupedMessages.containsKey(buyerId)) {
            groupedMessages[buyerId] = [];
          }
          groupedMessages[buyerId]!.add(msg);
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: groupedMessages.length,
          itemBuilder: (context, index) {
            final buyerId = groupedMessages.keys.toList()[index];
            final buyerMessages = groupedMessages[buyerId]!;
            final lastMessage = buyerMessages.last;
            final unreadCount = buyerMessages.where((m) => !m.isRead).length;

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade700,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  lastMessage.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  lastMessage.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                trailing: unreadCount > 0
                    ? Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerConversationScreen(
                        buyerId: buyerId,
                        buyerName: lastMessage.senderName,
                        sellerId: lastMessage.recipientId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrdersTab(String sellerId) {
    return StreamBuilder<List<dynamic>>(
      stream: FirebaseService.getSellerOrders(sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.orange.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade700,
                  child: Icon(Icons.check_circle, color: Colors.white),
                ),
                title: Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '\$${order.totalAmount.toStringAsFixed(2)} • ${order.items.length} items',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order.status == 'completed'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: order.status == 'completed'
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SellerConversationScreen extends StatefulWidget {
  final String buyerId;
  final String buyerName;
  final String sellerId;

  const SellerConversationScreen({
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    super.key,
  });

  @override
  State<SellerConversationScreen> createState() =>
      _SellerConversationScreenState();
}

class _SellerConversationScreenState extends State<SellerConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final sellerName = auth.user?.name ?? 'Seller';
    final messageText = _messageController.text.trim();

    try {
      print('💬 Seller sending message to buyer...');
      await FirebaseService.sendMessage(
        widget.sellerId,
        sellerName,
        widget.buyerId,
        widget.buyerName,
        messageText,
      );
      print('✅ Seller message sent to Firebase');
      _messageController.clear();

      // Scroll to bottom
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('❌ Failed to send message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.buyerName),
        backgroundColor: Colors.orange.shade700,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: FirebaseService.getConversation(
                  widget.buyerId, widget.sellerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Colors.orange.shade700),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: Text('No messages'),
                  );
                }

                final messages = snapshot.data!;

                Future.delayed(Duration(milliseconds: 100), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isSeller = message.senderId == widget.sellerId;

                    return Align(
                      alignment: isSeller
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSeller
                              ? Colors.orange.shade700
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(isSeller ? 16 : 0),
                            bottomRight: Radius.circular(isSeller ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isSeller ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isSeller
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.orange.shade700,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.orange.shade300,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.orange.shade700,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
