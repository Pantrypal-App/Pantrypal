import 'package:flutter/material.dart';
import 'donator2_page.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                paymentOption('assets/gcash.png', 'Gcash', context),
                paymentOption('assets/paymaya.png', 'PayMaya', context),
                paymentOption('assets/paypal.png', 'PayPal', context),
                paymentOption('assets/bank.png', 'Bank Transfer', context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentOption(String asset, String name, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Donator2Page()),
            );
          },
          child: CircleAvatar(
            backgroundImage: AssetImage(asset),
            radius: 30,
          ),
        ),
        SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}