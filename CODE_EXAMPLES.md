# 📱 Image & Logo Code Examples

## **1. USING THE LOGO**

### **Example: Splash Screen** ✅ Already Done
```dart
import '../../widgets/logo_widget.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade500],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpiceMarketLogo(size: 120, showText: true),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        ),
      ),
    ),
  );
}
```

---

### **Example: App Bar with Logo**
```dart
AppBar(
  leading: Padding(
    padding: EdgeInsets.all(8),
    child: SpiceMarketLogo(size: 40, showText: false),
  ),
  title: Text('Spice Market'),
  backgroundColor: Colors.orange.shade700,
)
```

---

### **Example: Login Screen**
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    SpiceMarketLogo(size: 100, showText: true),
    SizedBox(height: 40),
    TextField(
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
      ),
    ),
    // ... more fields
  ],
)
```

---

## **2. SELLER IMAGE UPLOAD**

### **Pick Image from Gallery**
```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SellerAddProduct extends StatefulWidget {
  @override
  _SellerAddProductState createState() => _SellerAddProductState();
}

class _SellerAddProductState extends State<SellerAddProduct> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null)
          Image.file(
            _selectedImage!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          )
        else
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
      ],
    );
  }
}
```

---

### **Take Photo with Camera**
```dart
Future<void> _takePhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? photo = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 80,  // Compress to 80% quality
  );
  
  if (photo != null) {
    setState(() {
      _selectedImage = File(photo.path);
    });
  }
}
```

---

### **Show Camera/Gallery Options Dialog**
```dart
void _showImageOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
        ],
      ),
    ),
  );
}
```

---

## **3. DISPLAYING PRODUCT IMAGES**

### **Simple Product Card with Image**
```dart
Card(
  child: Column(
    children: [
      // Product Image
      if (product.imageFile != null)
        Image.file(
          product.imageFile!,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        )
      else
        Container(
          width: double.infinity,
          height: 150,
          color: Colors.grey.shade300,
          child: Icon(Icons.image),
        ),
      
      // Product Info
      Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(product.name),
            Text('\$${product.price}'),
          ],
        ),
      ),
    ],
  ),
)
```

---

### **Product Grid with Images**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    return Card(
      child: Column(
        children: [
          Expanded(
            child: product.imageFile != null
                ? Image.file(
                    product.imageFile!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: Icon(Icons.image),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text(product.name),
                Text('\$${product.price}'),
              ],
            ),
          ),
        ],
      ),
    );
  },
)
```

---

## **4. ADD CUSTOM LOGO FILE**

### **Step 1: Create Folder Structure**
```
project/
└── assets/
    └── images/
        ├── logo.png
        ├── banner.png
        └── icons/
            ├── home.png
            └── cart.png
```

### **Step 2: Update pubspec.yaml**
```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/images/icons/
```

### **Step 3: Use in Code**
```dart
// Simple image
Image.asset('assets/images/logo.png')

// With sizing
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
)

// In AppBar
AppBar(
  leading: Image.asset('assets/images/logo.png'),
  title: Text('App Title'),
)

// In container background
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/banner.png'),
      fit: BoxFit.cover,
    ),
  ),
)

// With error handling
Image.asset(
  'assets/images/logo.png',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image);
  },
)
```

---

## **5. FIREBASE STORAGE UPLOAD** (Optional)

### **Setup Firebase**
```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseImageService {
  final storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(
    File imageFile,
    String productId,
  ) async {
    try {
      // Create reference
      final ref = storage.ref('products/$productId.jpg');
      
      // Upload file
      await ref.putFile(imageFile);
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      return '';
    }
  }

  // Upload with progress tracking
  Future<String> uploadWithProgress(
    File imageFile,
    String productId,
    Function(double) onProgress,
  ) async {
    try {
      final ref = storage.ref('products/$productId.jpg');
      
      final uploadTask = ref.putFile(imageFile);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload error: $e');
      return '';
    }
  }
}
```

---

### **Use Firebase Upload in Seller Screen**
```dart
Future<void> _addProductWithImage() async {
  if (_selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select an image')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Upload image to Firebase
    final imageUrl = await FirebaseImageService()
        .uploadProductImage(
          _selectedImage!,
          productId,
        );

    // Save product with image URL
    await spiceProvider.addSpice(
      Spice(
        id: productId,
        name: nameController.text,
        price: double.parse(priceController.text),
        sellerId: auth.user!.id,
        imageUrl: imageUrl,  // Cloud URL
        description: descriptionController.text,
        category: _selectedCategory,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product added successfully')),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## **6. IMAGE COMPRESSION BEFORE UPLOAD**

```dart
import 'package:image/image.dart' as img;

Future<File> compressImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes);
  
  // Resize to max width 800px
  final resized = img.copyResize(
    image!,
    width: 800,
  );
  
  // Compress
  final compressed = File(imageFile.path)
      ..writeAsBytesSync(
        img.encodeJpg(resized, quality: 80),
      );
  
  return compressed;
}

// Usage
Future<void> _pickAndCompress() async {
  final image = await ImagePickerService.pickImageFromGallery();
  if (image != null) {
    final compressed = await compressImage(image);
    setState(() => _selectedImage = compressed);
  }
}
```

---

## **7. IMAGE CACHING FOR NETWORK IMAGES**

```dart
Image.network(
  'https://example.com/product.jpg',
  cacheWidth: 400,      // Cache at 400px width
  cacheHeight: 400,     // Cache at 400px height
  fit: BoxFit.cover,
)
```

---

## **8. LOADING & ERROR STATES**

```dart
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  
  // Show while loading
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
  
  // Show on error
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(Icons.broken_image),
    );
  },
)
```

---

## **9. CUSTOM LOGO WIDGET EXAMPLE**

```dart
class CustomLogo extends StatelessWidget {
  final double size;

  const CustomLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.blue],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SM',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

---

## **Quick Reference**

| Task | Code |
|------|------|
| Show Logo | `SpiceMarketLogo(size: 100)` |
| Show Asset Image | `Image.asset('assets/images/logo.png')` |
| Show File Image | `Image.file(file)` |
| Show Network Image | `Image.network(url)` |
| Pick from Gallery | `ImagePickerService.pickImageFromGallery()` |
| Take Photo | `ImagePickerService.pickImageFromCamera()` |
| Upload to Firebase | `FirebaseImageService().uploadProductImage()` |

---

**Ready to add professional images to your app! 🚀**
