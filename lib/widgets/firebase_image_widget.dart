import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseImageWidget extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const FirebaseImageWidget({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
    super.key,
  });

  @override
  State<FirebaseImageWidget> createState() => _FirebaseImageWidgetState();
}

class _FirebaseImageWidgetState extends State<FirebaseImageWidget> {
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _getImageUrl();
  }

  @override
  void didUpdateWidget(FirebaseImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageUrlFuture = _getImageUrl();
    }
  }

  Future<String> _getImageUrl() async {
    try {
      final url = widget.imageUrl;

      // If no URL, return empty
      if (url == null || url.trim().isEmpty) {
        throw Exception('No image URL provided');
      }

      print('🖼️ Processing image URL: ${url.substring(0, 50)}...');

      // If it's already a download URL, return it directly
      if (url.contains('firebasestorage.googleapis.com')) {
        print('✅ Using Firebase Storage download URL directly');
        return url;
      }

      // If it's a file path (starts with spices/), get the URL from Firebase Storage
      if (url.startsWith('spices/')) {
        print('📍 Getting download URL from Firebase Storage path: $url');
        final ref = FirebaseStorage.instance.ref(url);
        final downloadUrl = await ref.getDownloadURL();
        print('🔗 Retrieved URL: ${downloadUrl.substring(0, 50)}...');
        return downloadUrl;
      }

      // Otherwise assume it's a valid URL
      print('✅ Using URL as-is');
      return url;
    } catch (e) {
      print('❌ Error getting image URL: $e');
      throw Exception('Failed to load image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                  ),
                ),
              );
        }

        // Error state
        if (snapshot.hasError) {
          print('🖼️ Error loading image: ${snapshot.error}');
          return widget.errorWidget ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Image not available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              );
        }

        // Success state
        if (snapshot.hasData && snapshot.data != null) {
          print(
              '🖼️ Loading image from: ${snapshot.data!.substring(0, 50)}...');
          return Image.network(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('🖼️ Error displaying image: $error');
              return widget.errorWidget ??
                  Container(
                    width: widget.width,
                    height: widget.height,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
            },
          );
        }

        // No data
        return widget.errorWidget ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[300],
              child: Icon(Icons.image, color: Colors.grey[600]),
            );
      },
    );
  }
}
