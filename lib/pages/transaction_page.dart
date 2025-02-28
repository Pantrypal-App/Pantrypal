import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final String transactionId;
  final String donor;
  final String recipient;
  final String donationType;
  final String donationAmount;
  final String status;
  final String deliveredOn;
  final String donationDate;

  const TransactionDetailsPage({
    Key? key,
    required this.transactionId,
    required this.donor,
    required this.recipient,
    required this.donationType,
    required this.donationAmount,
    required this.status,
    required this.deliveredOn,
    required this.donationDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true, // Ensures title is centered
        title: const Text(
          "Donation Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18, // Adjusted size to match other headers
          ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Transaction ID:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(transactionId),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Donation Date:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(donationDate),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow("Donor:", donor),
                    infoRow("Recipient:", recipient),
                    infoRow("Donation Type:", donationType),
                    infoRow("Donation Amount:", donationAmount),
                    infoRow("Status:", status),
                    infoRow("Delivered On:", deliveredOn),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
