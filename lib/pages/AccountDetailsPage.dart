import 'package:flutter/material.dart';
import 'transaction_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AccountDetailsPage extends StatefulWidget {
  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  List<Map<String, dynamic>> donations = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid;
        await fetchDonations();
      } else {
        print("No current user found");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching current user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDonations() async {
    if (currentUserId == null) return;

    try {
      // Fetch monetary donations: first find the user's document
      final monetaryDocQuery = await FirebaseFirestore.instance
          .collection('monetary_donations')
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .get();

      List<Map<String, dynamic>> allDonations = [];

      if (monetaryDocQuery.docs.isNotEmpty) {
        final monetaryDocId = monetaryDocQuery.docs.first.id;
        final donationsSnapshot = await FirebaseFirestore.instance
            .collection('monetary_donations')
            .doc(monetaryDocId)
            .collection('donations')
            .orderBy('timestamp', descending: true)
            .get();

        for (var doc in donationsSnapshot.docs) {
          final data = doc.data();
          final timestamp = data['timestamp'] as Timestamp?;
          if (timestamp != null) {
            allDonations.add({
              'type': 'Monetary',
              'title': 'Monetary Donation',
              'amount': 'PHP ${NumberFormat('#,##0.00').format(data['amount'] ?? 0.0)}',
              'date': DateFormat('MMMM dd, yyyy').format(timestamp.toDate()),
              'timestamp': timestamp,
              'payment_method': data['payment_method'] ?? 'Unknown',
              'status': 'Confirmed',
              'receipt_url': data['receipt_url'],
              'ewallet_number': data['ewallet_number'],
            });
          }
        }
      }

      // Fetch physical donations
      final physicalSnapshot = await FirebaseFirestore.instance
          .collection('physical_donations')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      for (var doc in physicalSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          allDonations.add({
            'type': 'Physical',
            'title': (data['donated_items'] as List<dynamic>?)?.join(', ') ?? 'Physical Donation',
            'amount': 'Physical Goods',
            'date': DateFormat('MMMM dd, yyyy').format(timestamp.toDate()),
            'timestamp': timestamp,
            'pickup_location': data['pickup_location'] ?? 'Not specified',
            'status': 'Pending',
            'contact': data['contact'],
            'name': data['name'],
          });
        }
      }

      // Sort all donations by timestamp
      allDonations.sort((a, b) => (b['timestamp'] as Timestamp)
          .compareTo(a['timestamp'] as Timestamp));

      print("Fetched donations: ${allDonations.length}"); // Debug print
      for (var donation in allDonations) {
        print("Donation: ${donation.toString()}"); // Debug print
      }

      setState(() {
        donations = allDonations;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching donations: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          "Account Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Donations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (donations.isEmpty)
              Center(
                child: Text(
                  "No donations yet",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    return DonationItem(
                      donation['title'],
                      donation['date'],
                      donation['type'],
                      donation['amount'],
                      donation['status'],
                      donation['payment_method'] ?? donation['pickup_location'],
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

class DonationItem extends StatelessWidget {
  final String title;
  final String date;
  final String type;
  final String amount;
  final String status;
  final String additionalInfo;

  DonationItem(
    this.title,
    this.date,
    this.type,
    this.amount,
    this.status,
    this.additionalInfo,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                type == 'Monetary' ? Icons.attach_money : Icons.volunteer_activism,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      amount,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 2),
                    Text(
                      type == 'Monetary' 
                          ? 'Payment: ${additionalInfo}'
                          : 'Location: ${additionalInfo}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Confirmed' ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Confirmed' ? Colors.green[800] : Colors.orange[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
