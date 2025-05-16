import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonateCoinsPage extends StatefulWidget {
  @override
  _DonateCoinsPageState createState() => _DonateCoinsPageState();
}

class _DonateCoinsPageState extends State<DonateCoinsPage> {
  int coinBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadCoinBalance();
  }

  Future<void> _loadCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coinBalance = prefs.getInt('coinBalance') ?? 0;
    });
  }

  Future<void> _donateCoin(int coins, int amount) async {
    if (coinBalance < coins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins! You need $coins coins.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coinBalance -= coins;
    });
    await prefs.setInt('coinBalance', coinBalance);

    // Save donation history
    List<String> donationHistory = prefs.getStringList('donationHistory') ?? [];
    final now = DateTime.now();
    donationHistory.add('${now.toIso8601String()},₱$amount.00,$coins');
    await prefs.setStringList('donationHistory', donationHistory);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully donated ₱$amount.00! Thank you for your generosity!'),
        backgroundColor: Colors.green,
      ),
    );
  }

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
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.white, size: 18),
                    SizedBox(width: 5),
                    Text(
                      "Your Coins: $coinBalance",
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
                  donationTile(2500, 250, Colors.purple, "lib/images/pig 2.png"),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              color: bgColor,
              padding: EdgeInsets.all(4),
              width: 55,
              height: 55,
              child: Image.asset(pigImage, fit: BoxFit.contain),
            ),
          ),

          SizedBox(width: 10),

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
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(
            width: 90,
            child: ElevatedButton(
              onPressed: () => _donateCoin(coins, amount),
              child: Text("Donate"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                foregroundColor: Colors.black,
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
