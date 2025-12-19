import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class BuyerProfile extends StatelessWidget {
  const BuyerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        title: Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF1B5E4B),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E4B), Color(0xFF2D8659)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.orange.shade100],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        )
                      ],
                    ),
                    child:
                        Icon(Icons.person, size: 60, color: Color(0xFF1B5E4B)),
                  ),
                  SizedBox(height: 20),
                  Text(
                    user?.name ?? 'Guest',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Buyer Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    shadowColor: Color(0xFF1B5E4B).withOpacity(0.2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Color(0xFF1B5E4B).withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E4B)),
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
                  ),
                  SizedBox(height: 20),
                  // Settings Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    shadowColor: Color(0xFF1B5E4B).withOpacity(0.1),
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              Icon(Icons.receipt, color: Color(0xFF1B5E4B)),
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
                          leading:
                              Icon(Icons.favorite, color: Color(0xFF1B5E4B)),
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
                          leading:
                              Icon(Icons.settings, color: Color(0xFF1B5E4B)),
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
                          leading: Icon(Icons.help, color: Color(0xFF1B5E4B)),
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
                  SizedBox(height: 24),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Logout',
                                style: TextStyle(
                                    color: Color(0xFF1B5E4B),
                                    fontWeight: FontWeight.bold)),
                            content: Text('Are you sure you want to logout?',
                                style: TextStyle(color: Colors.grey.shade700)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel',
                                    style: TextStyle(color: Color(0xFF1B5E4B))),
                              ),
                              TextButton(
                                onPressed: () {
                                  auth.logout();
                                  Navigator.pushReplacementNamed(
                                      context, '/welcome');
                                },
                                child: Text('Logout',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
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
