import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:convert' show base64Decode;

/// Helper function to display images safely across all platforms
/// On Web: Only shows network images or placeholders
/// On Mobile: Can show file images
Widget buildImageWidget({
  required String? imagePath,
  required double width,
  required double height,
  required BoxFit fit,
  required Widget fallback,
}) {
  // If no image path provided, show fallback
  if (imagePath == null || imagePath.isEmpty) {
    return fallback;
  }

  // If it's a network URL (starts with http/https)
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  // For file paths (mobile platforms only)
  try {
    // Check if platform supports File images (not Web)
    if (!identical(0, 0.0)) {
      // This is a hack to check if we're on Web
      // Web will not have dart:io File support
      return Image.file(
        io.File(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
  } catch (e) {
    // If Image.file fails (e.g., on Web), fall back to placeholder
    debugPrint('Image loading error: $e');
  }

  return fallback;
}

/// Simplified wrapper for Image.file that safely handles Web platform and data URLs
Widget safeImageFile(
  String filePath, {
  required double width,
  required double height,
  required BoxFit fit,
  Widget? errorBuilder,
}) {
  // If it's a URL, use Image.network instead
  if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
    print('🌐 Loading image from URL: $filePath');
    return Image.network(
      filePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error loading image: $error');
        return errorBuilder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, color: Colors.red),
                  SizedBox(height: 4),
                  Text(
                    'Failed to load',
                    style: TextStyle(fontSize: 10, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  // Handle base64 data URLs (e.g., "data:image/jpeg;base64,/9j/4AAQSkZJRgABA...")
  if (filePath.startsWith('data:')) {
    print('📊 Loading image from base64 data URL (${filePath.length} chars)');
    try {
      // Extract base64 string from data URL
      // Format: data:image/jpeg;base64,<base64-string>
      final base64String = filePath.split(',').last;
      final imageBytes = base64Decode(base64String);

      return Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading base64 image: $error');
          return errorBuilder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey.shade300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, color: Colors.red),
                    SizedBox(height: 4),
                    Text(
                      'Failed to load',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
        },
      );
    } catch (e) {
      print('❌ Base64 decoding failed: $e');
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.red),
            SizedBox(height: 4),
            Text(
              'Invalid image',
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
          ],
        ),
      );
    }
  }

  // For file paths, check if we can use Image.file
  bool canUseImageFile = false;
  try {
    // Test if we can create a File object
    final _ = io.File(filePath);
    canUseImageFile = true;
  } catch (e) {
    // On Web or other platforms that don't support File
    canUseImageFile = false;
  }

  // On platforms that don't support file images, show placeholder
  if (!canUseImageFile) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported),
    );
  }

  // On mobile platforms, use Image.file
  try {
    return Image.file(
      io.File(filePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          errorBuilder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: const Icon(Icons.image_not_supported),
          ),
    );
  } catch (e) {
    debugPrint('Error displaying image: $e');
    // Fallback for any other errors
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported),
    );
  }
}
