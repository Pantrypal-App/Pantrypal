import 'package:flutter/material.dart';
import 'exchangecoin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reward_reader_wrapper.dart';
import 'home_page.dart';
import 'view_all_articles.dart';

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
  int coinBalance = 0;
  DateTime? lastClaimDate;
  int currentStreak = 0;
  DateTime? lastTaskResetDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load basic user data
    setState(() {
      claimedDays = prefs.getStringList('claimedDays') ?? [];
      coinBalance = prefs.getInt('coinBalance') ?? 0;
      lastClaimDate = DateTime.tryParse(prefs.getString('lastClaimDate') ?? '');
      currentStreak = prefs.getInt('currentStreak') ?? 0;
      lastTaskResetDate = DateTime.tryParse(prefs.getString('lastTaskResetDate') ?? '');
    });

    await _checkStreak();
    await _checkDailyTaskReset();
  }

  Future<void> _checkDailyTaskReset() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    
    // If it's the first time or a new day
    if (lastTaskResetDate == null || 
        !_isSameDay(lastTaskResetDate!, now)) {
      // Reset all task completion statuses
      await prefs.remove('great_reader_completed');
      await prefs.remove('disaster_awareness_completed');
      await prefs.remove('food_security_completed');
      await prefs.remove('community_helper_completed');
      
      // Reset task-specific reading times
      await prefs.remove('great_reader_time');
      await prefs.remove('disaster_awareness_time');
      await prefs.remove('food_security_time');
      await prefs.remove('community_helper_time');
      
      // Update last reset date
      await prefs.setString('lastTaskResetDate', now.toIso8601String());
      setState(() {
        lastTaskResetDate = now;
      });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<void> _checkStreak() async {
    if (lastClaimDate != null) {
      final now = DateTime.now();
      final difference = now.difference(lastClaimDate!).inDays;
      
      if (difference > 1) {
        // Reset streak if more than 1 day has passed
        setState(() {
          currentStreak = 0;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('currentStreak', 0);
      }
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('claimedDays', claimedDays);
    await prefs.setInt('coinBalance', coinBalance);
    await prefs.setString('lastClaimDate', DateTime.now().toIso8601String());
    await prefs.setInt('currentStreak', currentStreak);
  }

  int _calculateDailyReward() {
    // Base reward is 10 coins
    int reward = 10;
    
    // Add streak bonus
    if (currentStreak >= 7) {
      reward += 20; // Full week bonus
    } else if (currentStreak >= 3) {
      reward += 10; // 3-day streak bonus
    }
    
    return reward;
  }

  void claimTodayReward() async {
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";

    if (claimedDays.contains(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already claimed your reward for today!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calculate reward with streak bonus
    final reward = _calculateDailyReward();
    
    setState(() {
      claimedDays.add(today);
      coinBalance += reward;
      currentStreak++;
      lastClaimDate = now;
    });

    await _saveUserData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Daily reward claimed! +$reward coins (Streak: $currentStreak days)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'PantryPal Rewards',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Balance and Streak Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            '$coinBalance coins',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Current streak: $currentStreak days',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DonateCoinsPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Exchange'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Daily Rewards Section
            Container(
              padding: EdgeInsets.all(16),
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
                      Text(
                        "Daily Rewards",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentStreak > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$currentStreak day streak!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Next reward: ${_calculateDailyReward()} coins',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: claimedDays.contains(
                      "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}")
                        ? null
                        : claimTodayReward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text(
                      claimedDays.contains(
                        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}")
                          ? "Already Claimed Today"
                          : "Claim Daily Reward",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Available Tasks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [
                  _buildTaskCard(
                    "Great Reader",
                    "Read articles for 5 minutes",
                    50,
                    "lib/images/read 1.png",
                    "great_reader",
                  ),
                  _buildTaskCard(
                    "Disaster Awareness",
                    "Read disaster relief articles",
                    100,
                    "lib/images/typhoon 1.png",
                    "disaster_awareness",
                  ),
                  _buildTaskCard(
                    "Food Security Champion",
                    "Read food security articles",
                    100,
                    "lib/images/dog-and-cat-paws-with-sharp-claws-cute-animal-footprints-png 1.png",
                    "food_security",
                  ),
                  _buildTaskCard(
                    "Community Helper",
                    "Read community aid articles",
                    100,
                    "lib/images/4530515 1.png",
                    "community_helper",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String description, int points,
      String iconPath, String taskKey) {
    return FutureBuilder<bool>(
      future: _checkTaskStatus(taskKey),
      builder: (context, snapshot) {
        final bool isCompleted = snapshot.data ?? false;
        
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 24,
              child: Image.asset(iconPath, width: 30, height: 30),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: isCompleted ? Colors.grey : _getCoinColor(points),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCompleted ? "Completed" : "Earn $points coins!",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.grey : _getCoinColor(points),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: isCompleted
                  ? null
                  : () => _startTask(taskKey, points, title),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted
                    ? Colors.grey
                    : const Color.fromARGB(93, 0, 255, 68),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCompleted ? "Done" : "Start",
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkTaskStatus(String taskKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${taskKey}_completed') ?? false;
  }

  void _startTask(String taskKey, int points, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAllArticlesPage(
          isRewardMode: true,
          rewardPoints: points,
          taskKey: taskKey,
        ),
      ),
    );
  }

  Color _getCoinColor(int points) {
    if (points <= 50) return Colors.green;
    if (points <= 100) return Colors.blue;
    return Colors.red;
  }
}
