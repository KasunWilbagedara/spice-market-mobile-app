import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' as io;
import 'dart:typed_data' as typed_data;
import 'dart:convert' show base64Encode;
import 'package:flutter/foundation.dart' show kIsWeb;
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

  /// Upload spice image to Firebase Storage from XFile with smart retry
  /// Falls back to base64 data URL if storage upload fails (web only)
  static Future<String> uploadSpiceImageFromXFile(
      dynamic xFile, String spiceId) async {
    try {
      print('📸 Uploading image for spice: $spiceId');

      // Read file bytes
      print('📥 Reading image bytes...');
      var bytes = await xFile.readAsBytes();
      final sizeKB = bytes.length / 1024;
      print('📥 Image size: ${sizeKB.toStringAsFixed(2)} KB');
      print('📥 File name: ${xFile.name}');

      // On web: immediately use base64 for small images (avoids CORS)
      if (kIsWeb && sizeKB < 200) {
        print(
            '🌐 Web platform detected - using base64 data URL (CORS-safe)...');
        final dataUrl = _createBase64DataUrl(bytes);
        print('✅ Image prepared as data URL!');
        print('🔗 Data URL: ${dataUrl.substring(0, 50)}...');
        return dataUrl;
      }

      // On native: try Firebase Storage upload
      try {
        final downloadUrl =
            await _uploadToStorageWithRetry(bytes, spiceId, xFile.name);
        print('✅ Image uploaded successfully!');
        print('🔗 Download URL: $downloadUrl');
        return downloadUrl;
      } catch (storageError) {
        print('⚠️ Storage upload failed: $storageError');

        // Final fallback for small images: use base64 data URL
        if (sizeKB < 200) {
          print('🔄 Fallback: using base64 data URL...');
          return _createBase64DataUrl(bytes);
        }

        throw storageError;
      }
    } catch (e) {
      print('❌ Image upload completely failed: $e');
      print('Stack trace: ${e.toString()}');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Create a base64 data URL (works on web, good for small images)
  static String _createBase64DataUrl(typed_data.Uint8List bytes) {
    final base64String = base64Encode(bytes);
    final dataUrl = 'data:image/jpeg;base64,$base64String';
    print(
        '✅ Created base64 data URL (${(bytes.length / 1024).toStringAsFixed(2)} KB)');
    return dataUrl;
  }

  /// Alternative storage upload with different approach
  static Future<String> _uploadToStorageAlternative(
    typed_data.Uint8List bytes,
    String spiceId,
    String fileName,
  ) async {
    try {
      print('📤 Trying alternative storage upload...');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'temp/$spiceId/$timestamp.jpg';

      print('📋 Uploading to: $storagePath');
      final ref = _storage.ref(storagePath);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
      );

      final snapshot = await ref.putData(bytes, metadata).timeout(
            const Duration(seconds: 45), // Shorter timeout
          );

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Alternative upload succeeded');
      return downloadUrl;
    } catch (e) {
      print('❌ Alternative upload also failed: $e');
      rethrow;
    }
  }

  /// Upload to Firebase Storage with exponential backoff retry
  static Future<String> _uploadToStorageWithRetry(
    typed_data.Uint8List bytes,
    String spiceId,
    String fileName, {
    int maxAttempts = 5,
    int initialDelayMs = 500,
  }) async {
    int attempt = 0;
    Exception? lastError;

    while (attempt < maxAttempts) {
      try {
        attempt++;
        print('📤 Upload attempt $attempt/$maxAttempts...');

        // Create unique filename with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final storagePath = 'spices/$spiceId/$timestamp.jpg';

        print('📋 Uploading to: $storagePath');
        final ref = _storage.ref(storagePath);

        // Set metadata with proper cache headers
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000', // 1 year
          customMetadata: {
            'uploaded-by': 'flutter-app',
            'timestamp': timestamp.toString(),
            'original-name': fileName,
          },
        );

        // Upload with timeout
        final snapshot = await ref.putData(bytes, metadata).timeout(
          const Duration(seconds: 90),
          onTimeout: () {
            throw Exception(
                'Upload timeout after 90 seconds on attempt $attempt');
          },
        );

        // Get download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Upload succeeded on attempt $attempt');
        print('🔗 URL: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        lastError = Exception('Attempt $attempt failed: $e');
        print('❌ $lastError');

        // Don't retry on auth errors
        if (e.toString().contains('permission') ||
            e.toString().contains('auth') ||
            e.toString().contains('unauthorized')) {
          print('⛔ Authentication error - not retrying');
          rethrow;
        }

        if (attempt < maxAttempts) {
          // Exponential backoff: 500ms, 1s, 2s, 4s, 8s
          final delayMs = initialDelayMs * (1 << (attempt - 1));
          print(
              '⏳ Retrying in ${delayMs}ms... (attempt $attempt/$maxAttempts)');
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    print('❌ Upload failed after $maxAttempts attempts');
    throw lastError ?? Exception('Upload failed after $maxAttempts attempts');
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

      // Get seller name
      String sellerName = 'Unknown Seller';
      try {
        final userDoc =
            await _firestore.collection('users').doc(spice.sellerId).get();
        if (userDoc.exists) {
          sellerName = userDoc.data()?['name'] ?? 'Unknown Seller';
        }
      } catch (e) {
        print('⚠️ Could not fetch seller name: $e');
      }

      final spiceData = {
        'id': spice.id,
        'name': spice.name,
        'description': spice.description ?? '',
        'price': spice.price,
        'category': spice.category ?? '',
        'sellerId': spice.sellerId,
        'sellerName': sellerName,
        'averageRating': spice.averageRating,
        'reviews': spice.reviews,
        'comments': spice.comments,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // ✅ FIX 1: Only save imageUrl if valid (NEVER save empty strings)
      if (spice.imageUrl != null && spice.imageUrl!.trim().isNotEmpty) {
        spiceData['imageUrl'] = spice.imageUrl!;
        print('✅ imageUrl saved: ${spice.imageUrl}');
      } else {
        print('⚠️ No imageUrl provided, field will not be saved to Firestore');
      }

      print('💾 Firestore data imageUrl field: "${spiceData['imageUrl']}"');

      final docRef = await _firestore.collection('spices').add(spiceData);
      print('✅ Spice saved with Firestore ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Failed to add spice: $e');
      throw Exception('Failed to add spice: $e');
    }
  }

  /// Validate and get image URL with proper Firebase Storage URL format
  static Future<String?> validateImageUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    try {
      // If it's already a download URL, return it
      if (imageUrl.contains('firebasestorage.googleapis.com')) {
        print('✅ Image URL valid: ${imageUrl.substring(0, 50)}...');
        return imageUrl;
      }

      // If it's a file path, try to get the URL from storage
      if (imageUrl.startsWith('spices/')) {
        final ref = _storage.ref(imageUrl);
        final url = await ref.getDownloadURL();
        print(
            '✅ Retrieved image URL from Firebase: ${url.substring(0, 50)}...');
        return url;
      }

      // Otherwise assume it's a valid URL
      return imageUrl;
    } catch (e) {
      print('⚠️ Error validating image URL: $e');
      return null;
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

        // ✅ FIX 2: Normalize empty strings to null when reading
        final rawUrl = data['imageUrl'];
        final imageUrl =
            (rawUrl is String && rawUrl.trim().isNotEmpty) ? rawUrl : null;

        return Spice(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          sellerId: data['sellerId'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          imageUrl: imageUrl,
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

        // ✅ FIX 3: Normalize empty strings to null when reading (same as getAllSpices)
        final rawUrl = data['imageUrl'];
        final imageUrl =
            (rawUrl is String && rawUrl.trim().isNotEmpty) ? rawUrl : null;

        return Spice(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          sellerId: data['sellerId'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          imageUrl: imageUrl,
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
          reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
          comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
        );
      }).toList();
    });
  }

  /// Update spice with partial data
  static Future<void> updateSpice(
      String spiceId, Map<String, dynamic> updateData) async {
    try {
      // Add updatedAt timestamp
      updateData['updatedAt'] = DateTime.now().toIso8601String();

      // Find the document by the spice's id field (not the Firestore document ID)
      final querySnapshot = await _firestore
          .collection('spices')
          .where('id', isEqualTo: spiceId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Spice document not found for id: $spiceId');
      }

      // Update the first (and should be only) matching document
      await _firestore
          .collection('spices')
          .doc(querySnapshot.docs.first.id)
          .update(updateData);

      print('✅ Spice updated successfully: $spiceId');
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

  /// Add a review to a spice
  static Future<void> addReview({
    required String spiceId,
    required double rating,
    required String reviewText,
    required String spiceName,
  }) async {
    try {
      print('📝 Adding review for spice: $spiceId');
      print('   Rating: $rating');
      print('   Review text: $reviewText');

      // Find the spice document by ID
      final querySnapshot = await _firestore
          .collection('spices')
          .where('id', isEqualTo: spiceId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Spice not found with ID: $spiceId');
      }

      final spiceDoc = querySnapshot.docs.first;
      final spiceData = spiceDoc.data();

      // Get existing reviews or empty list
      final existingReviews = List<Map<String, dynamic>>.from(
        spiceData['reviews'] ?? [],
      );

      // Create new review
      final newReview = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'rating': rating,
        'comment': reviewText,
        'text': reviewText,
        'timestamp': DateTime.now().toIso8601String(),
        'userName': 'Anonymous', // Could be fetched from auth if needed
        'daysAgo': 'Recently',
      };

      // Add new review to list
      existingReviews.add(newReview);

      // Calculate new average rating
      double totalRating = 0;
      for (var review in existingReviews) {
        totalRating += (review['rating'] as num).toDouble();
      }
      final averageRating = totalRating / existingReviews.length;

      // Update spice with new reviews and average rating
      await spiceDoc.reference.update({
        'reviews': existingReviews,
        'averageRating': averageRating,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Review added successfully');
      print('   New average rating: ${averageRating.toStringAsFixed(2)}');
      print('   Total reviews: ${existingReviews.length}');
    } catch (e) {
      print('❌ Failed to add review: $e');
      throw Exception('Failed to add review: $e');
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
    print('🚀 ═══════════════════════════════════════════════════');
    print('🚀 CREATEORDER CALLED');
    print('🚀 order.id: ${order.id}');
    print('🚀 order.buyerId: "${order.buyerId}"');
    print('🚀 order.items count: ${order.items.length}');
    print('🚀 order.items: ${order.items}');
    print('🚀 order.totalAmount: ${order.totalAmount}');
    print('🚀 ═══════════════════════════════════════════════════');

    try {
      print('📝 [createOrder] Creating order: ${order.id}');
      print('   [createOrder] Buyer ID: "${order.buyerId}"');
      print('   [createOrder] Buyer ID is empty: ${order.buyerId.isEmpty}');
      print('   [createOrder] Items count: ${order.items.length}');
      for (var item in order.items) {
        print(
            '   [createOrder] - Item: ${item['name']}, Seller: ${item['sellerId']}');
      }

      print('🔥 [createOrder] About to save to Firestore...');
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

      print('✅ ═══════════════════════════════════════════════════');
      print('✅ Order saved to Firestore with ID: ${docRef.id}');
      print('✅ Order saved with buyerId: "${order.buyerId}"');
      print('✅ Items saved: ${order.items.length}');
      print('✅ ═══════════════════════════════════════════════════');

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

          print('💾 Saving notification with sellerId: "$sellerId"');
          await _firestore.collection('notifications').add({
            'sellerId': sellerId,
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
      print('❌ ═══════════════════════════════════════════════════');
      print('❌ Order creation FAILED!');
      print('❌ Error: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error toString: ${e.toString()}');
      print('❌ ═══════════════════════════════════════════════════');
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
        final aData = a.data();
        final bData = b.data();
        final dateA = _convertToDateTime(aData['orderDate']) ??
            _convertToDateTime(aData['createdAt']) ??
            DateTime.now();
        final dateB = _convertToDateTime(bData['orderDate']) ??
            _convertToDateTime(bData['createdAt']) ??
            DateTime.now();
        return dateB.compareTo(dateA); // Descending order
      });

      return docs.map((doc) {
        try {
          final data = doc.data();
          print(
              '📄 Processing order: ${data['id']} with status: ${data['status']}');
          print('   Keys in order doc: ${data.keys.toList()}');
          print('   items field exists: ${data.containsKey('items')}');
          print('   items field value: ${data['items']}');
          print('   items field type: ${data['items'].runtimeType}');

          // Handle manual document fields (adapt to app's expected structure)
          List<Map<String, dynamic>> items = [];

          if (data['items'] != null && (data['items'] as List).isNotEmpty) {
            print('   ✅ Using items from data');
            items = List<Map<String, dynamic>>.from(data['items']);
          } else {
            print(
                '   ⚠️ Items missing or empty, checking for individual fields');
            // Only use fallback if truly no items
            if (data['spiceId'] != null &&
                data['spiceId'].toString().isNotEmpty) {
              items = [
                {
                  'name': data['name'] ?? 'Manual Spice Order',
                  'spiceId': data['spiceId'] ?? '',
                  'sellerId': data['sellerId'] ?? '',
                  'quantity': data['quantity'] ?? 1,
                  'price': (data['price'] as num?)?.toDouble() ?? 0.0,
                }
              ];
            }
          }

          print('   Final items count: ${items.length}');

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
    print('📢 getNotifications called for sellerId: $userId');
    print('   Looking for documents where sellerId == "$userId"');
    return _firestore
        .collection('notifications')
        .where('sellerId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      print(
          '📬 Retrieved ${snapshot.docs.length} notifications from Firebase for sellerId: $userId');

      // Log all documents in the collection to understand the data structure
      if (snapshot.docs.isEmpty) {
        print('⚠️ No documents found! Querying all notifications to debug...');
        // This is just for debugging - we're using the snapshot we already have
      }

      final notifications = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          final buyerName = data['buyerName'] ?? 'Unknown Buyer';
          print(
              '🔔 Notification: id=${doc.id}, type=${data['type']}, sellerId=${data['sellerId']}, read=${data['read']}, buyerName=$buyerName');
          return {
            'id': doc.id,
            'title': data['title'] ?? 'New Order',
            'body': data['body'] ?? 'You have a new order',
            'type': data['type'] ?? 'order_received',
            'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
            'read': data['read'] ?? false,
            'orderId': data['orderId'] ?? '',
            'buyerId': data['buyerId'] ?? '',
            'buyerName': buyerName,
            'buyerEmail': data['buyerEmail'] ?? 'N/A',
            'buyerPhone': data['buyerPhone'] ?? 'N/A',
            'orderAmount': data['orderAmount'] ?? 0.0,
            'itemCount': data['itemCount'] ?? 0,
          };
        } catch (e) {
          print('❌ Error mapping notification doc: $e');
          return {
            'id': doc.id,
            'title': 'Error',
            'body': 'Could not load notification',
            'type': 'error',
            'timestamp': DateTime.now().toIso8601String(),
            'read': false,
            'orderId': '',
            'buyerId': '',
            'buyerName': 'Unknown',
            'buyerEmail': 'N/A',
            'buyerPhone': 'N/A',
            'orderAmount': 0.0,
            'itemCount': 0,
          };
        }
      }).toList();
      print('✅ Mapped ${notifications.length} notifications');
      return notifications;
    }).handleError((error) {
      print('❌ Error in getNotifications stream: $error');
      print('❌ Error type: ${error.runtimeType}');
      return <Map<String, dynamic>>[];
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

  /// Get seller name by seller ID (with comprehensive fallback logic)
  Future<String> getSellerName(String sellerId) async {
    try {
      if (sellerId.isEmpty) {
        return 'Unknown Seller';
      }

      // First, try getting from users collection
      try {
        final userDoc =
            await _firestore.collection('users').doc(sellerId).get();
        if (userDoc.exists) {
          final name = userDoc.data()?['name'];
          if (name != null && name.toString().isNotEmpty) {
            return name.toString();
          }
        }
      } catch (e) {
        print('Info: Could not fetch from users: $e');
      }

      // Second, try getting from spices collection
      try {
        final spicesQuery = await _firestore
            .collection('spices')
            .where('sellerId', isEqualTo: sellerId)
            .limit(1)
            .get();

        if (spicesQuery.docs.isNotEmpty) {
          final sellerName = spicesQuery.docs.first.data()['sellerName'];
          if (sellerName != null && sellerName.toString().isNotEmpty) {
            return sellerName.toString();
          }
        }
      } catch (e) {
        print('Info: Could not fetch from spices: $e');
      }

      // If all else fails, return a reasonable default
      return 'Seller';
    } catch (e) {
      print('Error in getSellerName: $e');
      return 'Seller';
    }
  }

  /// Debug: Print all orders in Firestore for current user
  static Future<void> debugPrintAllOrders(String buyerId) async {
    try {
      print(
          '\n🔍 [DEBUG] Checking all orders in Firestore for buyerId: $buyerId');
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: buyerId)
          .get();

      print('📊 Total orders found: ${ordersSnapshot.docs.length}');

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        print('\n  📋 Order ID: ${doc.id}');
        print('     id field: ${data['id']}');
        print('     buyerId: ${data['buyerId']}');
        print('     status: ${data['status']}');
        print('     totalAmount: ${data['totalAmount']}');
        print('     Has items field: ${data.containsKey('items')}');

        final items = data['items'];
        if (items != null && items is List) {
          print('     Items count: ${items.length}');
          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            print(
                '       Item $i: name=${item['name']}, price=${item['price']}, sellerId=${item['sellerId']}');
          }
        } else {
          print('     Items field is null or not a list: $items');
        }
      }
    } catch (e) {
      print('❌ Error in debugPrintAllOrders: $e');
    }
  }

  /// Debug: Print all spices with given seller ID
  static Future<void> debugPrintSellerSpices(String sellerId) async {
    try {
      print('\n🔍 [DEBUG] Checking all spices for sellerId: $sellerId');
      final spicesSnapshot = await _firestore
          .collection('spices')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      print('📊 Total spices found: ${spicesSnapshot.docs.length}');

      for (var doc in spicesSnapshot.docs) {
        final data = doc.data();
        print('\n  🛒 Spice ID: ${doc.id}');
        print('     id field: ${data['id']}');
        print('     name: ${data['name']}');
        print('     sellerId: ${data['sellerId']}');
        print('     price: ${data['price']}');
      }
    } catch (e) {
      print('❌ Error in debugPrintSellerSpices: $e');
    }
  }

  /// Create or update seller profile
  static Future<void> createSellerProfile(
      String sellerId, String sellerName) async {
    try {
      print('💾 Creating/Updating seller profile: $sellerId -> $sellerName');
      await _firestore.collection('users').doc(sellerId).set({
        'id': sellerId,
        'name': sellerName,
        'role': 'seller',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      print('✅ Seller profile created/updated');
    } catch (e) {
      print('❌ Error creating seller profile: $e');
    }
  }

  /// Update all spices for a seller with their name
  static Future<void> updateSellerSpicesWithName(
      String sellerId, String sellerName) async {
    try {
      print(
          '🔄 Updating all spices for seller: $sellerId with name: $sellerName');
      final spicesQuery = await _firestore
          .collection('spices')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      for (var doc in spicesQuery.docs) {
        await doc.reference.update({
          'sellerName': sellerName,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      print('✅ Updated ${spicesQuery.docs.length} spices with seller name');
    } catch (e) {
      print('❌ Error updating spices: $e');
    }
  }
}
