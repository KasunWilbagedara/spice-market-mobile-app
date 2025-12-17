import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/spice_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_spice_screen.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  _SellerHomeState createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  @override
  void initState() {
    super.initState();
    final spiceProvider = Provider.of<SpiceProvider>(context, listen: false);
    spiceProvider.loadSpices();
  }

  @override
  Widget build(BuildContext context) {
    final spiceProvider = Provider.of<SpiceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('🌶️ Seller Dashboard'),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        actions: [
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
        child: Column(
          children: [
            Container(
              color: Colors.orange.shade700,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Listings',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${spiceProvider.spices.length}',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Value',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${spiceProvider.spices.fold<double>(0, (sum, spice) => sum + spice.price).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: spiceProvider.spices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_box, size: 80, color: Colors.orange.shade300),
                          SizedBox(height: 16),
                          Text('No spices listed yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddSpiceScreen()),
                              );
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Your First Spice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                          ),
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
                                  if (spice.category != null)
                                    Text(
                                      'Category: ${spice.category}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Price: \$${spice.price.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 28),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Spice?'),
                                      content: Text('Are you sure you want to delete ${spice.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            spiceProvider.removeSpice(spice.id);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Spice deleted'), backgroundColor: Colors.red),
                                            );
                                          },
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade700,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddSpiceScreen()),
          );
        },
      ),
    );
  }
}
