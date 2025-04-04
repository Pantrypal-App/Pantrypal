import 'package:flutter/material.dart';
import 'exchangecoin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationPage extends StatefulWidget {
  @override
  _GamificationPageState createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  final List<String> rewardDays = [
    "Day 1",
    "Day 2",
    "Day 3",
    "Day 4",
    "Day 5",
    "Day 6",
    "Day 7"
  ];

  List<String> claimedDays = [];

  @override
  void initState() {
    super.initState();
    _loadClaimedDays();
  }

  Future<void> _loadClaimedDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedClaimedDays = prefs.getStringList('claimedDays') ?? [];
    setState(() {
      claimedDays = savedClaimedDays;
    });
  }

  Future<void> _saveClaimedDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('claimedDays', claimedDays);
  }

  void claimTodayReward() async {
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";

    // Check if the reward was already claimed today
    if (claimedDays.contains(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already claimed your reward for today!'),
        ),
      );
      return;
    }

    // Simulate claiming the reward
    if (claimedDays.length < 7) {
      setState(() {
        claimedDays.add(today);
      });

      // Save the updated claimed days
      await _saveClaimedDays();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Successfully claimed reward for ${rewardDays[claimedDays.length - 1]}!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          '',
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
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            ),
            const SizedBox(height: 10),

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
                      "Your Coins 150",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
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
                        onPressed: claimedDays.contains(
                                "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}")
                            ? null
                            : claimTodayReward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: claimedDays.contains(
                                  "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}")
                              ? Colors.grey
                              : const Color.fromARGB(93, 0, 255, 68),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Claim",
                            style: TextStyle(color: Colors.white)),
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
                          width: MediaQuery.of(context).size.width *
                              (claimedDays.length / 7),
                          // Adjust based on claimed rewards
                          color: Colors.orange,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          return Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: claimedDays.length > index
                                    ? Colors.orange
                                    : Colors.grey[300],
                                radius: 14,
                                child: Icon(Icons.monetization_on,
                                    color: Colors.white, size: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                rewardDays[index],
                                style: TextStyle(fontSize: 12),
                              ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DonateCoinsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: Text(
                  "Exchange and Donate your Coins",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Tasks",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            ),
            const SizedBox(height: 10),

            // Task List
            Expanded(
              child: ListView(
                children: [
                  _buildTaskCard(
                      "Great Reader",
                      "Read any article within 5 minutes!",
                      50,
                      "lib/images/read 1.png",
                      true),
                  _buildTaskCard(
                      "Great Sympathy",
                      "Read about typhoon-affected families.",
                      100,
                      "lib/images/typhoon 1.png",
                      false),
                  _buildTaskCard(
                      "Malnutrition Awareness",
                      "Read about malnutrition in Mindanao.",
                      100,
                      "lib/images/Famine-hunger-scarcity-foodcrises-foodcrisis-poverty-malnutrition-starvation-foodscarcity-512 1.png",
                      false),
                  _buildTaskCard(
                      "Love For Animals",
                      "Support animal food programs.",
                      100,
                      "lib/images/dog-and-cat-paws-with-sharp-claws-cute-animal-footprints-png 1.png",
                      false),
                  _buildTaskCard(
                      "Love For Orphans",
                      "Read about orphan support.",
                      100,
                      "lib/images/Kids-Download-PNG 1.png",
                      false),
                  _buildTaskCard(
                      "Care For People Who Need Help",
                      "Watch documented videos.",
                      150,
                      "lib/images/4530515 1.png",
                      false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String description, int points,
      String iconPath, bool isClaimable) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 24,
          child: Image.asset(iconPath, width: 30, height: 30),
        ),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.monetization_on,
                    color: _getCoinColor(points), size: 16),
                const SizedBox(width: 4),
                Text("Earn $points coins!",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getCoinColor(points))),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isClaimable
                ? const Color.fromARGB(93, 0, 255, 68)
                : Colors.blue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(isClaimable ? "Claim" : "Go",
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }

  Color _getCoinColor(int points) {
    if (points <= 50) {
      return Colors.green;
    } else if (points <= 100) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }
}
