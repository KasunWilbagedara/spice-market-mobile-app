# Debug Guide: Image Upload Issues

## Problem
Images are not being saved when adding a spice. The spice is created but without the image URL.

## Why This Happens
1. **Firebase Storage upload fails** - Network error, authentication issue, or permission denied
2. **Upload times out** - Takes longer than 60 seconds
3. **Invalid download URL returned** - Upload succeeds but URL is malformed
4. **Firestore security rules block writes** - Upload succeeds but spice creation fails

## Debugging Steps

### Step 1: Check Console Logs
Open Chrome DevTools while testing:
1. Press `F12` in the browser
2. Go to **Console** tab
3. Look for these log messages:

**SUCCESS FLOW:**
```
📤 Uploading image for new spice: [spice-id]
📥 Reading image bytes...
📥 Image size: 125.50 KB
📤 Uploading to Firebase...
🔗 Getting download URL...
✅ Image uploaded successfully!
🔗 Download URL: https://firebasestorage.googleapis.com/...
📋 Upload returned: "https://firebasestorage.googleapis.com/..."
✅ Valid Firebase Storage URL received
📦 Creating spice object:
  ImageURL: https://firebasestorage.googleapis.com/...
💾 Saving spice to Firestore: [spice-name]
📷 Image URL being saved: "https://firebasestorage.googleapis.com/..."
✅ Spice saved with Firestore ID: [doc-id]
```

**FAILURE FLOW - Look for:**
- `❌ Image upload failed:` - Check the error message
- `⚠️ Image upload timeout after 60s` - Upload took too long
- `❌ Upload exception caught:` - Exception occurred
- `Image: ✗ NONE` - URL not received (check previous logs)

### Step 2: Check User Notifications
When you click "Add Spice":
- ✅ **Blue notification** = Saving spice WITH image
- 🟠 **Orange notification** = Saving spice WITHOUT image (check console for reason)
- 🔴 **Red notification** = Upload error occurred

The notification message tells you what went wrong.

### Step 3: Check Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select **spice-market-49a7b** project
3. Check **Firestore > spices collection**
   - Look at a spice document
   - The `imageUrl` field should contain a URL starting with `https://`
4. Check **Storage > spices folder**
   - Images should be uploaded there as `.jpg` files

### Step 4: Deploy Firebase Rules
If uploads succeed but URLs don't work, rules might be blocking access:

```bash
cd "D:\Projects\hackcheck\mobile app\spice-market-mobile-app"
deploy-storage-rules.bat
```

Or manually:
```bash
firebase login
firebase deploy --only firestore,storage
```

## Common Issues & Fixes

### Issue: "Failed to upload image: Permission denied"
**Cause:** Firebase Storage rules are too restrictive
**Fix:** Deploy the `storage.rules` file

### Issue: "Image upload timeout after 60s"
**Cause:** Network is slow or Firebase Storage is unreachable
**Fix:** 
- Check internet connection
- Try with a smaller image (compress before uploading)
- Check Firebase project is active and storage bucket exists

### Issue: "URL does not start with http"
**Cause:** getDownloadURL() returned something unexpected
**Fix:** 
- Check Firebase Storage bucket is correctly initialized
- Verify firebase_options.dart has correct storageBucket value

### Issue: Spice saved but image field is empty
**Cause:** Upload failed but didn't show error properly
**Fix:** 
- Check browser console (F12) for error details
- Look for `❌` or `⚠️` messages

## Testing Checklist

- [ ] 1. Open Chrome DevTools (F12)
- [ ] 2. Go to Console tab
- [ ] 3. Launch app: `flutter run -d chrome`
- [ ] 4. Navigate to Seller section
- [ ] 5. Click "+ Add Spice"
- [ ] 6. Fill in: Name, Price, Category
- [ ] 7. Click image area to select a photo
  - [ ] Check console shows: "📤 Uploading image for new spice:"
  - [ ] Check console shows upload progress
  - [ ] Look for final URL in console
- [ ] 8. Click "Add Spice" button
  - [ ] Check notification color (blue = with image, orange = without)
  - [ ] Check console for any ❌ or ⚠️ messages
- [ ] 9. Navigate back to seller home
- [ ] 10. Check if spice appears with image thumbnail
  - [ ] Look for "Image: ✓" text in the list
  - [ ] Thumbnail should show the uploaded image

## If All Else Fails

1. Check network tab in DevTools (F12 > Network)
2. Look for failed requests to `firebasestorage.googleapis.com`
3. Note the exact error status code
4. Share console logs with error messages

## Files Involved

- `lib/screens/seller/add_spice_screen.dart` - Handles upload
- `lib/services/firebase_service.dart` - Firebase operations
- `storage.rules` - Storage permissions
- `firestore.rules` - Firestore permissions
