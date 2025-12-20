import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/spice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/spice.dart';
import '../../services/firebase_service.dart';

class AddSpiceScreen extends StatefulWidget {
  const AddSpiceScreen({super.key});

  @override
  _AddSpiceScreenState createState() => _AddSpiceScreenState();
}

class _AddSpiceScreenState extends State<AddSpiceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String _selectedCategory = 'Spicy';
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> categories = ['Spicy', 'Mild', 'Sweet', 'Exotic'];

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addSpice() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final spiceProvider = Provider.of<SpiceProvider>(context, listen: false);
      final sellerId = auth.user?.id ?? '';

      // Upload image to Firebase Storage if selected
      String? imageUrl;
      if (_selectedImage != null) {
        try {
          print('📤 Uploading image for new spice...');
          final spiceId = Uuid().v4();
          imageUrl =
              await FirebaseService.uploadSpiceImage(_selectedImage!, spiceId);
          print('✅ Image uploaded: $imageUrl');
        } catch (e) {
          print('❌ Image upload failed: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      final spice = Spice(
        id: Uuid().v4(),
        name: nameController.text.trim(),
        price: double.tryParse(priceController.text) ?? 0,
        sellerId: sellerId,
        description: descriptionController.text.trim(),
        category: _selectedCategory,
        imageUrl: imageUrl,
      );

      await spiceProvider.addSpice(spice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${spice.name} added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding spice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Spice',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Upload Section
              Text('Spice Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.shade50,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 48, color: Colors.orange.shade700),
                            SizedBox(height: 12),
                            Text('Tap to add photo',
                                style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('(Optional)',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 180),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImage = null),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade700,
                                      shape: BoxShape.circle),
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 20),

              // Spice Name
              Text('Spice Name *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter spice name',
                  prefixIcon: Icon(Icons.local_fire_department,
                      color: Colors.orange.shade700),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              // Category
              Text('Category *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: SizedBox(),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value ?? 'Spicy');
                  },
                ),
              ),
              SizedBox(height: 20),

              // Price
              Text('Price (\$) *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  prefixIcon:
                      Icon(Icons.attach_money, color: Colors.orange.shade700),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              // Description
              Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter spice description',
                  prefixIcon:
                      Icon(Icons.description, color: Colors.orange.shade700),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 30),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _addSpice,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : Icon(Icons.add),
                  label: Text(_isLoading ? 'Adding...' : 'Add Spice',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
