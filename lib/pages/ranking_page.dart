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
  bool isLoading = true;

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

  // New function to fetch user profile information
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (docSnapshot.exists) {
        final userData = docSnapshot.data() ?? {};
        print("Successfully fetched user profile for $userId: $userData");
        return userData;
      } else {
        print("User profile not found for $userId");
        return {};
      }
    } catch (e) {
      print("Error fetching user profile for $userId: $e");
      return {};
    }
  }

  Future<void> fetchTopDonors() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('monetary_donations')
          .orderBy('totalAmount', descending: true)
          .get();

      List<Map<String, dynamic>> donorList = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final userId = doc.id;
        final totalAmount = data['totalAmount'] ?? 0;
        
        // Fetch user profile information
        final userProfile = await fetchUserProfile(userId);
        
        // Use profile data if available, fallback to donation data
        final name = userProfile['name'] ?? userProfile['fullName'] ?? data['name'] ?? 'Anonymous';
        
        // Try multiple possible field names for profile image, with profilePic as the first option
        final image = userProfile['profilePic'] ?? 
                      userProfile['profileImage'] ?? 
                      userProfile['photoURL'] ?? 
                      userProfile['photoUrl'] ?? 
                      userProfile['profilePicture'] ?? 
                      userProfile['avatar'] ?? 
                      userProfile['image'] ?? 
                      data['image'] ?? 
                      'path_to_default_image';

        donorList.add({
          'uid': userId,
          'name': name,
          'image': image,
          'amount': "₱ ${double.parse(totalAmount.toString()).toStringAsFixed(2)}",
        });
      }

      // Sort again (precaution) and assign rank
      donorList.sort((a, b) => double.parse(b['amount'].toString().replaceAll('₱ ', '')).compareTo(
          double.parse(a['amount'].toString().replaceAll('₱ ', ''))));
      for (int i = 0; i < donorList.length; i++) {
        donorList[i]['rank'] = i + 1;
      }

      // Handle current user
      if (currentUserId != null &&
          !donorList.any((donor) => donor['uid'] == currentUserId)) {
        // Fetch current user profile
        final currentUserProfile = await fetchUserProfile(currentUserId!);
        final currentUserName = currentUserProfile['name'] ?? currentUserProfile['fullName'] ?? 'You';
        
        // Try multiple possible field names for profile image, with profilePic as the first option
        final currentUserImage = currentUserProfile['profilePic'] ?? 
                                currentUserProfile['profileImage'] ?? 
                                currentUserProfile['photoURL'] ?? 
                                currentUserProfile['photoUrl'] ?? 
                                currentUserProfile['profilePicture'] ?? 
                                currentUserProfile['avatar'] ?? 
                                currentUserProfile['image'] ?? 
                                'path_to_default_image';
        
        donorList.add({
          'uid': currentUserId!,
          'name': currentUserName,
          'amount': "₱ 0.00",
          'rank': donorList.length + 1,
          'image': currentUserImage,
        });
      }

      setState(() {
        topDonors = donorList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching top donors: $e");
      setState(() {
        isLoading = false;
      });
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
              backgroundImage: (imagePath != null && imagePath != 'path_to_default_image')
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
    final currentUserData = topDonors.firstWhere(
      (donor) => donor['uid'] == currentUserId,
      orElse: () => {},
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Top Donors'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
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
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
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
                              backgroundImage: (donor["image"] != null && donor["image"] != 'path_to_default_image')
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: (currentUserData["image"] != null && currentUserData["image"] != 'path_to_default_image')
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