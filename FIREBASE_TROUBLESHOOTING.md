# Firebase Data Not Saving - Troubleshooting Guide

## Quick Checklist

### ✅ Step 1: Verify Firebase Console Access
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **spice-market-49a7b**
3. Check **Build** → **Firestore Database**
   - Is there a database? (Should see **Production** or **Test Mode** database)
   - If not, click **Create Database**

### ✅ Step 2: Check Firestore Rules
1. In Firebase Console, go **Firestore Database** → **Rules** tab
2. Replace rules with this (for testing):
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
3. Click **Publish**

### ✅ Step 3: Create the Collections (Optional)
Firestore auto-creates collections, but you can pre-create them:
1. In Firestore, click **+ Start collection**
2. Create these collections:
   - `orders`
   - `notifications`
   - `spices`
   - `messages`

---

## Testing Data Save

### Test 1: Manual Save Test
Add this to your checkout screen to test Firebase connection:

```dart
// Add this import at top:
import 'package:cloud_firestore/cloud_firestore.dart';

// Add this method to _CheckoutScreenState:
Future<void> _testFirebase() async {
  try {
    print('🧪 Testing Firebase connection...');
    
    // Test write
    await FirebaseFirestore.instance.collection('test').doc('test-doc').set({
      'message': 'Hello Firebase!',
      'timestamp': DateTime.now().toIso8601String(),
    });
    print('✅ Write successful!');
    
    // Test read
    final doc = await FirebaseFirestore.instance
        .collection('test')
        .doc('test-doc')
        .get();
    print('✅ Read successful: ${doc.data()}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Firebase is working!'), backgroundColor: Colors.green),
    );
  } catch (e) {
    print('❌ Firebase Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
    );
  }
}

// Call this from a button in your UI:
ElevatedButton(
  onPressed: _testFirebase,
  child: Text('Test Firebase'),
)
```

Run the app and click "Test Firebase" button. Check the console output:
- ✅ Should print "Write successful!" and "Read successful!"
- ❌ If you see "Permission denied", Firestore rules are too strict

---

## Common Issues & Solutions

### Issue 1: "Permission denied" Error
**Cause**: Firestore security rules don't allow writes

**Solution**:
1. Go to Firebase Console → Firestore → Rules
2. Copy-paste this:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write;
    }
  }
}
```
3. Click **Publish**
4. Wait 10 seconds and try again

### Issue 2: "No Firestore database found" Error
**Cause**: Firestore isn't created yet

**Solution**:
1. Go to Firebase Console
2. Click **Build** → **Firestore Database**
3. Click **Create Database**
4. Choose region (e.g., `us-east1`)
5. Choose **Test Mode** (for development)
6. Wait for it to initialize (may take 1-2 minutes)

### Issue 3: FirebaseService methods not being called
**Cause**: Checkout might not reach the Firebase code

**Solution**:
- Check console output after placing order
- Should see: `📝 Creating order...` then `✅ Order saved to Firebase successfully!`
- If you don't see these logs, the code isn't running

### Issue 4: Order appears in console but not in Firestore
**Cause**: The code runs but Firebase isn't actually saving

**Solution**:
- Check the console error message carefully
- Most likely Firestore rules issue (see Issue 1)
- Or user isn't authenticated (Firebase thinks it's an anonymous user)

---

## Debugging Steps (Do This)

### Step 1: Run the App and Check Console
```
cd "d:\Projects\hackcheck\mobile app\spice-market-mobile-app"
flutter run
```

Look for console output in VS Code Debug Console.

### Step 2: Trigger the Save
1. Open app
2. Add spice to cart
3. Click "Proceed to Checkout"
4. Fill in billing details
5. Click "Place Order"

### Step 3: Check Console Output
You should see in Debug Console:
```
📝 Creating order: abc123...
✅ Order saved to Firebase successfully!
🔔 Creating seller notification...
✅ Notification sent!
```

**If you DON'T see these**, the code isn't running.
**If you see an error**, that's the issue to fix.

### Step 4: Check Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project **spice-market-49a7b**
3. Go to **Firestore Database** → **Data** tab
4. Look for **orders** collection
5. Should see your order document there

---

## Checklist: What to Verify

- [ ] Firebase project exists and is accessible
- [ ] Firestore Database is created (not just Firebase project)
- [ ] Firestore rules allow reads/writes (use the simple rule above)
- [ ] App runs without errors
- [ ] Checkout shows success message (dialog appears)
- [ ] Console shows "✅ Order saved to Firebase successfully!"
- [ ] Firebase Console shows the order in the orders collection

---

## If Still Not Working

Try this nuclear option:

### Option 1: Reset Firestore Rules to Completely Open
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Option 2: Check if Checkout is Even Reaching Firebase Code
In `checkout_screen.dart`, add this before the Firebase call:

```dart
print('🔍 About to save order...');
print('Order ID: ${order.id}');
print('Buyer ID: ${order.buyerId}');
print('Items: ${order.items.length}');
print('Total: ${order.totalAmount}');

try {
  print('📝 Calling FirebaseService.createOrder...');
  await FirebaseService.createOrder(order);
  print('✅ Success!');
} catch (e) {
  print('❌ Failed: $e');
  print('🔍 Full error: ${e.toString()}');
  rethrow;
}
```

This will show you exactly where it fails.

---

## Production Security Rules (Later)

Once it's working, use proper rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Spices collection - anyone can read
    match /spices/{document=**} {
      allow read;
      allow create, update, delete: if request.auth != null;
    }
    
    // Orders - only buyer can create/read their own
    match /orders/{document=**} {
      allow read: if request.auth.uid == resource.data.buyerId;
      allow create: if request.auth.uid == request.resource.data.buyerId;
    }
    
    // Messages - users can read/write their own
    match /messages/{document=**} {
      allow read: if request.auth.uid == resource.data.senderId || 
                      request.auth.uid == resource.data.receiverId;
      allow create: if request.auth.uid == request.resource.data.senderId;
    }
    
    // Notifications - users can read their own
    match /notifications/{document=**} {
      allow read: if request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## Summary

1. **Firestore Database** must exist (not just Firebase project)
2. **Firestore Rules** must allow reads/writes (use simple rule for testing)
3. **Check console** for error messages after placing order
4. **Check Firebase Console** Data tab to verify data is saved

If data still isn't saving, the error message in the console will tell you why!
