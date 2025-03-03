import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'AccountDetailsPage.dart';
import 'donationlist_page.dart';
import 'messageus_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'request_page.dart';
import 'Donate_page.dart';
import 'notification_page.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 4;

  final List<TabItem> items = [
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.volunteer_activism, title: 'Donate'),
    TabItem(icon: Icons.request_page, title: 'Request'),
    TabItem(icon: Icons.notifications, title: 'Notification'),
    TabItem(icon: Icons.person, title: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.isNightMode
            ? Colors.grey[900]
            : const Color(0xFF4BB050),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: themeProvider.isNightMode
                ? Colors.grey[900]
                : const Color(0xFF4BB050),
            padding: const EdgeInsets.only(top: 5, bottom: 15),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: themeProvider.isNightMode
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      child: Icon(Icons.camera_alt,
                          color: themeProvider.isNightMode
                              ? Colors.white70
                              : Colors.grey[700],
                          size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("Username",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text("Example@gmail.com",
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildCard(
                    themeProvider,
                    ListTile(
                      title: const Text("Account Details",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountDetailsPage())),
                    ),
                  ),
                  _buildCard(
                    themeProvider,
                    Column(
                      children: [
                        _buildToggleOption(
                          Icons.dark_mode,
                          "Night Mode",
                          themeProvider.isNightMode,
                          (value) => themeProvider.toggleNightMode(),
                        ),
                        _buildOption(Icons.notifications, "Notification", () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationPage()));
                        }),
                        _buildOption(Icons.list, "List", () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DonationListPage()));
                        }),
                      ],
                    ),
                  ),
                  _buildCard(
                    themeProvider,
                    Column(
                      children: [
                        _buildOption(Icons.message, "Message us", () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FeedbackPage()));
                        }),
                        _buildOption(Icons.share, "Share"),
                        _buildOption(Icons.group, "About us"),
                      ],
                    ),
                  ),
                  _buildCard(
                    themeProvider,
                    ListTile(
                      title: const Text("Log Out",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
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
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: themeProvider.isNightMode
            ? (Colors.grey[800] ?? Colors.grey) // Ensures it's never null
            : const Color(0xFF4BB050), // Green color

        color: themeProvider.isNightMode ? Colors.white : Colors.black,
        colorSelected: Colors.black,
        indexSelected: selectedIndex,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } else if (index == 1) {
            // Navigate to Donate Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DonationPage()),
            );
          } else if (index == 2) {
            // Navigate to Notification Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RequestPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => NotificationPage()));
          } else {
            setState(() {
              selectedIndex = index;
            });
          }
        },
        chipStyle: const ChipStyle(
          convexBridge: true,
          background: Colors.white,
        ),
        itemStyle: ItemStyle.circle,
        titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        animated: true,
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildToggleOption(
      IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing:
          Switch(value: value, onChanged: onChanged, activeColor: Colors.green),
    );
  }

  Widget _buildCard(ThemeProvider themeProvider, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        color: themeProvider.isNightMode ? Colors.grey[700] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: child,
      ),
    );
  }
}
