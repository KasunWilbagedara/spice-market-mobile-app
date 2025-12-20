import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/order.dart' as order_models;
import '../models/spice.dart';
import '../models/message.dart' as msg;

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============== IMAGE STORAGE ==============

  /// Upload spice image to Firebase Storage
  static Future<String> uploadSpiceImage(File imageFile, String spiceId) async {
    try {
      print('📸 Uploading image for spice: $spiceId');

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'spices/$spiceId/$timestamp.jpg';

      // Upload file to Firebase Storage
      final ref = _storage.ref(fileName);
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Image uploaded successfully: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // ============== USERS ==============

  /// Save user profile to Firestore
  static Future<void> saveUserProfile(
      String userId, String name, String email, String role) async {
    try {
      print('💾 Saving user profile: $userId');
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ User profile saved to Firestore');
    } catch (e) {
      print('❌ Failed to save user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('❌ Failed to get user profile: $e');
      return null;
    }
  }

  // ============== SPICES (PRODUCTS) ==============

  /// Add a new spice/product by seller
  static Future<String> addSpice(Spice spice) async {
    try {
      final docRef = await _firestore.collection('spices').add({
        'id': spice.id,
        'name': spice.name,
        'description': spice.description ?? '',
        'price': spice.price,
        'category': spice.category ?? '',
        'sellerId': spice.sellerId,
        'imageUrl': spice.imageUrl ?? '',
        'averageRating': spice.averageRating,
        'reviews': spice.reviews,
        'comments': spice.comments,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add spice: $e');
    }
  }

  /// Get all spices (for buyer to browse)
  static Stream<List<Spice>> getAllSpices() {
    return _firestore.collection('spices').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Spice(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          sellerId: data['sellerId'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
          reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
          comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
        );
      }).toList();
    });
  }

  /// Get spices by seller
  static Stream<List<Spice>> getSellerSpices(String sellerId) {
    return _firestore
        .collection('spices')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Spice(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          sellerId: data['sellerId'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
          reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
          comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
        );
      }).toList();
    });
  }

  /// Update spice
  static Future<void> updateSpice(String docId, Spice spice) async {
    try {
      await _firestore.collection('spices').doc(docId).update({
        'name': spice.name,
        'description': spice.description,
        'price': spice.price,
        'category': spice.category,
        'imageUrl': spice.imageUrl,
        'averageRating': spice.averageRating,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update spice: $e');
    }
  }

  /// Delete spice
  static Future<void> deleteSpice(String docId) async {
    try {
      await _firestore.collection('spices').doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete spice: $e');
    }
  }

  // ============== ORDERS ==============

  /// Create order when buyer buys
  static Future<String> createOrder(order_models.Order order) async {
    try {
      final docRef = await _firestore.collection('orders').add({
        'id': order.id,
        'buyerId': order.buyerId,
        'items': order.items,
        'totalAmount': order.totalAmount,
        'billingDetails': {
          'fullName': order.billingDetails.fullName,
          'email': order.billingDetails.email,
          'phoneNumber': order.billingDetails.phoneNumber,
          'address': order.billingDetails.address,
          'city': order.billingDetails.city,
          'state': order.billingDetails.state,
          'zipCode': order.billingDetails.zipCode,
          'bankAccountName': order.billingDetails.bankAccountName,
          'bankAccountNumber': order.billingDetails.bankAccountNumber,
          'bankName': order.billingDetails.bankName,
          'ifscCode': order.billingDetails.ifscCode,
        },
        'orderDate': order.orderDate.toIso8601String(),
        'status': order.status,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Create notifications for each seller whose products are in the order with detailed buyer info
      final Map<String, List<Map<String, dynamic>>> sellerItems = {};

      // Group items by seller
      for (var item in order.items) {
        final sellerId = item['sellerId'] as String?;
        if (sellerId != null && sellerId.isNotEmpty) {
          if (!sellerItems.containsKey(sellerId)) {
            sellerItems[sellerId] = [];
          }
          sellerItems[sellerId]!.add(item);
        }
      }

      // Create detailed notification for each seller
      for (var entry in sellerItems.entries) {
        final sellerId = entry.key;
        final items = entry.value;

        try {
          // Build item details string
          final itemDetails = items.map((item) {
            final name = item['name'] ?? 'Unknown';
            final quantity = item['quantity'] ?? 1;
            return '$name (Qty: $quantity)';
          }).join(', ');

          final title = '🛒 New Order Received!';
          final body = '''
Order Details:
━━━━━━━━━━━━━━━━━━━━━━
📦 Items: $itemDetails

👤 Buyer: ${order.billingDetails.fullName}
📧 Email: ${order.billingDetails.email}
📱 Phone: ${order.billingDetails.phoneNumber}
📍 Address: ${order.billingDetails.address}, ${order.billingDetails.city}

💰 Total: ₹${order.totalAmount.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━━━━━━━
''';

          await _firestore.collection('notifications').add({
            'userId': sellerId,
            'title': title,
            'body': body,
            'type': 'order_received',
            'orderId': docRef.id,
            'buyerId': order.buyerId,
            'buyerName': order.billingDetails.fullName,
            'buyerEmail': order.billingDetails.email,
            'buyerPhone': order.billingDetails.phoneNumber,
            'orderAmount': order.totalAmount,
            'itemCount': items.length,
            'timestamp': DateTime.now().toIso8601String(),
            'read': false,
          });

          print(
              '✅ Detailed notification created for seller: $sellerId with ${items.length} items');
        } catch (e) {
          print('⚠️ Failed to create notification for seller $sellerId: $e');
        }
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get orders for buyer
  static Stream<List<order_models.Order>> getBuyerOrders(String buyerId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final billingData = data['billingDetails'] as Map<String, dynamic>;
        return order_models.Order(
          id: data['id'] ?? '',
          buyerId: data['buyerId'] ?? '',
          items: List<Map<String, dynamic>>.from(data['items'] ?? []),
          totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
          billingDetails: order_models.BillingDetails(
            fullName: billingData['fullName'] ?? '',
            email: billingData['email'] ?? '',
            phoneNumber: billingData['phoneNumber'] ?? '',
            address: billingData['address'] ?? '',
            city: billingData['city'] ?? '',
            state: billingData['state'] ?? '',
            zipCode: billingData['zipCode'] ?? '',
            bankAccountName: billingData['bankAccountName'] ?? '',
            bankAccountNumber: billingData['bankAccountNumber'] ?? '',
            bankName: billingData['bankName'] ?? '',
            ifscCode: billingData['ifscCode'] ?? '',
          ),
          orderDate: DateTime.parse(
              data['orderDate'] ?? DateTime.now().toIso8601String()),
          status: data['status'] ?? 'pending',
        );
      }).toList();
    });
  }

  /// Get orders for seller (to see who bought their items)
  static Stream<List<order_models.Order>> getSellerOrders(String sellerId) {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final billingData = data['billingDetails'] as Map<String, dynamic>;
            return order_models.Order(
              id: data['id'] ?? '',
              buyerId: data['buyerId'] ?? '',
              items: List<Map<String, dynamic>>.from(data['items'] ?? []),
              totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
              billingDetails: order_models.BillingDetails(
                fullName: billingData['fullName'] ?? '',
                email: billingData['email'] ?? '',
                phoneNumber: billingData['phoneNumber'] ?? '',
                address: billingData['address'] ?? '',
                city: billingData['city'] ?? '',
                state: billingData['state'] ?? '',
                zipCode: billingData['zipCode'] ?? '',
                bankAccountName: billingData['bankAccountName'] ?? '',
                bankAccountNumber: billingData['bankAccountNumber'] ?? '',
                bankName: billingData['bankName'] ?? '',
                ifscCode: billingData['ifscCode'] ?? '',
              ),
              orderDate: DateTime.parse(
                  data['orderDate'] ?? DateTime.now().toIso8601String()),
              status: data['status'] ?? 'pending',
            );
          })
          .where((order) =>
              order.items.any((item) => item['sellerId'] == sellerId))
          .toList();
    });
  }

  /// Update order status
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // ============== MESSAGES/CHAT ==============

  /// Send message between buyer and seller
  static Future<void> sendMessage(
    String senderId,
    String senderName,
    String receiverId,
    String receiverName,
    String message,
  ) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'recipientName': receiverName,
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get conversation between buyer and seller
  static Stream<List<msg.Message>> getConversation(
    String userId1,
    String userId2,
  ) {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [userId1, userId2])
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data();
            final senderId = data['senderId'];
            final receiverId = data['receiverId'];
            return (senderId == userId1 && receiverId == userId2) ||
                (senderId == userId2 && receiverId == userId1);
          }).map((doc) {
            final data = doc.data();
            return msg.Message(
              id: doc.id,
              senderId: data['senderId'] ?? '',
              senderName: data['senderName'] ?? '',
              recipientId: data['receiverId'] ?? '',
              recipientName: data['recipientName'] ?? '',
              content: data['content'] ?? '',
              timestamp: DateTime.parse(
                  data['timestamp'] ?? DateTime.now().toIso8601String()),
              isRead: data['isRead'] ?? false,
            );
          }).toList();
        });
  }

  /// Get all conversations for a seller (messages received from buyers)
  static Stream<List<msg.Message>> getSellerConversations(String sellerId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: sellerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return msg.Message(
          id: doc.id,
          senderId: data['senderId'] ?? '',
          senderName: data['senderName'] ?? '',
          recipientId: data['receiverId'] ?? '',
          recipientName: data['recipientName'] ?? '',
          content: data['content'] ?? '',
          timestamp: DateTime.parse(
              data['timestamp'] ?? DateTime.now().toIso8601String()),
          isRead: data['isRead'] ?? false,
        );
      }).toList();
    });
  }

  /// Get all unread messages for user
  static Stream<int> getUnreadMessageCount(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead(String userId) async {
    try {
      final query = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in query.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // ============== NOTIFICATIONS ==============

  /// Create notification when order is received
  static Future<void> createNotification(
    String userId,
    String title,
    String body,
    String type, // 'order_received', 'order_shipped', 'message'
  ) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Get notifications for user
  static Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'title': doc['title'],
                'body': doc['body'],
                'type': doc['type'],
                'timestamp': doc['timestamp'],
                'read': doc['read'],
              })
          .toList();
    });
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // ============== USER DATA ==============

  /// Save user data to Firestore
  static Future<void> saveUserData(
      String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Get user stream
  static Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Get seller name by seller ID
  static Future<String> getSellerName(String sellerId) async {
    try {
      final doc = await _firestore.collection('users').doc(sellerId).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Unknown Seller';
      }
      return 'Unknown Seller';
    } catch (e) {
      print('Error getting seller name: $e');
      return 'Unknown Seller';
    }
  }
}
