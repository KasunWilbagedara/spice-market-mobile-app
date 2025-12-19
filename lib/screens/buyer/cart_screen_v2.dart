import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreenV2 extends StatelessWidget {
  const CartScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final total = cartProvider.total;

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        title: Text('Shopping Cart',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF1B5E4B),
        elevation: 2,
      ),
      body: cartProvider.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Color(0xFF1B5E4B).withOpacity(0.3)),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B5E4B),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Continue Shopping',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final spice = cartProvider.cartItems[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFFFFF8F0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Spice Icon
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange.shade700,
                                    size: 40,
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Spice Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spice.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B5E4B),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      if (spice.description != null)
                                        Text(
                                          spice.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600),
                                        ),
                                      SizedBox(height: 8),
                                      Text(
                                        '\$${spice.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove Button
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.red, size: 28),
                                  onPressed: () {
                                    cartProvider.removeFromCart(spice);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${spice.name} removed from cart'),
                                        backgroundColor: Colors.red.shade700,
                                        duration: Duration(milliseconds: 800),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Checkout Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 2)),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700)),
                          Text('\$${total.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shipping:',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700)),
                          Text('\$${(total * 0.1).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax:',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700)),
                          Text('\$${(total * 0.08).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      Divider(height: 20, thickness: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E4B)),
                          ),
                          Text(
                            '\$${(total + (total * 0.1) + (total * 0.08)).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                cartProvider.clear();
                              },
                              child: Text('Clear Cart',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1B5E4B),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Order placed successfully!'),
                                    backgroundColor: Colors.green.shade700,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                cartProvider.clear();
                              },
                              child: Text('Checkout',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
