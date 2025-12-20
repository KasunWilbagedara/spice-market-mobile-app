import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/spice_provider.dart';
import '../../utils/page_transition.dart';
import 'spice_detail_screen.dart';

class SellerStoreScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  const SellerStoreScreen({
    required this.sellerId,
    required this.sellerName,
    super.key,
  });

  @override
  State<SellerStoreScreen> createState() => _SellerStoreScreenState();
}

class _SellerStoreScreenState extends State<SellerStoreScreen> {
  String _selectedCategory = 'All';
  final List<String> categories = ['All', 'Spicy', 'Mild', 'Sweet', 'Exotic'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sellerName} Store',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seller Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.orange.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.store,
                      size: 50,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.sellerName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '4.8 (342 reviews)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category Filter
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Colors.orange.shade700,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Products Grid
            Consumer<SpiceProvider>(
              builder: (context, spiceProvider, _) {
                // Filter spices by seller and category
                var sellerSpices = spiceProvider.spices
                    .where((spice) => spice.sellerId == widget.sellerId)
                    .toList();

                if (_selectedCategory != 'All') {
                  sellerSpices = sellerSpices
                      .where((spice) => spice.category == _selectedCategory)
                      .toList();
                }

                if (sellerSpices.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 80,
                          color: Colors.orange.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products in this category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: sellerSpices.length,
                  itemBuilder: (context, index) {
                    final spice = sellerSpices[index];
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        createSmoothTransition(
                          SpiceDetailScreen(spice: spice),
                        ),
                      ),
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Product Image
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  color: Colors.grey.shade100,
                                ),
                                child: spice.imageUrl != null &&
                                        spice.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        spice.imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.local_fire_department,
                                        size: 40,
                                        color: Colors.orange.shade700,
                                      ),
                              ),
                            ),
                            // Product Info
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    spice.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (spice.category != null)
                                    Text(
                                      spice.category!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  SizedBox(height: 6),
                                  Text(
                                    '\$${spice.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade700,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        cartProvider.addToCart(spice);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${spice.name} added to cart',
                                            ),
                                            duration:
                                                Duration(milliseconds: 800),
                                            backgroundColor:
                                                Colors.green.shade700,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
