import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/spice_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_spice_screen.dart';
import 'edit_profile_screen.dart';
import 'seller_messages_screen.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  _SellerHomeState createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showOnlyMySpices = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = ['All', 'Spicy', 'Mild', 'Sweet', 'Exotic'];

  @override
  void initState() {
    super.initState();
    final spiceProvider = Provider.of<SpiceProvider>(context, listen: false);
    spiceProvider.loadSpices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> getFilteredSpices(
      List<dynamic> spices, String currentSellerId) {
    return spices.where((spice) {
      final matchesSearch =
          spice.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (spice.description
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false);
      final matchesCategory =
          _selectedCategory == 'All' || spice.category == _selectedCategory;
      final matchesSeller =
          !_showOnlyMySpices || spice.sellerId == currentSellerId;
      return matchesSearch && matchesCategory && matchesSeller;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spiceProvider = Provider.of<SpiceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final filteredSpices =
        getFilteredSpices(spiceProvider.spices, auth.user?.id ?? '');
    final mySpicesCount =
        spiceProvider.spices.where((s) => s.sellerId == auth.user?.id).length;
    final mySpicesTotalValue = spiceProvider.spices
        .where((s) => s.sellerId == auth.user?.id)
        .fold<double>(0, (sum, spice) => sum + spice.price);

    if (_selectedIndex == 1) {
      // Add Spice tab - navigate to add screen and reset index
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddSpiceScreen()))
            .then((_) {
          setState(() => _selectedIndex = 0);
        });
      });
      return WillPopScope(
        onWillPop: () async => false,
        child: _buildHomeScreen(auth, spiceProvider, filteredSpices),
      );
    }

    if (_selectedIndex == 2) {
      return WillPopScope(
        onWillPop: () async => false,
        child: SellerMessagesScreen(),
      );
    }

    if (_selectedIndex == 3) {
      return WillPopScope(
        onWillPop: () async => false,
        child: _buildProfileTab(
            auth, spiceProvider, mySpicesCount, mySpicesTotalValue),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: _buildHomeScreen(auth, spiceProvider, filteredSpices),
    );
  }

  Widget _buildHomeScreen(AuthProvider auth, SpiceProvider spiceProvider,
      List<dynamic> filteredSpices) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🌶️ Spice Market Seller',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Stats Card
            Container(
              color: Colors.orange.shade700,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Listings',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 4),
                      Text(
                          '${spiceProvider.spices.where((s) => s.sellerId == auth.user?.id).length}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total Value',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 4),
                      Text(
                          '\$${spiceProvider.spices.where((s) => s.sellerId == auth.user?.id).fold<double>(0, (sum, spice) => sum + spice.price).toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search spices...',
                  prefixIcon: Icon(Icons.search, color: Colors.orange.shade700),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon:
                              Icon(Icons.clear, color: Colors.orange.shade700),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange.shade300)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Toggle: My Spices vs All Spices
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showOnlyMySpices = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_showOnlyMySpices
                              ? Colors.orange.shade700
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Center(
                          child: Text('All Spices',
                              style: TextStyle(
                                  color: !_showOnlyMySpices
                                      ? Colors.white
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showOnlyMySpices = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _showOnlyMySpices
                              ? Colors.orange.shade700
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Center(
                          child: Text('My Spices',
                              style: TextStyle(
                                  color: _showOnlyMySpices
                                      ? Colors.white
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.orange.shade700 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.orange.shade300, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),

            // Spices List/Grid
            Expanded(
              child: filteredSpices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department,
                              size: 80, color: Colors.orange.shade300),
                          SizedBox(height: 16),
                          Text('No spices found',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade700)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: filteredSpices.length,
                      itemBuilder: (context, index) {
                        final spice = filteredSpices[index];
                        final isMySpice = spice.sellerId == auth.user?.id;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.orange.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isMySpice
                                      ? Colors.green.shade200
                                      : Colors.orange.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: spice.imageUrl != null &&
                                        spice.imageUrl!.startsWith('/')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          spice.imageUrl! as dynamic,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.local_fire_department,
                                        color: isMySpice
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                        size: 30,
                                      ),
                              ),
                              title: Text(
                                spice.name,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  if (spice.category != null)
                                    Text('Category: ${spice.category}',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text(
                                      'Price: \$${spice.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700)),
                                  if (!isMySpice)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                          'Seller ID: ${spice.sellerId}',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500)),
                                    ),
                                  if (isMySpice)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text('Your Listing',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: isMySpice
                                  ? IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: Colors.red.shade700, size: 24),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Delete Spice?'),
                                            content: Text(
                                                'Are you sure you want to delete ${spice.name}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  spiceProvider
                                                      .removeSpice(spice.id);
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Spice deleted'),
                                                        backgroundColor:
                                                            Colors.red),
                                                  );
                                                },
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Add Spice'),
          BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildProfileTab(AuthProvider auth, SpiceProvider spiceProvider,
      int mySpicesCount, double mySpicesTotalValue) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Profile',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/seller_home'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.store,
                        size: 50, color: Colors.orange.shade700),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${auth.user?.name}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EditProfileScreen()))
                    .then((_) {
                  setState(() {});
                });
              },
              icon: Icon(Icons.edit),
              label: Text('Edit Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade200, blurRadius: 4)
                        ]),
                    child: Column(
                      children: [
                        Text('My Listings',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        SizedBox(height: 8),
                        Text('$mySpicesCount',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade200, blurRadius: 4)
                        ]),
                    child: Column(
                      children: [
                        Text('Total Value',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        SizedBox(height: 8),
                        Text('\$${mySpicesTotalValue.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // My Spices Section
            Text('My Spices',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900)),
            SizedBox(height: 12),
            spiceProvider.spices
                    .where((s) => s.sellerId == auth.user?.id)
                    .isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No spices listed yet',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: spiceProvider.spices
                        .where((s) => s.sellerId == auth.user?.id)
                        .length,
                    itemBuilder: (context, index) {
                      final mySpices = spiceProvider.spices
                          .where((s) => s.sellerId == auth.user?.id)
                          .toList();
                      final spice = mySpices[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: Icon(Icons.local_fire_department,
                              color: Colors.orange.shade700),
                          title: Text(spice.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '\$${spice.price.toStringAsFixed(2)} • ${spice.category}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Spice?'),
                                  content: Text(
                                      'Are you sure you want to delete ${spice.name}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        spiceProvider.removeSpice(spice.id);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text('Spice deleted')));
                                        setState(() {});
                                      },
                                      child: Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
            SizedBox(height: 20),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout?'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          auth.logout();
                          Navigator.pushReplacementNamed(context, '/welcome');
                        },
                        child:
                            Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
