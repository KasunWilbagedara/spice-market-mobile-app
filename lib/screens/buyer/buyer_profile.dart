import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class BuyerProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade700,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.orange.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: Icon(Icons.person,
                        size: 50, color: Colors.orange.shade700),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Guest',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Profile Info
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Account Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900),
                          ),
                          SizedBox(height: 16),
                          _buildInfoRow('Name', user?.name ?? 'N/A'),
                          Divider(height: 16),
                          _buildInfoRow('Email', user?.email ?? 'N/A'),
                          Divider(height: 16),
                          _buildInfoRow('Role', 'Buyer'),
                          Divider(height: 16),
                          _buildInfoRow('Member Since', 'Dec 2024'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Settings Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.receipt,
                              color: Colors.orange.shade700),
                          title: Text('Order History'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Order history coming soon')),
                            );
                          },
                        ),
                        Divider(height: 0),
                        ListTile(
                          leading: Icon(Icons.favorite,
                              color: Colors.orange.shade700),
                          title: Text('Wishlist'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Wishlist coming soon')),
                            );
                          },
                        ),
                        Divider(height: 0),
                        ListTile(
                          leading: Icon(Icons.settings,
                              color: Colors.orange.shade700),
                          title: Text('Settings'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Settings coming soon')),
                            );
                          },
                        ),
                        Divider(height: 0),
                        ListTile(
                          leading:
                              Icon(Icons.help, color: Colors.orange.shade700),
                          title: Text('Help & Support'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Help & Support coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Logout'),
                            content: Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  auth.logout();
                                  Navigator.pushReplacementNamed(
                                      context, '/welcome');
                                },
                                child: Text('Logout',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }
}
