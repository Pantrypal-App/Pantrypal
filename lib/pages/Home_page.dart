import 'package:flutter/material.dart';

void main() {
  runApp(PantryPalApp());
}

class PantryPalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('PantryPal', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey, World-Changer!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8), 
                  Text(
                    "With just ₱40.00 you can share a meal with someone in need.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
            FeaturedGoalsSection(),
            PowerToEndHungerSection(),
            InviteFriendsSection(),
            GetToKnowUsSection(),
            DonationBreakdownSection(),
            EmergencyAidSection(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class FeaturedGoalsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FEATURED GOALS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {}, // Navigate to more goals
                child: Text("See all", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 230, // Increased height for buttons
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GoalCard(
                  title: "Feed Families in Typhoon-Affected Areas",
                  description:
                      "Support families recovering from recent typhoons. Your help can bring hope and nourishment.",
                  imagePath: 'assets/goal_image.png',
                ),
                GoalCard(
                  title: "Help Combat Malnutrition in Mindanao",
                  description:
                      "Provide nutritious meals to children in remote areas suffering from hunger and malnutrition.",
                  imagePath: 'assets/goal_image.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final String title;
  final String description; // Add this line
  final String imagePath;

  GoalCard({required this.title, required this.description, required this.imagePath}); // Update constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120, // Adjust height for image
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.black54)), // Now using description
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {}, // Navigate to more details
                      child: Text("Read More", style: TextStyle(color: Colors.blue)),
                    ),
                    ElevatedButton(
                      onPressed: () {}, // Navigate to donation
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: Text("Donate"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.green,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism), label: 'Donate'),
        BottomNavigationBarItem(
            icon: Icon(Icons.request_page), label: 'Request'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notification'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
      ],
    );
  }
}

class PowerToEndHungerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text("Together, we have the power to end hunger",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class InviteFriendsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {},
        child: Text("Invite Your Friends"),
      ),
    );
  }
}

class GetToKnowUsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text("Get to Know Us",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class DonationBreakdownSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text("Donation Breakdown",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class EmergencyAidSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text("Emergency Aid",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
