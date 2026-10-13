import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Helper method to show custom alert dialogs for list items
  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.brown[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  // Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.brown[900],
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, size: 60, color: Colors.brown),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mary Jhen Mula',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'maryjhen@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.amberAccent),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileTile(
                    context,
                    Icons.shopping_bag,
                    'My Orders',
                    onTap: () => _showInfoDialog(context, 'My Orders', 'You currently have no active orders.'),
                  ),
                  _buildProfileTile(
                    context,
                    Icons.favorite,
                    'My Favorites',
                    onTap: () => _showInfoDialog(context, 'My Favorites', 'Your favorite coffee items will appear here.'),
                  ),
                  _buildProfileTile(
                    context,
                    Icons.settings,
                    'Settings',
                    onTap: () => _showInfoDialog(context, 'Settings', 'App Settings & Preferences.'),
                  ),
                  _buildProfileTile(
                    context,
                    Icons.help,
                    'Help & Support',
                    onTap: () => _showInfoDialog(context, 'Help & Support', 'Contact us at support@beantherecoffee.com'),
                  ),
                  _buildProfileTile(
                    context,
                    Icons.logout,
                    'Log Out',
                    color: Colors.redAccent,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context,
    IconData icon,
    String title, {
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.brown[800],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap, // Connected the tap listener
      ),
    );
  }
}