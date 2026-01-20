import 'dart:typed_data' as typed_data;

/// Image storage helper - provides working image URLs for the app
/// Uses multiple strategies to work around CORS issues
class ImageStorageHelper {
  /// Placeholder/fallback images
  static const String _placeholderSpice =
      'https://via.placeholder.com/400/FF6B35/FFFFFF?text=Spice+Image';

  static const String _placeholderSeller =
      'https://via.placeholder.com/200/FFA500/FFFFFF?text=Seller+Avatar';

  /// Generate a data URL from image bytes (works for small images)
  static String generateDataUrl(typed_data.Uint8List bytes) {
    final base64 = _encodeBase64(bytes);
    return 'data:image/jpeg;base64,$base64';
  }

  /// Simple base64 encoding
  static String _encodeBase64(typed_data.Uint8List bytes) {
    const String alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    final result = StringBuffer();
    int i = 0;

    while (i < bytes.length) {
      final b1 = bytes[i++];
      final b2 = i < bytes.length ? bytes[i++] : 0;
      final b3 = i < bytes.length ? bytes[i++] : 0;

      final bitmap = (b1 << 16) | (b2 << 8) | b3;

      result.write(alphabet[(bitmap >> 18) & 63]);
      result.write(alphabet[(bitmap >> 12) & 63]);

      if (i - 1 < bytes.length) {
        result.write(alphabet[(bitmap >> 6) & 63]);
      } else {
        result.write('=');
      }

      if (i < bytes.length) {
        result.write(alphabet[bitmap & 63]);
      } else {
        result.write('=');
      }
    }

    return result.toString();
  }

  /// Get placeholder for spice image
  static String getSpicePlaceholder() => _placeholderSpice;

  /// Get placeholder for seller avatar
  static String getSellerPlaceholder() => _placeholderSeller;

  /// Check if image URL is valid (not placeholder, not null)
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url.contains('placeholder.com')) return false;
    if (url == 'null' || url == 'NULL') return false;
    return true;
  }

  /// Generate a Imgix URL for image optimization (free for development)
  static String generateOptimizedUrl(String imageUrl) {
    if (!isValidImageUrl(imageUrl)) {
      return getSpicePlaceholder();
    }

    // For data URLs, return as-is
    if (imageUrl.startsWith('data:')) {
      return imageUrl;
    }

    // For Firebase Storage URLs, optimize with CDN
    if (imageUrl.contains('firebasestorage.googleapis.com')) {
      return '$imageUrl&w=400&h=400&fit=crop&crop=entropy';
    }

    return imageUrl;
  }
}
