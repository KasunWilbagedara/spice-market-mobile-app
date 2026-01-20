import '../services/firebase_service.dart';

/// Helper class to set up and manage seller profiles
class SellerSetup {
  /// Map of seller IDs to their display names
  /// Update this with your actual seller IDs and names
  static const Map<String, String> sellerProfiles = {
    'F2sPpGAw': 'janiduwilbagedara',
    // Add more sellers as needed: 'sellerId': 'Seller Name',
  };

  /// Initialize all seller profiles in Firebase
  /// Call this once during app startup or from admin panel
  static Future<void> initializeSellerProfiles() async {
    print('🔄 Initializing seller profiles...');

    for (var entry in sellerProfiles.entries) {
      final sellerId = entry.key;
      final sellerName = entry.value;

      try {
        // Create seller profile
        await FirebaseService.createSellerProfile(sellerId, sellerName);

        // Update all their spices with the seller name
        await FirebaseService.updateSellerSpicesWithName(sellerId, sellerName);

        print('✅ Setup completed for: $sellerName ($sellerId)');
      } catch (e) {
        print('❌ Error setting up $sellerName: $e');
      }
    }

    print('✅ Seller profiles initialization complete!');
  }

  /// Add a single seller profile
  static Future<void> addSellerProfile(
      String sellerId, String sellerName) async {
    try {
      await FirebaseService.createSellerProfile(sellerId, sellerName);
      await FirebaseService.updateSellerSpicesWithName(sellerId, sellerName);
      print('✅ Seller profile added: $sellerName');
    } catch (e) {
      print('❌ Error adding seller: $e');
    }
  }
}
