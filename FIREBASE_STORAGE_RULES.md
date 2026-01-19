# Firebase Storage Rules Setup

## Overview
The storage.rules file has been created to allow public read access to spice images while maintaining security by requiring authentication for uploads.

## Rules Summary
```
- /spices/* → Public read access ✅, Auth required to write 🔐
- All other paths → Blocked by default 🚫
```

## How to Deploy

### Option 1: Using Firebase CLI (Recommended)
```bash
# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy the rules
firebase deploy --only storage
```

### Option 2: Via Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **spice-market-49a7b**
3. Navigate to **Storage > Rules**
4. Copy the contents of `storage.rules` file
5. Paste into the rules editor
6. Click **Publish**

## Testing
After deploying the rules, images uploaded to `/spices/` folder will be publicly accessible via their download URLs.

The app will:
1. Upload images to: `gs://spice-market-49a7b.appspot.com/spices/{spiceId}/{timestamp}.jpg`
2. Generate download URLs like: `https://firebasestorage.googleapis.com/v0/b/spice-market-49a7b.appspot.com/o/spices%2F...`
3. These URLs will now be publicly readable ✅

## Security Notes
- ✅ Anyone can **read** spice images (public)
- 🔐 Only authenticated users can **upload** (Firebase Auth required)
- 🚫 All other paths are blocked by default

## Troubleshooting
If images still don't load after deploying rules:
1. Clear browser cache (Chrome DevTools > Network > Disable cache, then reload)
2. Wait a few minutes for rules to fully propagate
3. Check browser console for CORS or 403 errors
4. Verify the image URL starts with `https://firebasestorage.googleapis.com`
