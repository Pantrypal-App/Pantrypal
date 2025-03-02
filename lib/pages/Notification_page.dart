import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'Home_page.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int selectedIndex = 3; // Default to Notification tab
  String selectedFilter = "All";

  final List<TabItem> items = [
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.volunteer_activism, title: 'Donate'),
    TabItem(icon: Icons.request_page, title: 'Request'),
    TabItem(icon: Icons.notifications, title: 'Notification'),
    TabItem(icon: Icons.person, title: 'You'),
  ];

  final List<Map<String, dynamic>> notifications = [
    {
      "icon": Icons.notifications_active,
      "title": "Hey, World-Changer!",
      "message":
          "We just wanted to brighten your day with a little hello. Have a blast day, World-Changer.",
      "color": Colors.amber,
      "time": "Yesterday",
      "isRecent": false
    },
    {
      "icon": Icons.favorite,
      "title": "You are a Hero Today!",
      "message":
          "Your generous donation has been received and will help the people in need. Together, we're creating change!",
      "color": Colors.blue,
      "time": "10 hours ago",
      "isRecent": true
    },
    {
      "icon": Icons.eco,
      "title": "Your Kindness Fulfills the World!",
      "message":
          "Explore new causes and see how small actions create big impact. Let’s keep making a difference together!",
      "color": Colors.green,
      "time": "6 hours ago",
      "isRecent": true
    },
    {
      "icon": Icons.volunteer_activism,
      "title": "Ready to make a difference today?",
      "message":
          "Discover new opportunities to support causes that matter to you. Together, we can create a brighter future.",
      "color": Colors.pink,
      "time": "2 hours ago",
      "isRecent": true
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildFilterButton("All"),
                    SizedBox(width: 10),
                    _buildFilterButton("Recents"),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Mark all as read",
                      style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: notifications
                  .where((notif) =>
                      selectedFilter == "All" || notif["isRecent"] == true)
                  .map((notif) {
                return _buildNotificationItem(notif["icon"], notif["title"],
                    notif["message"], notif["color"], notif["time"]);
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: Colors.green,
        color: Colors.black,
        colorSelected: Colors.black,
        indexSelected: selectedIndex,
        onTap: (int index) {
          if (index == 0) {
            // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 4) {
            // Profile
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
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

  Widget _buildFilterButton(String filter) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selectedFilter == filter ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: selectedFilter == filter ? Colors.white : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, String title, String message,
      Color iconColor, String time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(fontSize: 12)),
            SizedBox(height: 5),
            Text(time, style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
