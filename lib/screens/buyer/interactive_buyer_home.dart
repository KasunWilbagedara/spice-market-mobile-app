import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/spice_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/page_transition.dart';
import '../../widgets/logo_widget.dart';
import '../buyer/spice_detail_screen.dart';
import '../buyer/cart_screen_v2.dart';
import '../buyer/buyer_profile.dart';

class InteractiveBuyerHome extends StatefulWidget {
  const InteractiveBuyerHome({super.key});

  @override
  State<InteractiveBuyerHome> createState() => _InteractiveBuyerHomeState();
}

class _InteractiveBuyerHomeState extends State<InteractiveBuyerHome> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<SpiceProvider>(context, listen: false).loadSpices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTabIndex,
        children: const [
          HomeScreen(),
          CartScreenV2(),
          BuyerProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (i) => setState(() => _selectedTabIndex = i),
        selectedItemColor: Color(0xFF1B5E4B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Extracted Home Screen - now won't freeze
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'All',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFFFDEFD3)
    },
    {
      'name': 'Spicy',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFFF6B6B)
    },
    {'name': 'Mild', 'icon': Icons.eco, 'color': Color(0xFF4ECDC4)},
    {'name': 'Sweet', 'icon': Icons.favorite, 'color': Color(0xFFFFD93D)},
    {'name': 'Exotic', 'icon': Icons.star_rounded, 'color': Color(0xFF6BCB77)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> getFilteredSpices(List<dynamic> spices) {
    return spices.where((spice) {
      final matchesSearch =
          spice.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || spice.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spiceProvider = Provider.of<SpiceProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final filteredSpices = getFilteredSpices(spiceProvider.spices);

    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E4B), Color(0xFF2D8659)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              _buildTopSection(cartProvider),
              _buildCategoryList(),
              _buildSectionTitle("Trending Now"),
              _buildYouMightNeedSection(filteredSpices, cartProvider),
              _buildSectionTitle("All Spices"),
              _buildProductGrid(filteredSpices, cartProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection(CartProvider cart) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SpiceMarketLogo(size: 50, showText: false),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search spices',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/welcome');
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: Icon(Icons.logout, color: Color(0xFF1B5E4B), size: 20),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E4B),
            ),
          ),
          Spacer(),
          Text(
            'View All',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF1B5E4B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      child: Column(
        children: [
          SizedBox(
            height: 110,
            child: Center(
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 8),
                children: categories.map((cat) {
                  final selected = _selectedCategory == cat['name'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat['name']),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: AnimatedScale(
                        scale: selected ? 1.15 : 1.0,
                        duration: Duration(milliseconds: 300),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: selected
                                        ? cat['color'].withOpacity(0.4)
                                        : Colors.transparent,
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: selected ? 32 : 28,
                                backgroundColor: selected
                                    ? cat['color']
                                    : Colors.white.withOpacity(0.9),
                                child: AnimatedScale(
                                  scale: selected ? 1.1 : 1.0,
                                  duration: Duration(milliseconds: 300),
                                  child: Icon(
                                    cat['icon'],
                                    color:
                                        selected ? Colors.white : cat['color'],
                                    size: selected ? 24 : 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            AnimatedOpacity(
                              opacity: selected ? 1.0 : 0.8,
                              duration: Duration(milliseconds: 300),
                              child: Text(
                                cat['name'],
                                style: TextStyle(
                                  fontSize: selected ? 13 : 12,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: selected
                                      ? Color(0xFF1B5E4B)
                                      : Color(0xFF1B5E4B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouMightNeedSection(List items, CartProvider cart) {
    final limited = items.take(3).toList();
    if (limited.isEmpty) {
      return SizedBox.shrink();
    }
    return SizedBox(
      height: 260,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          itemCount: limited.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 140,
                child: _buildProductCard(limited[index], cart),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGrid(List items, CartProvider cart) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No spices found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildProductCard(items[i], cart),
    );
  }

  Widget _buildProductCard(dynamic item, CartProvider cart) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        createSmoothTransition(SpiceDetailScreen(spice: item)),
      ),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey.shade100,
                ),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : Icon(Icons.local_fire_department,
                        size: 40, color: Colors.orange),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1B5E4B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "\$${item.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1B5E4B),
                        padding: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        cart.addToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${item.name} added to cart"),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
