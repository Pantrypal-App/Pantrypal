import 'package:flutter/material.dart';
import "AccountDetailsPage.dart";
import 'donationlist_page.dart';
import 'messageus_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNightMode = false; // Night Mode State

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : Colors.grey[200],
      appBar: AppBar(
        backgroundColor: isNightMode ? Colors.grey[900] : Colors.green,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            decoration: BoxDecoration(
              color: isNightMode ? Colors.grey[900] : Colors.green,
            ),
            padding: const EdgeInsets.only(top: 5, bottom: 15),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.camera_alt,
                              color: Colors.grey[700], size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Username",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "Example@gmail.com",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Account Details Button
                  _buildCard(
                    child: ListTile(
                      title: Text(
                        "Account Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isNightMode ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 18,
                          color: isNightMode ? Colors.white : Colors.black),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountDetailsPage()),
                        );
                      },
                    ),
                  ),

                  // Settings Section
                  _buildCard(
                    child: Column(
                      children: [
                        _buildToggleOption(
                            Icons.dark_mode, "Night Mode", isNightMode,
                            (value) {
                          setState(() {
                            isNightMode = value;
                          });
                        }),
                        _buildToggleOption(
                            Icons.notifications, "Notification", false,
                            (value) {
                          // Handle notification toggle logic
                        }),
                        _buildOption(Icons.list, "List", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DonationListPage()),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Additional Options
                  _buildCard(
                    child: Column(
                      children: [
                        _buildOption(Icons.message, "Message us", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackPage()),
                          );
                        }),
                        _buildOption(Icons.share, "Share"),
                        _buildOption(Icons.group, "About us"),
                      ],
                    ),
                  ),

                  // Log Out Button
                  _buildCard(
                    child: ListTile(
                      title: const Text(
                        "Log Out",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) =>
                              false, // This removes all previous routes (so user can't go back)
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable method for option items
  Widget _buildOption(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: isNightMode ? Colors.white : Colors.black),
      title: Text(
        title,
        style: TextStyle(color: isNightMode ? Colors.white : Colors.black),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 18, color: isNightMode ? Colors.white : Colors.black),
      onTap: onTap,
    );
  }

  // Reusable method for toggle options
  Widget _buildToggleOption(
      IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: isNightMode ? Colors.white : Colors.black),
      title: Text(
        title,
        style: TextStyle(color: isNightMode ? Colors.white : Colors.black),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  // Reusable card container
  Widget _buildCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        color: isNightMode ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: child,
      ),
    );
  }
}
