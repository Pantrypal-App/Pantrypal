import 'package:flutter/material.dart';
import 'donator2_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonetaryDonationPage extends StatefulWidget {
  @override
  _MonetaryDonationPageState createState() => _MonetaryDonationPageState();
}

class _MonetaryDonationPageState extends State<MonetaryDonationPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> donations = [
    {
      'title': 'Bicol Region',
      'subtitle': 'Recently affected by typhoon.',
      'count': '3,089 donations'
    },
    {
      'title': 'Manila Animal Rescue Shelter',
      'subtitle': 'Supporting pet needs.',
      'count': '2,011 donations'
    },
    {
      'title': 'Bangsamoro Autonomous Region',
      'subtitle': 'Limited access to education.',
      'count': '1,117 donations'
    },
    {
      'title': 'Leyte',
      'subtitle': 'Residents face poverty.',
      'count': '4,335 donations'
    },
  ];
  List<Map<String, String>> filteredDonations = [];

  @override
  void initState() {
    super.initState();
    filteredDonations = donations;
  }

  void filterDonations(String query) {
    setState(() {
      filteredDonations = donations
          .where((donation) =>
              donation['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
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
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Graph Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'lib/images/graph.png',
                      fit: BoxFit.contain,
                      height: 120,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Statistics',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    'As of year 2024, our donations were on the rise. Thanks to your generosity! Let’s keep this momentum going.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Search Bar
            TextField(
              controller: searchController,
              onChanged: filterDonations,
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
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredDonations.length,
              itemBuilder: (context, index) {
                return _donationItem(
                  filteredDonations[index]['title']!,
                  filteredDonations[index]['subtitle']!,
                  filteredDonations[index]['count']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Donation Card Widget
  Widget _donationItem(String title, String subtitle, String count) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 4),
                Text(
                  '$subtitle\n$count as of Dec 2024',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Donator2Page(
                    userId: FirebaseAuth.instance.currentUser?.uid ??
                        '', // Or get the user ID as needed
                    name: FirebaseAuth.instance.currentUser?.displayName ??
                        'Guest', // Or get the name as needed
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(93, 0, 255, 68),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Donate',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
