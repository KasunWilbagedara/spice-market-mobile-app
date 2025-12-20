import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/validators.dart';
import '../../services/firebase_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final uuid = Uuid();
  int _currentStep = 0;
  bool _isProcessing = false;

  // Billing Details Form Fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Bank Details Form Fields
  final _bankAccountNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankNameController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  void _validateAndContinue() {
    if (_currentStep == 0) {
      // Validate billing details
      if (_fullNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Full name is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!isValidEmail(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enter a valid email'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!isValidPhone(_phoneController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enter a valid phone number'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('City is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_stateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('State is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_zipCodeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zip code is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      // Validate bank details
      if (_bankAccountNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account holder name is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_bankNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bank name is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_bankAccountNumberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account number is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_ifscCodeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('IFSC code is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      _processPayment();
    }
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Create billing details
      final billingDetails = BillingDetails(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        bankAccountName: _bankAccountNameController.text,
        bankAccountNumber: _bankAccountNumberController.text,
        bankName: _bankNameController.text,
        ifscCode: _ifscCodeController.text,
      );

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Simulate payment processing
      await Future.delayed(Duration(seconds: 2));

      // Create order
      final order = Order(
        id: uuid.v4(),
        buyerId: authProvider.user?.id ?? 'guest_buyer',
        items: cartProvider.cartItems
            .map((item) => {
                  'spiceId': item.id,
                  'spiceName': item.name,
                  'price': item.price,
                  'quantity': 1,
                })
            .toList(),
        totalAmount: cartProvider.total,
        billingDetails: billingDetails,
        orderDate: DateTime.now(),
        status: 'completed',
      );

      // Save order to Firebase
      print('📝 Creating order: ${order.id}');
      await FirebaseService.createOrder(order);
      print('✅ Order saved to Firebase successfully!');

      // Create notification for seller
      print('🔔 Creating seller notification...');
      await FirebaseService.createNotification(
        'seller_id', // You'll get actual seller ID from cart items
        'New Order Received!',
        'You have a new order for \$${order.totalAmount.toStringAsFixed(2)}',
        'order_received',
      );
      print('✅ Notification sent!');

      // Clear cart after successful order
      cartProvider.clear();

      setState(() => _isProcessing = false);

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Order Confirmed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your order has been placed successfully!'),
                SizedBox(height: 16),
                _buildOrderConfirmationSummary(order),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B5E4B),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to cart
                },
                child:
                    Text('Back to Cart', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      print('❌ Payment Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildOrderConfirmationSummary(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order ID: ${order.id.substring(0, 12)}...',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text('Items: ${order.items.length}'),
        SizedBox(height: 8),
        Text(
          'Total: \$${order.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Color(0xFF1B5E4B),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1B5E4B),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Processing your order...'),
                ],
              ),
            )
          : _buildCheckoutBody(),
    );
  }

  Widget _buildCheckoutBody() {
    return Column(
      children: [
        // Step indicator
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStepIndicator(0, 'Billing'),
              _buildStepIndicator(1, 'Bank'),
              _buildStepIndicator(2, 'Review'),
            ],
          ),
        ),
        Divider(),
        // Form content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildCurrentStepForm(),
            ),
          ),
        ),
        // Buttons
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _currentStep--);
                    },
                    child: Text('Back', style: TextStyle(color: Colors.white)),
                  ),
                ),
              if (_currentStep > 0) SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B5E4B),
                  ),
                  onPressed: _validateAndContinue,
                  child: Text(
                    _currentStep == 2 ? 'Place Order' : 'Continue',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Color(0xFF1B5E4B) : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? Color(0xFF1B5E4B) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepForm() {
    switch (_currentStep) {
      case 0:
        return _buildBillingDetailsForm();
      case 1:
        return _buildBankDetailsForm();
      case 2:
        return _buildOrderSummaryStep();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildBillingDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E4B),
          ),
        ),
        SizedBox(height: 24),
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Street Address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home),
          ),
          maxLines: 2,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _zipCodeController,
          decoration: InputDecoration(
            labelText: 'Zip Code',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildBankDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E4B),
          ),
        ),
        SizedBox(height: 24),
        TextField(
          controller: _bankAccountNameController,
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _bankNameController,
          decoration: InputDecoration(
            labelText: 'Bank Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _bankAccountNumberController,
          decoration: InputDecoration(
            labelText: 'Account Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        TextField(
          controller: _ifscCodeController,
          decoration: InputDecoration(
            labelText: 'IFSC Code',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.code),
          ),
        ),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your bank details are securely encrypted.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryStep() {
    final cartProvider = Provider.of<CartProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E4B),
          ),
        ),
        SizedBox(height: 20),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E4B),
                  ),
                ),
                SizedBox(height: 12),
                ...cartProvider.cartItems.map((item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${cartProvider.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E4B),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _fullNameController.text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(_addressController.text),
                Text(
                    '${_cityController.text}, ${_stateController.text} ${_zipCodeController.text}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
