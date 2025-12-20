import 'package:flutter/material.dart';
import '../screens/buyer/seller_store_screen.dart';

class SellerProfileWidget extends StatelessWidget {
  final String sellerId;
  final String sellerName;
  final double rating;
  final int reviewCount;
  final Function(String, String)? onMessagePressed;

  const SellerProfileWidget({
    required this.sellerId,
    required this.sellerName,
    this.rating = 4.5,
    this.reviewCount = 128,
    this.onMessagePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Seller Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E4B),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.store, color: Colors.white, size: 40),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E4B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '$rating',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '($reviewCount reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                      backgroundColor: Color(0xFF1B5E4B),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (onMessagePressed != null) {
                        onMessagePressed!(sellerId, sellerName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening message screen...'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Message',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to seller store
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerStoreScreen(
                            sellerId: sellerId,
                            sellerName: sellerName,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('View Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
