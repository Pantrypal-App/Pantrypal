import 'package:flutter/material.dart';


class DonateCoinsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Balance Section
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.white, size: 18),
                    SizedBox(width: 5),
                    Text(
                      "Your Coins 150",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Donate Your Coins Text
            Text(
              "Donate your Coins!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Every coin holds value, and your generosity makes a difference.",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),

            // Donation Options (Using ListView to prevent overflow)
            Expanded(
              child: ListView(
                children: [
                  donationTile(500, 50, Colors.brown, "lib/images/pig 2.png"),
                  donationTile(1000, 100, Colors.green, "lib/images/pig 2.png"),
                  donationTile(
                      2500, 250, Colors.purple, "lib/images/pig 2.png"),
                  donationTile(5000, 500, Colors.red, "lib/images/pig 2.png"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget donationTile(int coins, int amount, Color bgColor, String pigImage) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Hexagon Clip for Image
          ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              color: bgColor,
              padding: EdgeInsets.all(4), // 🔹 Reduce padding
              width: 55, // Increase width
              height: 55, // Increase height
              child: Image.asset(pigImage,
                  fit: BoxFit.contain), // 🔹 Prevent cropping
            ),
          ),

          SizedBox(width: 10),

          // Expanded Text to Prevent Overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$coins Coins = ₱$amount.00",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "This amount of coins will automatically convert into Peso when you donate it.",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 4, // 🔹 Allow text to take two lines
                  overflow:
                      TextOverflow.ellipsis, // 🔹 Add "..." if it overflows
                ),
              ],
            ),
          ),

          // Donate Button with Fixed Width
          SizedBox(
            width: 90,
            child: ElevatedButton(
              onPressed: () {},
              child: Text("Donate"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hexagon Clipper for Image
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    Path path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

