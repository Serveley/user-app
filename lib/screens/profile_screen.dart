import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo,
                    Colors.purple.shade700,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Guest User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user@serveley.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.bookings,
                    title: 'My Bookings',
                    subtitle: 'View your service bookings',
                    onTap: () {
                      // TODO: Navigate to bookings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    title: 'Favorite Vendors',
                    subtitle: 'Vendors you love',
                    onTap: () {
                      // TODO: Navigate to favorites
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Saved Addresses',
                    subtitle: 'Manage your addresses',
                    onTap: () {
                      // TODO: Navigate to addresses
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.payment,
                    title: 'Payment Methods',
                    subtitle: 'Manage payment options',
                    onTap: () {
                      // TODO: Navigate to payments
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Notification preferences',
                    onTap: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  const Divider(height: 32),
                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'About Serveley',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(height: 32),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      // TODO: Implement logout
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey[50],
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.indigo),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            : null,
        trailing: onTap != null
            ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400])
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Serveley'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Serveley',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Your trusted local service marketplace. Connect with verified vendors for all your service needs.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 Serveley. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
