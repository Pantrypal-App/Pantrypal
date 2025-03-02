import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'Notification_page.dart';
import 'Home_page.dart';
import 'profile_page.dart';

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  int selectedIndex = 1;

  final List<TabItem> items = [
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.volunteer_activism, title: 'Donate'),
    TabItem(icon: Icons.request_page, title: 'Request'),
    TabItem(icon: Icons.notifications, title: 'Notification'),
    TabItem(icon: Icons.person, title: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PantryPal'),
        backgroundColor: Colors.green,
         automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donate Now Button at the Top
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement donation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Yellow background
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Donate now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black text
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              _buildSectionTitle('Choose where to donate'),
              _buildDonationCard(
                'Philippines: Help feed communities in the Philippines affected by disasters and poverty.',
                'lib/images/typhon.jpg',
                'Urgent',
              ),

              _buildSectionTitle('Ongoing Hunger Crisis'),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Support the Philippines and other regions in addressing hunger and building resilience for the long term.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              _buildHorizontalScroll([
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
                  imagePath: 'lib/images/typhon.jpg',
                ),
              ]),

              _buildSectionTitle('NEED SOME LOVE'),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Fundraising goals with low progress. Help show them some support!',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              _buildHorizontalScroll([
                GoalCard(
                  title: "Empower Indigenous Communities with Food Assistance",
                  description:
                      "Support indigenous communities in the Philippines by donating life-saving meals.",
                  imagePath: 'lib/images/typhon.jpg',
                ),
                GoalCard(
                  title: "Provide School Meals for Underserved Children",
                  description:
                      "Ensure children in impoverished areas get daily nutritious school meals.",
                  imagePath: 'lib/images/typhon.jpg',
                ),
              ]),

              _buildSectionTitle('NOT SURE WHERE TO HELP?'),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Choose where to use your donation.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              _buildDonationCard(
                'Global: Feed families who need it most',
                'lib/images/typhon.jpg',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: Colors.green,
        color: Colors.black,
        colorSelected: Colors.black,
        indexSelected: selectedIndex,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 2) {
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          } else if (index == 4) {
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDonationCard(String title, String imagePath, [String? tag]) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Container(
            height: 200,
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tag != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(tag, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScroll(List<Widget> cards) {
    return SizedBox(
      height: 350,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
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
      height: 350, // Kept your original height
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
            height: 160, // Kept your image height
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      maxLines: 3, // Prevents overflow
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 10),
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
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
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
