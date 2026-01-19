import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' as io;
import 'dart:typed_data' as typed_data;
import '../models/order.dart' as order_models;
import '../models/spice.dart';
import '../models/message.dart' as msg;

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get Firestore instance (for debugging)
  static FirebaseFirestore getFirebaseInstance() => _firestore;

  // ============== IMAGE COMPRESSION ==============

  /// Compress image bytes to reduce file size for faster uploads
  static Future<typed_data.Uint8List> compressImage(
      typed_data.Uint8List imageBytes) async {
    try {
      // For now, just return the original bytes
      // Image compression requires the image package which we'll avoid
      print(
          '⚠️ Using original image size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');

      // Limit file size - if too large, still try to upload but warn user
      if (imageBytes.length > 10 * 1024 * 1024) {
        print('⚠️ Warning: Image is larger than 10MB, upload may take time');
      }

      return imageBytes;
    } catch (e) {
      print('⚠️ Image processing failed, using original: $e');
      return imageBytes;
    }
  }

  // ============== IMAGE STORAGE ==============

  /// Upload spice image to Firebase Storage from XFile (works on Web and native)
  static Future<String> uploadSpiceImageFromXFile(
      dynamic xFile, String spiceId) async {
    try {
      print('📸 Uploading image for spice: $spiceId');

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'spices/$spiceId/$timestamp.jpg';

      // Read file bytes (works on Web and native)
      print('📥 Reading image bytes...');
      var bytes = await xFile.readAsBytes();
      final sizeKB = bytes.length / 1024;
      print('📥 Image size: ${sizeKB.toStringAsFixed(2)} KB');

      // Upload file to Firebase Storage
      print('📤 Uploading to Firebase...');
      final ref = _storage.ref(fileName);

      // putData returns a Future<TaskSnapshot>, not UploadTask
      // We need to await it directly
      final snapshot = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL from the snapshot
      print('🔗 Getting download URL...');
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Image uploaded successfully!');
      print('🔗 Download URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      print('Stack trace: ${e.toString()}');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload spice image to Firebase Storage from file path
  static Future<String> uploadSpiceImageFromPath(
      String imagePath, String spiceId) async {
    try {
      print('📸 Uploading image for spice: $spiceId from path: $imagePath');

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'spices/$spiceId/$timestamp.jpg';

      // Upload file to Firebase Storage
      final ref = _storage.ref(fileName);
      final imageFile = io.File(imagePath);
      final snapshot = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Image uploaded successfully: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload spice image to Firebase Storage
  static Future<String> uploadSpiceImage(
      dynamic imageFile, String spiceId) async {
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
      print('💾 Saving spice to Firestore: ${spice.name}');
      print('📷 Image URL being saved: "${spice.imageUrl}"');
      print('📷 Image URL is null: ${spice.imageUrl == null}');
      print('📷 Image URL is empty: ${spice.imageUrl?.isEmpty ?? "N/A"}');

      final spiceData = {
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
      };

      print('💾 Firestore data imageUrl field: "${spiceData['imageUrl']}"');

      final docRef = await _firestore.collection('spices').add(spiceData);
      print('✅ Spice saved with Firestore ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Failed to add spice: $e');
      throw Exception('Failed to add spice: $e');
    }
  }

  /// Get all spices (for buyer to browse)
  static Stream<List<Spice>> getAllSpices() {
    return _firestore.collection('spices').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('📊 Spice data from Firestore:');
        print('  Name: ${data['name']}');
        print('  ImageURL field value: ${data['imageUrl'] ?? "MISSING"}');
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

  /// Update spice with partial data
  static Future<void> updateSpice(
      String docId, Map<String, dynamic> updateData) async {
    try {
      // Add updatedAt timestamp
      updateData['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('spices').doc(docId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update spice: $e');
    }
  }

  /// Delete spice by spice ID
  static Future<void> deleteSpice(String spiceId) async {
    try {
      // First find the document that has this spice ID
      final querySnapshot = await _firestore
          .collection('spices')
          .where('id', isEqualTo: spiceId)
          .get();

      // Delete all matching documents (should be only 1)
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('✅ Deleted spice document: ${doc.id}');
      }

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ Spice with ID $spiceId not found in Firestore');
      }
    } catch (e) {
      print('❌ Failed to delete spice: $e');
      throw Exception('Failed to delete spice: $e');
    }
  }

  // ============== ORDERS ==============

  /// Helper function to convert Timestamp or String to DateTime
  static DateTime? _convertToDateTime(dynamic value) {
    if (value == null) return null;

    // If it's a Firestore Timestamp (has toDate method)
    if (value is Timestamp) {
      return value.toDate();
    }

    // If it's a string, parse it
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse date string: $value');
        return null;
      }
    }

    return null;
  }

  /// Create order when buyer buys
  static Future<String> createOrder(order_models.Order order) async {
    print('🚀 CREATEORDER CALLED - order.id: ${order.id}');
    print('🚀 order object: $order');
    print('🚀 Buyer ID passed: "${order.buyerId}"');

    try {
      print('📝 Creating order: ${order.id}');
      print('   Buyer ID: "${order.buyerId}"');
      print('   Buyer ID is empty: ${order.buyerId.isEmpty}');
      print('   Items count: ${order.items.length}');
      for (var item in order.items) {
        print('   - Item: ${item['name']}, Seller: ${item['sellerId']}');
      }

      print('🔥 About to save to Firestore...');
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

      print('✅ Order saved to Firestore with ID: ${docRef.id}');
      print('✅ Order saved with buyerId: "${order.buyerId}"');

      // Create notifications for each seller whose products are in the order with detailed buyer info
      final Map<String, List<Map<String, dynamic>>> sellerItems = {};

      // Group items by seller
      for (var item in order.items) {
        final sellerId = item['sellerId'] as String?;
        print('🔍 Checking item ${item['name']}: sellerId = $sellerId');
        if (sellerId != null && sellerId.isNotEmpty) {
          if (!sellerItems.containsKey(sellerId)) {
            sellerItems[sellerId] = [];
          }
          sellerItems[sellerId]!.add(item);
        }
      }

      print('📦 Grouped into ${sellerItems.length} seller(s)');

      // Create detailed notification for each seller
      for (var entry in sellerItems.entries) {
        final sellerId = entry.key;
        final items = entry.value;

        try {
          print(
              '🔔 Creating notification for seller: $sellerId (length: ${sellerId.length})');

          // Get buyer name from billing details or user document
          String buyerName = order.billingDetails.fullName;
          String buyerEmail = order.billingDetails.email;
          String buyerPhone = order.billingDetails.phoneNumber;

          print(
              '🔍 Buyer info - Name: "$buyerName", Email: "$buyerEmail", Phone: "$buyerPhone"');

          // If fullName is empty, try to fetch from user document
          if (buyerName.isEmpty) {
            try {
              final userDoc =
                  await _firestore.collection('users').doc(order.buyerId).get();
              if (userDoc.exists) {
                buyerName = userDoc.data()?['name'] ?? 'Unknown Buyer';
                buyerEmail = userDoc.data()?['email'] ?? buyerEmail;
                buyerPhone = userDoc.data()?['phone'] ?? buyerPhone;
                print('✅ Fetched buyer info from user document: $buyerName');
              }
            } catch (e) {
              print('⚠️ Could not fetch buyer info from user doc: $e');
              buyerName = 'Unknown Buyer';
            }
          }

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

👤 Buyer: $buyerName
📧 Email: $buyerEmail
📱 Phone: $buyerPhone
📍 Address: ${order.billingDetails.address}, ${order.billingDetails.city}

💰 Total: ₹${order.totalAmount.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━━━━━━━
''';

          print('💾 Saving notification with userId: "$sellerId"');
          await _firestore.collection('notifications').add({
            'userId': sellerId,
            'title': title,
            'body': body,
            'type': 'order_received',
            'orderId': docRef.id,
            'buyerId': order.buyerId,
            'buyerName': buyerName,
            'buyerEmail': buyerEmail,
            'buyerPhone': buyerPhone,
            'orderAmount': order.totalAmount,
            'itemCount': items.length,
            'timestamp': DateTime.now().toIso8601String(),
            'read': false,
          });

          print(
              '✅ Detailed notification created for seller: "$sellerId" with ${items.length} items (buyerName: $buyerName)');
        } catch (e) {
          print('⚠️ Failed to create notification for seller $sellerId: $e');
        }
      }

      return docRef.id;
    } catch (e) {
      print('❌ Order creation failed: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Full error: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get orders for buyer
  static Stream<List<order_models.Order>> getBuyerOrders(String buyerId) {
    print('🔍 getBuyerOrders called with buyerId: "$buyerId"');

    if (buyerId.isEmpty) {
      print('⚠️ WARNING: buyerId is empty, returning empty stream');
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
      print(
          '📦 Firebase returned ${snapshot.docs.length} orders for buyerId: $buyerId');

      // Sort orders by date in code (descending)
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final dateA =
            DateTime.parse(a['orderDate'] ?? DateTime.now().toIso8601String());
        final dateB =
            DateTime.parse(b['orderDate'] ?? DateTime.now().toIso8601String());
        return dateB.compareTo(dateA); // Descending order
      });

      return docs.map((doc) {
        try {
          final data = doc.data();
          print(
              '📄 Processing order: ${data['id']} with status: ${data['status']}');

          // Handle manual document fields (adapt to app's expected structure)
          final items = data['items'] != null
              ? List<Map<String, dynamic>>.from(data['items'])
              : [
                  {
                    'name': 'Manual Spice Order',
                    'spiceId': data['spiceId'] ?? '',
                    'sellerId': data['sellerId'] ?? '',
                    'quantity': data['quantity'] ?? 1,
                    'price': (data['total Price'] as num?)?.toDouble() ?? 0.0,
                  }
                ];

          final totalAmount = (data['totalAmount'] as num?)?.toDouble() ??
              (data['total Price'] as num?)?.toDouble() ??
              0.0;

          final orderDate = _convertToDateTime(data['orderDate']) ??
              _convertToDateTime(data['createdAt']) ??
              DateTime.now();

          final billingData =
              (data['billingDetails'] as Map<String, dynamic>?) ?? {};

          return order_models.Order(
            id: data['id'] ?? doc.id, // Use doc.id if id missing
            buyerId: data['buyerId'] ?? '',
            items: items,
            totalAmount: totalAmount,
            billingDetails: order_models.BillingDetails(
              fullName: billingData['fullName'] ?? 'Manual Order',
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
            orderDate: orderDate,
            status: data['status'] ?? 'pending',
          );
        } catch (e) {
          print('❌ Error parsing order document: $e');
          rethrow;
        }
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
    print('📱 getConversation called: userId1=$userId1, userId2=$userId2');
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      print(
          '📩 Retrieved ${snapshot.docs.length} total messages from Firebase');
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data();
        final senderId = data['senderId'] ?? '';
        final receiverId = data['receiverId'] ?? '';
        final matches = (senderId == userId1 && receiverId == userId2) ||
            (senderId == userId2 && receiverId == userId1);
        if (matches) {
          print('✅ Matched message: $senderId -> $receiverId');
        }
        return matches;
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
      print('📱 Filtered to ${filtered.length} messages for this conversation');
      return filtered;
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

  /// Get all conversations for a buyer (messages from sellers)
  static Stream<List<msg.Message>> getBuyerConversations(String buyerId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: buyerId)
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
    print('📢 getNotifications called for userId: $userId');
    print('   Looking for documents where userId == "$userId"');
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      print(
          '📬 Retrieved ${snapshot.docs.length} notifications from Firebase for userId: $userId');

      // Log all documents in the collection to understand the data structure
      if (snapshot.docs.isEmpty) {
        print('⚠️ No documents found! Querying all notifications to debug...');
        // This is just for debugging - we're using the snapshot we already have
      }

      final notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        final buyerName = data['buyerName'] ?? 'Unknown Buyer';
        print(
            '🔔 Notification: id=${doc.id}, type=${data['type']}, userId=${data['userId']}, read=${data['read']}, buyerName=$buyerName');
        return {
          'id': doc.id,
          'title': data['title'],
          'body': data['body'],
          'type': data['type'],
          'timestamp': data['timestamp'],
          'read': data['read'],
          'orderId': data['orderId'],
          'buyerId': data['buyerId'],
          'buyerName': buyerName,
          'buyerEmail': data['buyerEmail'] ?? 'N/A',
          'buyerPhone': data['buyerPhone'] ?? 'N/A',
          'orderAmount': data['orderAmount'] ?? 0.0,
          'itemCount': data['itemCount'] ?? 0,
        };
      }).toList();
      print('✅ Mapped ${notifications.length} notifications');
      return notifications;
    });
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
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
  Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
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
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Get user stream
  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Get seller name by seller ID
  Future<String> getSellerName(String sellerId) async {
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
