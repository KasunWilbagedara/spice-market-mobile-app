import 'package:flutter/material.dart';
import 'dart:io';
import '../services/image_picker_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final Function(File?) onImageSelected;
  final String label;
  final File? initialImage;

  const ImageUploadWidget({
    required this.onImageSelected,
    this.label = 'Upload Image',
    this.initialImage,
    super.key,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.orange.shade700),
              title: Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: Colors.orange.shade700),
              title: Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromGallery();
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                  widget.onImageSelected(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isLoading = true);
    final image = await ImagePickerService.pickImageFromCamera();
    if (image != null) {
      setState(() => _selectedImage = image);
      widget.onImageSelected(image);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    final image = await ImagePickerService.pickImageFromGallery();
    if (image != null) {
      setState(() => _selectedImage = image);
      widget.onImageSelected(image);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.orange.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _selectedImage != null
              ? Colors.orange.shade50
              : Colors.grey.shade50,
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
                ),
              )
            : _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedImage = null);
                            widget.onImageSelected(null);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.orange.shade700,
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap to select from camera or gallery',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
