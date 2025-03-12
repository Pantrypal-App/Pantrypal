import 'package:flutter/material.dart';

class GamificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Gamification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PantryPal Rewards Title
            Text(
              "PantryPal Rewards",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            const SizedBox(height: 10),

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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Daily Rewards Section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Daily Rewards",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Claim", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      Positioned(
                        left: 0,
                        child: Container(
                          height: 4,
                          width: MediaQuery.of(context).size.width * 0.3, // Adjust based on claimed rewards
                          color: Colors.orange,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          return Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: index < 2 ? Colors.orange : Colors.grey[300],
                                radius: 14,
                                child: Icon(Icons.monetization_on, color: Colors.white, size: 16),
                              ),
                              SizedBox(height: 4),
                              Text(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index],
                                  style: TextStyle(fontSize: 12)),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Exchange and Donate Coins Button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Text(
                  "Exchange and Donate your Coins",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Task List
            Expanded(
              child: ListView(
                children: [
                  _buildTaskCard("Great Reader", "Read any article within 5 minutes!", 50, "lib/images/read 1.png", true),
                  _buildTaskCard("Great Sympathy", "Read about typhoon-affected families.", 100, "lib/images/typhoon 1.png", false),
                  _buildTaskCard("Malnutrition Awareness", "Read about malnutrition in Mindanao.", 100, "lib/images/Famine-hunger-scarcity-foodcrises-foodcrisis-poverty-malnutrition-starvation-foodscarcity-512 1.png", false),
                  _buildTaskCard("Love For Animals", "Support animal food programs.", 100, "lib/images/dog-and-cat-paws-with-sharp-claws-cute-animal-footprints-png 1.png", false),
                  _buildTaskCard("Love For Orphans", "Read about orphan support.", 100, "lib/images/Kids-Download-PNG 1.png", false),
                  _buildTaskCard("Care For People Who Need Help", "Watch documented videos.", 150, "lib/images/4530515 1.png", false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String description, int points, String iconPath, bool isClaimable) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 24,
          child: Image.asset(iconPath, width: 30, height: 30),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(description, style: TextStyle(fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isClaimable ? Colors.orange : Colors.purple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(isClaimable ? "Claim" : "Go", style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }
}
