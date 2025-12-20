import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/page_transition.dart';
import '../../widgets/seller_profile_widget.dart';
import '../../widgets/reviews_widget.dart';
import '../../widgets/comments_widget.dart';
import '../../services/firebase_service.dart';
import 'interactive_buyer_home.dart';
import 'messaging_screen.dart';

class SpiceDetailScreen extends StatefulWidget {
  final dynamic spice;

  const SpiceDetailScreen({required this.spice, super.key});

  @override
  State<SpiceDetailScreen> createState() => _SpiceDetailScreenState();
}

class _SpiceDetailScreenState extends State<SpiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _quantity = 1;
  String _sellerName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _loadSellerName();
  }

  Future<void> _loadSellerName() async {
    try {
      final sellerDoc =
          await FirebaseService.getSellerName(widget.spice.sellerId);
      if (mounted) {
        setState(() {
          _sellerName = sellerDoc;
        });
      }
    } catch (e) {
      print('Error loading seller name: $e');
      if (mounted) {
        setState(() {
          _sellerName = 'Unknown Seller';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart() {
    Provider.of<CartProvider>(context, listen: false).addToCart(widget.spice);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.spice.name} added to cart!'),
        backgroundColor: Color(0xFF1B5E4B),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spice = widget.spice;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.push(
                  context, createSmoothTransition(InteractiveBuyerHome())),
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E4B), Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_fire_department,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.orange.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Title & Price
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                spice.name,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade600,
                                    Colors.red.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '\$${spice.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Category Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade400,
                                Colors.purple.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            spice.category ?? 'Exotic',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rating & Reviews
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '4.8 (124 reviews)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Description
                  if (spice.description != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade50,
                                Colors.cyan.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                spice.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 24),
                  // Related Categories Carousel
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Quantity Selector
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade50,
                              Colors.pink.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _quantity > 1
                                      ? () => setState(() => _quantity--)
                                      : null,
                                  child:
                                      Icon(Icons.remove, color: Colors.white),
                                ),
                                SizedBox(width: 16),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.purple.shade300,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_quantity',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade900,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => setState(() => _quantity++),
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Features List
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade50,
                              Colors.green.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Benefits',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildBenefitItem('🌿 100% Natural & Organic'),
                            _buildBenefitItem('✅ Premium Quality'),
                            _buildBenefitItem('🚚 Fast Delivery'),
                            _buildBenefitItem('💯 Satisfaction Guaranteed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Seller Profile Section
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: SellerProfileWidget(
                      sellerId: spice.sellerId,
                      sellerName: _sellerName,
                      rating: 4.8,
                      reviewCount: 342,
                      onMessagePressed: (sellerId, sellerName) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagingScreen(
                              args: MessageScreenArguments(
                                sellerId: sellerId,
                                sellerName: sellerName,
                                buyerId: 'buyer_123',
                                buyerName: 'You',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Reviews Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsWidget(
                      reviews: spice.reviews,
                      averageRating: spice.averageRating,
                      onAddReview: () {
                        _showAddReviewDialog();
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Comments Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: CommentsWidget(
                      comments: spice.comments,
                      onAddComment: () {
                        _showAddCommentDialog();
                      },
                    ),
                  ),
                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade700, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                CurvedAnimation(
                    parent: _animationController, curve: Curves.easeInOut),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                onPressed: _addToCart,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Color(0xFF1B5E4B),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E4B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Write a Review',
              style: TextStyle(
                  color: Color(0xFF1B5E4B), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('How would you rate this product?'),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => rating = (index + 1).toDouble());
                      },
                      child: Icon(
                        index < rating.toInt() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Color(0xFF1B5E4B), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Color(0xFF1B5E4B), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Color(0xFF1B5E4B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1B5E4B),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Thank you for your review!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCommentDialog() {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ask a Question',
            style: TextStyle(
                color: Color(0xFF1B5E4B), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: TextField(
            controller: commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Ask other customers about this product...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF1B5E4B), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF1B5E4B), width: 1.5),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF1B5E4B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1B5E4B),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Your question has been posted!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
