import 'package:flutter/material.dart';
import 'transaction_page.dart';

class AccountDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true, // Ensures title is centered
        title: Text(
          "Account Details",
          style: TextStyle(
            color: Colors.white, // Makes text white
            fontWeight: FontWeight.bold,
            fontSize:
                MediaQuery.of(context).size.width * 0.05, // Adjust font size
          ),
        ),
        iconTheme:
            IconThemeData(color: Colors.white), // Ensures back button is white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Donations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  DonationItem("Bicol", "January 18, 2025"),
                  DonationItem(
                      "Manila Animal Rescue Shelter", "December 11, 2024"),
                  DonationItem(
                      "Habitat for Humanity Philippines", "October 18, 2024"),
                  DonationItem("Cebu", "July 08, 2024"),
                  DonationItem("Davao", "May 11, 2024"),
                  DonationItem("Ilocos Sur", "March 18, 2024"),
                ],
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text("View All Donations",
                    style: TextStyle(color: Colors.green, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationItem extends StatelessWidget {
  final String title;
  final String date;

  DonationItem(this.title, this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8.0), // Adds space between items
      child: Card(
        elevation: 3, // Adds a subtle shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: 10), // Adjust padding
          leading:
              Icon(Icons.volunteer_activism, color: Colors.green, size: 30),
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(date,
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.green),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailsPage(
                    transactionId: "D12345",
                    donor: "Renoir Regidor",
                    recipient: "Jayson Villa",
                    donationType: "Food",
                    donationAmount: "PHP 10,000.00",
                    status: "Confirmed",
                    deliveredOn: "January 18, 2025",
                    donationDate: "January 18, 2025",
                  ),
                ),
              );
            },
            child: Text("Details", style: TextStyle(color: Colors.green)),
          ),
        ),
      ),
    );
  }
}
