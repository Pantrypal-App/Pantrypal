import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'Home_page.dart';
import 'Donate_page.dart';
import 'request_page.dart';
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

  @override
  void initState() {
    super.initState();
    _sendGreetingIfNew();
  }

  Future<void> _sendGreetingIfNew() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final greetingDoc = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('title', isEqualTo: 'Welcome Back!')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (greetingDoc.docs.isEmpty) {
      await _addGreeting(user);
      return;
    }

    final data = greetingDoc.docs.first.data();
    final timestamp = data['timestamp'];

    if (timestamp == null) {
      // In rare cases where timestamp isn't set yet
      return;
    }

    final lastTimestamp =
        (greetingDoc.docs.first.data()['timestamp'] as Timestamp).toDate();
    final lastGreetingDate =
        DateTime(lastTimestamp.year, lastTimestamp.month, lastTimestamp.day);

    if (today.isAfter(lastGreetingDate)) {
      await _addGreeting(user);
    }
  }

  Future<void> _addGreeting(User user) async {
    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": user.uid,
      "title": "Welcome Back!",
      "message":
          "Great to see you again, ${user.displayName ?? 'World-Changer'}!",
      "icon": "notifications_active",
      "color": "amber",
      "timestamp": FieldValue.serverTimestamp(),
    });
    print("Greeting notification sent.");
  }

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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No notifications yet."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return _buildNotificationItem(
                      _getIconFromName(data['icon'] ?? 'notifications'),
                      data['title'] ?? 'No Title',
                      data['message'] ?? '',
                      _getColorFromName(data['color'] ?? 'grey'),
                      _formatTimestamp(data['timestamp']),
                    );
                  },
                );
              },
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
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14), // Reduced size
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(fontSize: 10)), // Smaller text
            SizedBox(height: 3), // Reduced spacing
            Text(time,
                style: TextStyle(
                    fontSize: 9, color: Colors.grey)), // Smaller time text
          ],
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 12, vertical: 6), // Compact padding
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'eco':
        return Icons.eco;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'notifications_active':
        return Icons.notifications_active;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'amber':
        return Colors.amber;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    return "${date.month}/${date.day}/${date.year}";
  }
}
