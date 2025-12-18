import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/spice_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/page_transition.dart';
import '../buyer/spice_detail_screen.dart';
import '../buyer/cart_screen_v2.dart';
import '../buyer/buyer_profile.dart';

class InteractiveBuyerHome extends StatefulWidget {
  const InteractiveBuyerHome({super.key});

  @override
  State<InteractiveBuyerHome> createState() => _InteractiveBuyerHomeState();
}

class _InteractiveBuyerHomeState extends State<InteractiveBuyerHome> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _selectedTabIndex = 0;
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
      'color': Color(0xFFFFE0B2)
    },
    {'name': 'Mild', 'icon': Icons.eco, 'color': Color(0xFFDCEDC8)},
    {'name': 'Sweet', 'icon': Icons.favorite, 'color': Color(0xFFFFF9C4)},
    {'name': 'Exotic', 'icon': Icons.star_rounded, 'color': Color(0xFFD7CCC8)},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<SpiceProvider>(context, listen: false).loadSpices());
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

    Widget currentScreen;
    if (_selectedTabIndex == 0) {
      currentScreen = Stack(
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: Color(0xFF1B5E4B),
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
                _buildYouMightNeedSection(filteredSpices, cartProvider),
                _buildProductGrid(filteredSpices, cartProvider),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedTabIndex == 1) {
      currentScreen = CartScreenV2();
    } else {
      currentScreen = BuyerProfile();
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(_selectedTabIndex),
          child: currentScreen,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (i) => setState(() => _selectedTabIndex = i),
        selectedItemColor: Color(0xFF1B5E4B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTopSection(CartProvider cart) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search spices',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.shopping_cart),
                  ),
                  if (cart.cartItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          cart.cartItems.length.toString(),
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🔴 THIS METHOD WAS CAUSING THE ERROR – NOW FIXED
  Widget _buildCategoryList() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: categories.map((cat) {
                final selected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['name']),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: AnimatedScale(
                      scale: selected ? 1.15 : 1.0,
                      duration: Duration(milliseconds: 300),
                      child: Column(
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
                              backgroundColor:
                                  selected ? cat['color'] : Colors.white,
                              child: AnimatedScale(
                                scale: selected ? 1.1 : 1.0,
                                duration: Duration(milliseconds: 300),
                                child: Icon(
                                  cat['icon'],
                                  color: selected
                                      ? Colors.white
                                      : Color(0xFF1B5E4B).withOpacity(0.6),
                                  size: selected ? 24 : 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          AnimatedOpacity(
                            opacity: selected ? 1.0 : 0.7,
                            duration: Duration(milliseconds: 300),
                            child: Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: selected ? 13 : 12,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: selected
                                    ? Color(0xFF1B5E4B)
                                    : Colors.grey.shade700,
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
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 4,
                  width: 25,
                  margin: EdgeInsets.only(left: _getIndicatorPosition()),
                  decoration: BoxDecoration(
                    color: Color(0xFF1B5E4B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getIndicatorPosition() {
    final index = categories.indexWhere((c) => c['name'] == _selectedCategory);
    return index < 0 ? 0 : index * 90.0;
  }

  Widget _buildYouMightNeedSection(List items, CartProvider cart) {
    final limited = items.take(3).toList();
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: limited
            .map((e) => Expanded(child: _buildProductCard(e, cart)))
            .toList(),
      ),
    );
  }

  Widget _buildProductGrid(List items, CartProvider cart) {
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
        child: Column(
          children: [
            Expanded(
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.local_fire_department, size: 40),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("\$${item.price.toStringAsFixed(2)}"),
                  ElevatedButton(
                    onPressed: () {
                      cart.addToCart(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${item.name} added")),
                      );
                    },
                    child: Icon(Icons.add),
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
