@echo off
REM Firebase Deployment Script for Spice Market Mobile App
REM This script deploys both Firestore and Storage rules

echo ========================================
echo Firebase Rules Deployment
echo ========================================
echo.

echo Step 1: Checking Firebase CLI...
firebase --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Firebase CLI not found!
    echo Please install it first:
    echo   npm install -g firebase-tools
    pause
    exit /b 1
)
echo ✓ Firebase CLI is installed

echo.
echo Step 2: Login to Firebase...
echo (If you're already logged in, you can skip)
firebase login --no-localhost

echo.
echo Step 3: Deploying Firestore and Storage Rules...
echo This allows:
echo  - Public read access to spice images
echo  - Authenticated users to upload images
echo  - Authenticated users to create spices
echo.
firebase deploy --only firestore,storage

if errorlevel 0 (
    echo.
    echo ========================================
    echo ✓ DEPLOYMENT SUCCESSFUL!
    echo ========================================
    echo.
    echo Your Firebase is now configured to:
    echo  - Allow PUBLIC read access to /spices/* folder
    echo  - Require authentication for uploads/writes
    echo.
    echo You can now:
    echo  1. Run: flutter run -d chrome
    echo  2. Upload images in the app
    echo  3. Images will display in the seller list
    echo.
    pause
) else (
    echo.
    echo ========================================
    echo ✗ DEPLOYMENT FAILED
    echo ========================================
    echo.
    echo Please check the errors above and:
    echo  1. Ensure you're logged in: firebase login
    echo  2. Ensure project ID is correct: spice-market-49a7b
    echo  3. Check Firebase console for status
    echo.
    pause
    exit /b 1
)

