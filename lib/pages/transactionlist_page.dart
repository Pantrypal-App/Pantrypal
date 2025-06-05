import 'package:flutter/material.dart';
import 'barangay_details_page.dart';

class TransactionListPage extends StatelessWidget {
  final String location;

  TransactionListPage({required this.location});

  final List<Map<String, String>> transactions = [
    {"name": "BARANGAY 1", "date": "JULY 10, 2024", "location": "Sto. Tomas City, Batangas"},
    {"name": "BARANGAY 2", "date": "AUGUST 07, 2024", "location": "Sto. Tomas City, Batangas"},
    {"name": "BARANGAY 3", "date": "SEPTEMBER 15, 2024", "location": "Tanauan City, Batangas"},
    {"name": "BARANGAY 4", "date": "OCTOBER 20, 2024", "location": "Calamba City, Laguna"},
    {"name": "BARANGAY 5", "date": "NOVEMBER 30, 2024", "location": "Lapu-Lapu City, Cebu"},
    {"name": "BARANGAY 6", "date": "DECEMBER 25, 2024", "location": "Lapu-Lapu City, Cebu"},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = transactions
        .where((t) => t["location"] == location)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          location,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 24,
                        child: const Icon(Icons.volunteer_activism,
                            color: Colors.white),
                      ),
                      title: Text(
                        filteredTransactions[index]["name"]!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        filteredTransactions[index]["date"]!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarangayDetailsPage(
                              barangayName: filteredTransactions[index]["name"]!,
                              date: filteredTransactions[index]["date"]!,
                              location: filteredTransactions[index]["location"]!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
