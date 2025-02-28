import 'package:flutter/material.dart';

class TransactionListPage extends StatelessWidget {
  final String location;

  TransactionListPage({required this.location});

  final List<Map<String, String>> transactions = [
    {"name": "BARANGAY 1", "date": "JULY 10, 2024"},
    {"name": "BARANGAY 2", "date": "AUGUST 07, 2024"},
    {"name": "BARANGAY 3", "date": "SEPTEMBER 15, 2024"},
    {"name": "BARANGAY 4", "date": "OCTOBER 20, 2024"},
    {"name": "BARANGAY 5", "date": "NOVEMBER 30, 2024"},
    {"name": "BARANGAY 6", "date": "DECEMBER 25, 2024"},
  ];

  @override
  Widget build(BuildContext context) {
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
                itemCount: transactions.length,
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
                        transactions[index]["name"]!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        transactions[index]["date"]!,
                        style: const TextStyle(color: Colors.grey),
                      ),
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
