# Quick Troubleshooting Checklist for Image Upload

## Before Testing
- [ ] Flutter dependencies updated: `flutter pub get`
- [ ] No compilation errors: Check "Problems" panel in VS Code
- [ ] App running on web: `flutter run -d chrome`
- [ ] User logged in as Seller
- [ ] Browser console open (F12 → Console tab)

## During Upload Test
1. **Select an image** (at least 40KB recommended)
2. **Fill in spice details**
3. **Click "Add Spice" button**
4. **Watch the console for messages**

## Expected Success Flow

```
✓ Image bytes read: 40.63 KB
✓ Upload attempt 1 starts
✓ Firebase receives upload
✓ Download URL returned
✓ Spice saved to database
✓ Spice list updated with image
✓ Image displays with 🖼️ icon
```

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `hasImage=false, url=NULL` | Upload failed silently | Check browser console for errors, see below |
| **CORS error: Response to preflight request** | Browser blocking request | Clear cache (Ctrl+Shift+Delete), hard reload (Ctrl+F5) |
| `Upload timeout after 90s` | Network/file size | Reduce image size, check internet |
| `auth/permission-denied` | Not authenticated | Log out and back in, refresh token |
| `storage/unknown` | Storage offline/error | Check Firebase Console → Storage tab |
| No error, image not saved | Database error | Check Firestore in Firebase Console |

## Browser Console Tips

### To see all upload logs:
1. Open browser DevTools (F12)
2. Go to Console tab
3. Filter for: `Upload` or `spice`
4. Look for colored emoji messages:
   - 📸 = Upload started
   - 📥 = Reading bytes
   - 📤 = Uploading attempt
   - ⏳ = Retrying
   - ✅ = Success
   - ❌ = Error

### To see network requests:
1. Open DevTools (F12)
2. Go to Network tab
3. Add spice and upload image
4. Look for requests to `firebasestorage.googleapis.com`
5. Check status code (should be 200)

## Step-by-Step Debug

### Step 1: Check Upload Starts
```
Look for: "📸 Uploading image for spice:"
If missing → Image picker failed
```

### Step 2: Check Bytes Read
```
Look for: "📥 Image size: XX.XX KB"
If missing → Image couldn't be read
```

### Step 3: Check Upload Attempt
```
Look for: "📤 Upload attempt 1/5..."
If missing → Code didn't reach upload
```

### Step 4: Check Success
```
Look for: "✅ Upload succeeded on attempt X"
If missing → All 5 retries failed, check errors above
```

### Step 5: Check URL Returned
```
Look for: "🔗 URL: https://firebasestorage..."
If missing → URL generation failed
```

### Step 6: Check Spice Saved
```
Look for: "✅ Image uploaded successfully!"
If missing → Firebase save failed
```

## Network Inspection

### To check if upload requests are being sent:

1. Open DevTools → Network tab
2. Click "Add Spice" button
3. Look for POST requests to `firebasestorage.googleapis.com`
4. Check each request:
   - **Status**: Should be 200 or eventually become 200
   - **Headers**: Check `Authorization` and `Content-Type`
   - **Response**: Should show the uploaded file path

## Log Output Example (Success)

```
📸 Uploading image for spice: 28b31da8-5d73-4731-a43f-80b54bd8be30
📥 Reading image bytes...
📥 Image size: 45.23 KB
📥 File name: photo.jpg
📤 Upload attempt 1/5...
📋 Uploading to: spices/28b31da8-5d73-4731-a43f-80b54bd8be30/1768867263409.jpg
✅ Upload succeeded on attempt 1
🔗 URL: https://firebasestorage.googleapis.com/v0/b/spice-market-49a7b.firebasestorage.app/o/spices%2F28b31da8...
✅ Image uploaded successfully!
🔗 Download URL: https://firebasestorage.googleapis.com/...
```

## Log Output Example (Failure)

```
📸 Uploading image for spice: 28b31da8-5d73-4731-a43f-80b54bd8be30
📥 Reading image bytes...
📥 Image size: 45.23 KB
📥 File name: photo.jpg
📤 Upload attempt 1/5...
❌ Attempt 1 failed: Access to XMLHttpRequest blocked by CORS policy
⏳ Retrying in 500ms... (attempt 1/5)
📤 Upload attempt 2/5...
❌ Attempt 2 failed: Access to XMLHttpRequest blocked by CORS policy
⏳ Retrying in 1000ms... (attempt 2/5)
... (continues with more retries)
❌ Upload failed after 5 attempts
❌ Image upload failed: Upload failed after 5 attempts
```

## Firebase Console Checks

### To verify upload reached Firebase:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: `spice-market-49a7b`
3. Click Storage
4. Navigate to: `spices/` folder
5. Look for today's date → subfolder with spice ID
6. Should see `.jpg` files

### If files appear in Firebase:
✓ Upload succeeded
✗ Issue is elsewhere (database/UI update)

### If files NOT in Firebase:
✗ Upload really failed
- Check browser console errors
- Try different image (smaller size)
- Check network connection

## Still Not Working?

1. **Clear Everything:**
   - Close browser completely
   - `flutter clean`
   - Delete `.dart_tool` folder
   - Run `flutter pub get`
   - Run `flutter run -d chrome`

2. **Check Error Details:**
   - Right-click failed request in Network tab
   - Copy entire response
   - Note the error message

3. **Check Authentication:**
   - Open DevTools → Storage → Local Storage
   - Look for Firebase auth token
   - If not present, user isn't logged in

4. **Test with Different Image:**
   - Try smaller image (< 1MB)
   - Try different format
   - Try from different source

## Contact Support

If still failing, provide:
1. Screenshot of browser console (error messages)
2. Screenshot of Network tab (failed requests)
3. Steps you followed
4. Image file size
5. User account email
