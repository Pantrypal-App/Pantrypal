import 'package:flutter/material.dart';

class MonetaryDonationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monetary Donation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Monetary Donation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 12),

            // Statistics Section (Graph + Text)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Graph Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'lib/images/graph.png', // Ensure path is correct
                      fit: BoxFit.contain,
                      height: 120, // Adjust height as needed
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Statistics Text directly under Graph
                  Text(
                    'Statistics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'As of year 2024, our donations were on the rise. Thanks to your generosity! Let’s keep this momentum going.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search Here...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Donation List
            _donationItem('Bicol Region', 'Recently affected by typhoon.',
                '3,089 donations'),
            _donationItem('Manila Animal Rescue Shelter',
                'Supporting pet needs.', '2,011 donations'),
            _donationItem('Bangsamoro Autonomous Region',
                'Limited access to education.', '1,117 donations'),
            _donationItem(
                'Leyte', 'Residents face poverty.', '4,335 donations'),
          ],
        ),
      ),
    );
  }

  // Donation Card Widget
  Widget _donationItem(String title, String subtitle, String count) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$subtitle\n$count as of Dec 2024',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Handle donation action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('Donate', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
