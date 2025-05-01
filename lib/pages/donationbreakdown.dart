import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DonationBreakdownPage(),
  ));
}

class DonationBreakdownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Donations Breakdown',
          style: TextStyle(fontSize: 18), // smaller title
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image with overlay text
            Stack(
              children: [
                Image.asset(
                  'lib/images/donation breakdown.jpg', // <-- replace with your image path
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text(
                    'Where Your Donation Goes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black54,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Justified introduction text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'PantryPal is committed to transparency and community impact. Here’s how your donation is used:',
                style: TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),

            // All donation sections
            _buildDonationSection(
              color: Colors.blue,
              percentage: '85%',
              title: 'Direct Community Support',
              description:
                  'Goes directly to providing food, hygiene kits, and essential goods to individuals and families in need via partnered food banks and shelters.',
            ),
            _buildDonationSection(
              color: Colors.green,
              percentage: '5%',
              title: 'Volunteer Support & Logistics',
              description:
                  'Helps fund transport for pickups and deliveries, fuel costs, and tools needed for safe, timely distribution.',
            ),
            _buildDonationSection(
              color: Colors.teal,
              percentage: '5%',
              title: 'Technology & Platform Maintenance',
              description:
                  'Supports app development, server hosting, security updates, and improvements to ensure smooth and secure donations.',
            ),
            _buildDonationSection(
              color: Colors.orange,
              percentage: '3%',
              title: 'Community Engagement & Education',
              description:
                  'Funds local awareness campaigns, community training on resource sharing, and digital literacy programs to reach underserved groups.',
            ),
            _buildDonationSection(
              color: Colors.purple,
              percentage: '2%',
              title: 'Administrative & Compliance',
              description:
                  'Covers basic administrative expenses such as legal compliance, data protection, and reporting to ensure donor accountability.',
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSection({
    required Color color,
    required String percentage,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 22,
            child: Text(
              percentage,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}