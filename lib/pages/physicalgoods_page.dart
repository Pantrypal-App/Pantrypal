import 'package:flutter/material.dart';
import 'donator_page.dart';

class PhysicalGoodsDonationPage extends StatefulWidget {
  @override
  _PhysicalGoodsDonationPageState createState() =>
      _PhysicalGoodsDonationPageState();
}

class _PhysicalGoodsDonationPageState extends State<PhysicalGoodsDonationPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> donations = [
    {
      'title': 'Bicol Region',
      'subtitle': 'Needs food and clothing after typhoon.',
      'count': '2,540 items donated'
    },
    {
      'title': 'Manila Animal Rescue Shelter',
      'subtitle': 'Pet food and blankets needed.',
      'count': '1,320 items donated'
    },
    {
      'title': 'Bangsamoro Autonomous Region',
      'subtitle': 'School supplies for children.',
      'count': '980 items donated'
    },
    {
      'title': 'Leyte',
      'subtitle': 'Hygiene kits and canned goods needed.',
      'count': '3,412 items donated'
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
              'Donate Physical Goods',
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
                MaterialPageRoute(builder: (context) => DonatorPage()),
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
