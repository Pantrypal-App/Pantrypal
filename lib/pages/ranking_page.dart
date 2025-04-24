import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopDonorsPage extends StatefulWidget {
  const TopDonorsPage({super.key});

  @override
  State<TopDonorsPage> createState() => _TopDonorsPageState();
}

class _TopDonorsPageState extends State<TopDonorsPage> {
  List<Map<String, dynamic>> topDonors = [];
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
        fetchTopDonors();
      } else {
        print("No current user found");
      }
    } catch (e) {
      print("Error fetching current user: $e");
    }
  }

  Future<void> fetchTopDonors() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('monetary_donations').get();

    Map<String, Map<String, dynamic>> donorsMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final uid = data['uid'];
      final name = data['name'] ?? 'Anonymous';
      final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
      final image = data['image'];

      // Use UID if available; fallback to name
      String uniqueKey = uid ?? name;

      if (donorsMap.containsKey(uniqueKey)) {
        donorsMap[uniqueKey]!['amount'] += amount;
      } else {
        donorsMap[uniqueKey] = {
          'uid': uid ?? name,
          'name': name,
          'amount': amount,
          'image': image,
        };
      }
    }

    List<Map<String, dynamic>> donorList = donorsMap.values.toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    for (int i = 0; i < donorList.length; i++) {
      donorList[i]['rank'] = i + 1;
      donorList[i]['amount'] =
          "₱ ${double.parse(donorList[i]['amount'].toString()).toStringAsFixed(2)}";
    }

    // Add current user if missing
    bool userInList = donorList.any((d) => d['uid'] == currentUserId);
    if (!userInList && currentUserId != null) {
      final user = FirebaseAuth.instance.currentUser;
      donorList.add({
        'uid': currentUserId,
        'name': user?.displayName ?? 'You',
        'amount': "₱ 0.00",
        'rank': donorList.length + 1,
        'image': user?.photoURL,
      });
    }

    setState(() {
      topDonors = donorList;
    });
  } catch (e) {
    print("Error fetching top donors: $e");
  }
}


  Widget medal(int rank) {
    switch (rank) {
      case 1:
        return const Text("🥇", style: TextStyle(fontSize: 18));
      case 2:
        return const Text("🥈", style: TextStyle(fontSize: 18));
      case 3:
        return const Text("🥉", style: TextStyle(fontSize: 18));
      default:
        return CircleAvatar(
          backgroundColor: Colors.white,
          radius: 10,
          child: Text(
            "$rank",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
    }
  }

  Widget donorCircle(String? imagePath, String name, int rank, String uid) {
    bool isCurrentUser = uid == currentUserId;
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: imagePath != null
                  ? NetworkImage(imagePath)
                  : const AssetImage('assets/default_user.png')
                      as ImageProvider,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Image.asset(
                'lib/images/ph_flag.webp',
                height: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name.length > 10 ? '${name.substring(0, 10)}...' : name,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          rank == 1
              ? "🥇"
              : rank == 2
                  ? "🥈"
                  : rank == 3
                      ? "🥉"
                      : "#$rank",
          style: const TextStyle(fontSize: 14),
        ),
        if (isCurrentUser)
          const Text("You",
              style: TextStyle(fontSize: 12, color: Colors.green)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    Map<String, dynamic>? currentUserData = topDonors.firstWhere(
      (donor) => donor['uid'] == currentUserId,
      orElse: () => {},
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Top Donors'),
      ),
      body: topDonors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16), // Top padding added
                if (topDonors.length >= 3)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      donorCircle(topDonors[1]["image"], topDonors[1]["name"],
                          2, topDonors[1]["uid"]),
                      donorCircle(topDonors[0]["image"], topDonors[0]["name"],
                          1, topDonors[0]["uid"]),
                      donorCircle(topDonors[2]["image"], topDonors[2]["name"],
                          3, topDonors[2]["uid"]),
                    ],
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20), // Add space at top and bottom
                    itemCount: topDonors.length,
                    itemBuilder: (context, index) {
                      var donor = topDonors[index];
                      bool isCurrentUser = donor["uid"] == currentUserId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.amber.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: donor["image"] != null
                                  ? NetworkImage(donor["image"])
                                  : const AssetImage('assets/default_user.png')
                                      as ImageProvider,
                            ),
                            title: Row(
                              children: [
                                medal(donor["rank"]),
                                const SizedBox(width: 6),
                                Text(
                                  donor["name"].length > 10
                                      ? '${donor["name"].substring(0, 10)}...'
                                      : donor["name"],
                                ),
                              ],
                            ),
                            trailing: Text(donor["amount"]),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (currentUserData.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: currentUserData["image"] != null
                              ? NetworkImage(currentUserData["image"])
                              : const AssetImage('assets/default_user.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUserData["name"] ?? 'You',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Your Rank: ${currentUserData["rank"]}'),
                            ],
                          ),
                        ),
                        Text(currentUserData["amount"] ?? "₱ 0.00"),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
