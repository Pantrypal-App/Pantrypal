import 'package:flutter/material.dart';

void main() {
  runApp(PantryPalApp());
}

class PantryPalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryPal Overview',
      home: OverviewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Get to know us',
          style: TextStyle(fontSize: 18), // smaller title
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'lib/images/gettoknowus.jpg', // Replace with your image path
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 20,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'of how the PantryPal\ndelivers your donations!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  InfoCard(
                    title: 'Transparency & Real-Time Tracking',
                    content:
                        'By using technology to make the process quick, transparent, and community-centered, PantryPal guarantees that every donation gets to those who most need it.',
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 16),
                  InfoCard(
                    title: 'Direct Support to Local Communities',
                    content:
                        'Your contributions go straight to those in need, particularly in rural or underprivileged areas. Donations are effectively directed to local beneficiaries through PantryPal\'s smart matching feature to reduce delays and increase impact.',
                    backgroundColor: Color(0xFFCFEED2), // light green
                  ),
                  SizedBox(height: 16),
                  InfoCard(
                    title: 'Empowering Organizations',
                    content:
                        'Powered by your donation, PantryPal helps volunteers find available items, arrange deliveries, and assist with community operations.',
                    backgroundColor: Color(0xFFD1E7F9), // light blue
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final Color backgroundColor;

  const InfoCard({
    Key? key,
    required this.title,
    required this.content,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
