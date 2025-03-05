import 'package:flutter/material.dart';
import 'donator2_page.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea( // Prevents extra space at the top
        child: Column(
          children: [
            SizedBox(height: 10), // Adjust spacing
            Text(
              'Payment Method',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Expanded( // Ensures this fills the remaining space
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    paymentOption(
                        'lib/images/GCash-logo-1-1-removebg-preview.png',
                        'Gcash',
                        context),
                    paymentOption(
                        'lib/images/images__21_-removebg-preview.png',
                        'PayMaya',
                        context),
                    paymentOption(
                        'lib/images/PayPal-Symbol-removebg-preview.png',
                        'PayPal',
                        context),
                    paymentOption('lib/images/wallet-removebg-preview.png',
                        'Bank Transfer', context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentOption(String asset, String name, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Donator2Page()),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 30,
            child: ClipOval(
              child: Image.asset(asset,
                  width: 50, height: 50, fit: BoxFit.contain),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
