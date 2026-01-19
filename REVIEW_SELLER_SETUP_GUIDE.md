# Review System & Seller Name Setup Guide

## Features Implemented

### 1. **Add Buyer Reviews**
- Users can click "Write a Review" button on any spice detail page
- Reviews include:
  - Star rating (1-5 stars)
  - Review text/comment
  - Automatically saved with timestamp
  - Display name set to "Anonymous" (can be updated to show buyer name)
- All reviews are saved to Firebase and persist across sessions
- Average rating is automatically calculated and updated

### 2. **Seller Name Display**
The app now shows the actual seller's name instead of abbreviated ID like "Seller F2sPpGAw..."

## How to Set Up Seller Names

### Option 1: Automatic Setup (Recommended)

1. **Edit the seller mapping** in `lib/utils/seller_setup.dart`:
```dart
static const Map<String, String> sellerProfiles = {
  'F2sPpGAw': 'janiduwilbagedara',  // Replace with your actual seller ID and name
  // Add more sellers: 'sellerId': 'Seller Name',
};
```

2. **Call the setup function** from your main.dart or during app initialization:
```dart
import 'utils/seller_setup.dart';

void main() async {
  // ... other initialization code ...
  
  // Initialize seller profiles (call this once)
  await SellerSetup.initializeSellerProfiles();
  
  runApp(const MyApp());
}
```

### Option 2: Manual Firebase Setup

If you prefer to set up manually in Firebase Console:

1. Go to Firestore Database
2. Navigate to the `users` collection
3. Create a document with ID matching your seller ID (e.g., `F2sPpGAw`)
4. Add these fields:
   ```
   - id: F2sPpGAw
   - name: janiduwilbagedara
   - role: seller
   ```

### Option 3: Add Seller During New Spice Creation

When a seller creates/uploads a new spice, the seller name is automatically fetched from their user profile and stored in the spice document.

## How Reviews Work

### Viewing Reviews
- All reviews appear on the spice detail page
- Shows average rating and distribution chart
- Lists all submitted reviews with ratings and comments

### Adding Reviews
1. User clicks "Write a Review" button
2. Selects star rating (1-5)
3. Writes review comment
4. Clicks "Submit"
5. Review is saved to Firebase
6. Appears immediately in the spice detail page

### Review Data Stored
```dart
{
  'id': 'timestamp',
  'rating': 5,
  'text': 'Great product!',
  'timestamp': '2026-01-19T...',
  'userName': 'Anonymous'
}
```

## Accessing Seller Setup

You can also add sellers programmatically in your app:

```dart
// Add a single seller
SellerSetup.addSellerProfile('F2sPpGAw', 'janiduwilbagedara');

// Or initialize all at once
SellerSetup.initializeSellerProfiles();
```

## Testing

1. **Test Reviews:**
   - Navigate to any spice detail page
   - Click "Write a Review"
   - Add a rating and comment
   - Submit and verify it appears in the reviews section

2. **Test Seller Names:**
   - Ensure seller profile is set up in Firebase
   - Go to spice detail page
   - Verify "Seller Information" shows actual name, not ID

## Troubleshooting

### Reviews not showing after submit
- Check Firebase console to verify review data is saved
- The spice detail page may need to be refreshed (navigate away and back)
- Check browser console for any errors

### Seller name still showing as abbreviated ID
- Verify the seller user document exists in Firebase `users` collection
- Check that the "name" field is populated
- Call `SellerSetup.initializeSellerProfiles()` if using the setup utility

### Spice not showing in buyer home
- Make sure spice was created successfully in Firebase
- Verify the spice document has required fields: id, name, price, sellerId

## Files Modified

1. `lib/services/firebase_service.dart` - Added `createSellerProfile()` and `updateSellerSpicesWithName()`
2. `lib/screens/buyer/spice_detail_screen.dart` - Enhanced review submission
3. `lib/utils/seller_setup.dart` - New utility for easy seller setup
4. `lib/screens/buyer/checkout_screen.dart` - Shows seller names in cart items
5. `lib/widgets/seller_profile_widget.dart` - Displays seller information on detail page
