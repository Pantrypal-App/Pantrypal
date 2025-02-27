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
        physics: BouncingScrollPhysics(), // Enables smooth scrolling
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
                  SizedBox(height: 8), // Space between texts
                  Text(
                    "With just ₱40.00 you can share a meal with someone in need.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
            FeaturedGoalsSection(), // Your goal cards
            PowerToEndHungerSection(),
            InviteFriendsSection(),
            GetToKnowUsSection(),
            DonationBreakdownSection(),
            EmergencyAidSection(),
            SizedBox(height: 20), // Add some space at the bottom
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

          /// Increased the height to 350 for a taller box
          SizedBox(
            height: 350, // Increased height for bigger cards
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GoalCard(
                  title: "Feed Families in Typhoon-Affected Areas",
                  description:
                      "Support families recovering from recent typhoons. Your help can bring hope and nourishment.",
                  imagePath: 'lib/images/typhon.jpg',
                ),
                GoalCard(
                  title: "Help Combat Malnutrition in Mindanao",
                  description:
                      "Provide nutritious meals to children in remote areas suffering from hunger and malnutrition.",
                  imagePath: 'lib/images/malnutrition.jpg',
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
  final String description;
  final String imagePath;

  GoalCard({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 320, // Increased card height
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max, // Forces the box to expand
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160, // Increased image height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            // Allows text area to expand
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max, // Pushes everything inside
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 10), // Adjusted spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {}, // Navigate to more details
                        child: Text("Read More",
                            style: TextStyle(color: Colors.blue)),
                      ),
                      ElevatedButton(
                        onPressed: () {}, // Navigate to donation
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange, // Button background color
                          foregroundColor:
                              Colors.black, // Text color set to black
                          shape: RoundedRectangleBorder(
                            // Makes it a rectangle
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text("Donate"),
                      ),
                    ],
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title placed above the card
          Text(
            "Together, we have the power to end hunger",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8), // Space between title and card

          Center(
            child: Container(
              width: 340, // Keeps width smaller
              height: 360, // Increased height of the box
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'lib/images/map.jpg',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20), // More space between map and stats

                      // Keeping stats inside to avoid stretching
                      Column(
                        children: [
                          StatItem(
                            title: "12,345,678 meals",
                            subtitle: "Meals Shared",
                            additionalText: "+8,000",
                            highlightColor: Colors.green,
                            timeLabel: "in the last day",
                          ),
                          StatItem(
                            title: "234,567 supporters",
                            subtitle: "Fighting Hunger",
                            additionalText: "+150",
                            highlightColor: Colors.green,
                            timeLabel: "in the last day",
                          ),
                          StatItem(
                            title: "25 goals",
                            subtitle: "Completed",
                            additionalText: "+2",
                            highlightColor: Colors.green,
                            timeLabel: "in the last 90 days",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String additionalText;
  final String timeLabel;
  final Color highlightColor;

  const StatItem({
    required this.title,
    required this.subtitle,
    required this.additionalText,
    required this.timeLabel,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                additionalText,
                style: TextStyle(
                    color: highlightColor, fontWeight: FontWeight.bold),
              ),
              Text(timeLabel,
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class InviteFriendsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Card(
        color: Color(0xFFE3F2FD), // Light blue background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Image.asset(
                'lib/images/invite your friends.png', // Placeholder for invite image
                height: 50,
                width: 50,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invite your friends",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "and fight hunger together",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Text("Invite", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
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
