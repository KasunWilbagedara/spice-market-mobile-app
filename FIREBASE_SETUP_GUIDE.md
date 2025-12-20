# Firebase Integration Setup Guide

## Overview
Your app now integrates with **Firebase Firestore** to handle real-time data between buyers and sellers.

## What's Been Added

### 1. **FirebaseService** (`lib/services/firebase_service.dart`)
Central service for all database operations:
- **Spices**: Add, view, update, delete products
- **Orders**: Create orders, track status
- **Messages**: Send/receive chat messages
- **Notifications**: Send seller notifications when buyer orders
- **Users**: Save user profile data

### 2. **Updated Checkout** 
When buyer completes purchase:
- Order saved to Firestore
- Seller gets notified automatically
- Cart cleared

## Setup Steps

### Step 1: Enable Firebase Services
Go to [Firebase Console](https://console.firebase.google.com/):

1. Open your project
2. Go to **Build** → **Firestore Database**
3. Click **Create Database**
4. Choose region: `us-east1` (or closest to you)
5. Start in **Test Mode** (for development)

### Step 2: Set Firestore Rules
In Firebase Console, go to **Firestore** → **Rules**

Replace with this for testing (allows all reads/writes):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes for testing
    match /{document=**} {
      allow read, write;
    }
  }
}
```

**⚠️ IMPORTANT**: This is for testing only! Before production, set proper security rules.

### Step 3: Create Firestore Collections

The app will auto-create these when needed, but you can pre-create them:

1. **spices** - Products posted by sellers
   - Fields: name, price, sellerId, description, imageUrl, rating, createdAt

2. **orders** - Purchases made by buyers
   - Fields: buyerId, items[], totalAmount, status, billingDetails, orderDate

3. **messages** - Chat between buyer and seller
   - Fields: senderId, receiverId, message, timestamp, read

4. **notifications** - Alerts for sellers/buyers
   - Fields: userId, title, body, type, timestamp, read

5. **users** - User profile data
   - Fields: uid, name, email, userType (buyer/seller), createdAt

### Step 4: Update Your Code

The `FirebaseService` is already integrated. Now you need to:

#### **In Seller Screen** - When adding a new spice:
```dart
import '../../services/firebase_service.dart';

// When seller creates a product
final spiceId = await FirebaseService.addSpice(spice);
print('Spice saved to Firebase: $spiceId');
```

#### **In Buyer Home** - Show real-time spices:
```dart
FirebaseService.getAllSpices().listen((spices) {
  setState(() {
    this.spices = spices; // Update UI automatically
  });
});
```

#### **In Chat Screen** - Send messages:
```dart
await FirebaseService.sendMessage(
  currentUserId,
  otherUserId,
  messageText,
  'buyer_to_seller',
);
```

#### **In Seller Dashboard** - See orders:
```dart
FirebaseService.getSellerOrders(sellerId).listen((orders) {
  setState(() {
    this.orders = orders; // Show all orders for this seller
  });
});
```

## Data Flow Explanation

### When Seller Adds Product:
```
Seller fills form → Clicks "Post Item" 
  → FirebaseService.addSpice() 
  → Saved to Firestore
  → All buyers see it in real-time (via Stream)
```

### When Buyer Buys:
```
Buyer fills checkout → Clicks "Place Order"
  → FirebaseService.createOrder()
  → Order saved to Firestore
  → FirebaseService.createNotification() 
  → Seller gets notification ✓
```

### When They Chat:
```
Buyer sends message → FirebaseService.sendMessage()
  → Message saved to Firestore
  → Seller sees it in chat screen (via Stream) ✓
```

## How to Test

### Test 1: Add a Spice (Seller)
1. Run the app
2. Go to Seller screen
3. Add a new spice
4. Go to Firebase Console → Firestore → spices collection
5. **See your spice saved there? ✓**

### Test 2: Buy and Notify (Buyer)
1. Add spices to cart
2. Click "Proceed to Checkout"
3. Fill billing details
4. Click "Place Order"
5. Go to Firebase Console → Firestore → orders collection
6. **See your order? ✓**
7. Check notifications collection
8. **See seller notification? ✓**

### Test 3: Chat (Both)
1. Open messaging screen
2. Send a message
3. Go to Firebase Console → Firestore → messages collection
4. **See message stored? ✓**

## Common Issues & Fixes

### "No Firestore database found"
**Fix**: Go to Firebase Console → Create Firestore Database (Step 1 above)

### "Permission denied" errors
**Fix**: Update Firestore Rules to allow reads/writes (Step 2 above)

### "FirebaseService not found" compile error
**Fix**: Make sure `firebase_service.dart` is in `lib/services/` folder

### Real-time updates not working
**Fix**: Check that you're using `.stream` or `StreamBuilder`:
```dart
// ✓ Correct - uses Stream
StreamBuilder(
  stream: FirebaseService.getAllSpices(),
  builder: (context, snapshot) { ... }
)

// ✗ Wrong - won't update in real-time
FutureBuilder(
  future: FirebaseService.getAllSpices(),
  builder: (context, snapshot) { ... }
)
```

## Next Steps

### 1. Update Spice Model
Add `sellerId` field to track who posted each spice:
```dart
class Spice {
  final String id;
  final String name;
  final String sellerId; // Add this
  // ... other fields
}
```

### 2. Update Cart Items
Track seller ID so you know who gets the money:
```dart
{
  'spiceId': 'xxx',
  'spiceName': 'Turmeric',
  'price': 5.99,
  'sellerId': 'seller_uid', // Add this
  'quantity': 1,
}
```

### 3. Seller Gets Notification
In seller dashboard, show:
```dart
StreamBuilder(
  stream: FirebaseService.getNotifications(sellerId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      // Show list of notifications
    }
  },
)
```

### 4. Add Push Notifications (Optional)
To notify sellers on their phone, add Firebase Cloud Messaging (FCM):
- Follow [Firebase Cloud Messaging Guide](https://firebase.flutter.dev/docs/messaging/overview/)

## Security Rules for Production

When you're ready to go live, update Firestore Rules to:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Anyone can read spices
    match /spices/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        request.resource.data.sellerId == request.auth.uid;
    }
    
    // Users can read their own orders
    match /orders/{document=**} {
      allow read: if request.auth.uid == resource.data.buyerId;
      allow create: if request.auth.uid == request.resource.data.buyerId;
    }
    
    // Users can read/write their messages
    match /messages/{document=**} {
      allow read: if request.auth.uid == resource.data.senderId || 
                      request.auth.uid == resource.data.receiverId;
      allow create: if request.auth.uid == request.resource.data.senderId;
    }
    
    // Users get their own notifications
    match /notifications/{document=**} {
      allow read: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## Summary

✅ **What you have:**
- Firebase database service ready to use
- Checkout saves orders to Firestore
- Sellers get notified when someone buys

✅ **What to do next:**
1. Enable Firestore in Firebase Console
2. Update your seller screen to use `FirebaseService.addSpice()`
3. Update your buyer home to use `FirebaseService.getAllSpices()`
4. Update messaging to use `FirebaseService.sendMessage()`
5. Test each feature with Firebase Console

That's it! Your app now has real-time data sync. 🎉
