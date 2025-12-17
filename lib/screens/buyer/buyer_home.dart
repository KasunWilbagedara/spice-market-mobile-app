import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/spice_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../buyer/spice_details.dart';
import '../buyer/cart_screen.dart';

class BuyerHome extends StatefulWidget {
  @override
  _BuyerHomeState createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  @override
  void initState() {
    super.initState();
    final spiceProvider = Provider.of<SpiceProvider>(context, listen: false);
    spiceProvider.loadSpices();
  }

  @override
  Widget build(BuildContext context) {
    final spiceProvider = Provider.of<SpiceProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('🌶️ Spice Market'),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                enabled: false,
                child: Row(
                  children: [Icon(Icons.person, color: Colors.orange.shade700), SizedBox(width: 8), Text('${auth.user?.name}')],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [Icon(Icons.logout, color: Colors.orange.shade700), SizedBox(width: 8), Text('Logout')],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/welcome');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: spiceProvider.spices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, size: 80, color: Colors.orange.shade300),
                    SizedBox(height: 16),
                    Text('No spices available', style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: spiceProvider.spices.length,
                itemBuilder: (context, index) {
                  final spice = spiceProvider.spices[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 30),
                        ),
                        title: Text(
                          spice.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            if (spice.description != null)
                              Text(
                                spice.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            SizedBox(height: 8),
                            Text(
                              '\$${spice.price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.add_shopping_cart, color: Colors.orange.shade700, size: 28),
                          onPressed: () {
                            cartProvider.addToCart(spice);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${spice.name} added to cart'),
                                duration: Duration(milliseconds: 800),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SpiceDetails(spice: spice)),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
