import 'package:flutter/material.dart';
import 'transactionlist_page.dart';

class DonationListPage extends StatefulWidget {
  @override
  _DonationListPageState createState() => _DonationListPageState();
}

class _DonationListPageState extends State<DonationListPage> {
  TextEditingController searchController = TextEditingController();
  
  final List<Map<String, String>> donations = [
    {"id": "06", "location": "Sto. Tomas City, Batangas"},
    {"id": "08", "location": "Lapu-Lapu City, Cebu"},
    {"id": "09", "location": "Tanauan City, Batangas"},
    {"id": "07", "location": "Calamba City, Laguna"},
  ];

  List<Map<String, String>> filteredDonations = [];

  @override
  void initState() {
    super.initState();
    filteredDonations = donations;
  }

  void _filterDonations(String query) {
    setState(() {
      filteredDonations = donations
          .where((donation) =>
              donation["location"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          "List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterDonations,
              decoration: InputDecoration(
                hintText: "Search city...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List of Donations
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDonations.length,
              itemBuilder: (context, index) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      margin: const EdgeInsets.only(top: 20, bottom: 16),
                      child: ListTile(
                        title: Text(
                          filteredDonations[index]["location"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionListPage(
                                  location: filteredDonations[index]["location"]!,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("Details"),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Text(
                          filteredDonations[index]["id"]!,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
