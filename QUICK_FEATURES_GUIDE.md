# Quick Start Guide - New Features

## Feature 1: Checkout with Billing Details

### How to Access:
1. Navigate to cart page
2. Add spices to cart
3. Click "Proceed to Checkout" button

### Steps:
**Step 1 - Billing Details**
```
- Full Name: Your name
- Email: your.email@example.com
- Phone Number: +1234567890
- Street Address: 123 Main Street
- City: New York
- State: NY
- Zip Code: 10001
```
Click "Continue" to proceed to bank details

**Step 2 - Bank Details**
```
- Account Holder Name: Account owner name
- Bank Name: Your Bank Name
- Account Number: 1234567890123456
- IFSC Code: BANK0001
```
Click "Continue" to review order

**Step 3 - Order Summary**
- Review items and total amount
- Confirm billing address
- Click "Checkout" to complete payment

**Success**: Order confirmation dialog appears with Order ID

---

## Feature 2: Reviews and Comments

### Where to Find:
On any spice detail page, scroll down to see:

**Customer Reviews Section:**
- Average rating (e.g., 4.7/5)
- Rating distribution bar
- Individual reviews with:
  - User name and avatar
  - Star rating
  - Review text
  - Number of helpful votes
- "Write a Review" button

**Questions & Answers Section:**
- Customer questions with seller answers
- User names and timestamps
- "Ask" button to post new questions
- "Helpful" and "Reply" buttons for each question

### Example Data (Pre-populated):
**Reviews:**
1. John Doe - 5 stars - "Excellent quality spice! Highly recommended."
2. Sarah Smith - 4 stars - "Great flavor and aroma. Packaging could be better."
3. Mike Johnson - 5 stars - "Premium quality, fresh and aromatic."

**Q&A:**
1. Q: "Is this organic?" 
   A: "Yes, all our spices are 100% organic and sourced from certified farms."
2. Q: "What is the expiry date?"
   A: "Each pack has a 2-year shelf life from the manufacturing date."

---

## Feature 3: Buyer-Seller Messaging

### How to Access:
1. Open any spice detail page
2. Find "Seller Information" card
3. Click "Message Seller" button (green button with message icon)

### Messaging Interface:
- **Header**: Seller name and "Online" status
- **Chat Area**: Message bubbles
  - Your messages: White background on right
  - Seller messages: Grey background on left
  - Timestamps showing when message was sent
- **Input Field**: Text area at bottom to type messages
- **Send Button**: Green button with send icon

### Features:
- Auto-scroll to latest messages
- Messages sent immediately with timestamp
- Simulated seller response after 2 seconds
- Timestamps formatted as "X days ago" or "HH:MM"
- Sample conversation already loaded

### Example Conversation:
```
Seller (30 min ago): "Hello! Thanks for your interest in our products."

You (25 min ago): "Hi! I have a question about the spice quality."

Seller (20 min ago): "Of course! All our spices are premium quality 
and sourced directly from farmers."
```

---

## Form Validation Details

### Billing Details Validation:
- **Full Name**: Required, not empty
- **Email**: Required, valid email format
- **Phone**: Required, min 10 digits (numbers only)
- **Address**: Required, not empty
- **City**: Required, not empty
- **State**: Required, not empty
- **Zip Code**: Required, not empty

### Bank Details Validation:
- **Account Holder Name**: Required, not empty
- **Bank Name**: Required, not empty
- **Account Number**: Required, numeric
- **IFSC Code**: Required, not empty

### Error Messages:
If validation fails, you'll see:
- "Full name is required"
- "Enter a valid email"
- "Enter a valid phone number"
- etc.

Correct the field and try again.

---

## Data Persistence

**Current Implementation (Demo):**
- Reviews and comments are sample data
- Messages are simulated with auto-responses
- Orders are not persisted to database
- Cart clears after successful checkout

**For Production:**
- Connect to Firebase/Backend database
- Implement real payment processing
- Save orders with user accounts
- Store messaging history
- Create seller response notifications

---

## File Structure Reference

```
lib/
├── models/
│   ├── order.dart (NEW)
│   ├── message.dart (NEW)
│   ├── spice.dart (UPDATED)
│   └── ...
├── screens/buyer/
│   ├── checkout_screen.dart (NEW)
│   ├── messaging_screen.dart (NEW)
│   ├── cart_screen.dart (UPDATED)
│   ├── spice_detail_screen.dart (UPDATED)
│   └── ...
├── services/
│   ├── spice_service.dart (UPDATED)
│   └── ...
├── widgets/
│   ├── seller_profile_widget.dart (UPDATED)
│   ├── reviews_widget.dart (unchanged)
│   ├── comments_widget.dart (unchanged)
│   └── ...
├── utils/
│   ├── validators.dart (UPDATED)
│   └── ...
└── main.dart (UPDATED)
```

---

## Troubleshooting

**Checkout button not showing?**
- Make sure you have items in your cart
- Check cart_screen.dart is imported correctly

**Reviews not showing?**
- Scroll down on the spice detail page
- Check that spice_service.dart is using Spice.withSampleData()

**Message screen not opening?**
- Click the "Message Seller" button (not "View Store")
- Make sure you're on the spice detail page

**Form validation not working?**
- Check all fields are filled
- Email must have @ and . (e.g., test@example.com)
- Phone must have at least 10 digits

---

## Testing Commands

```bash
# Check for compilation errors
flutter analyze --no-fatal-infos

# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d emulator-5554
flutter run -d iphone-simulator
```

---

## Success Indicators

✓ Checkout flow completes with order confirmation
✓ Reviews section shows 3 sample reviews
✓ Q&A section shows 2 sample questions with answers
✓ Message Seller button opens messaging screen
✓ Can type and send messages
✓ Seller sends automated response after 2 seconds
✓ No compilation errors (warnings are acceptable)
✓ All form fields validate correctly

