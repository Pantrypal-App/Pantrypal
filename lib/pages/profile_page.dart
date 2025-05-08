import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AccountDetailsPage.dart';
import 'donationlist_page.dart';
import 'messageus_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'request_page.dart';
import 'Donate_page.dart';
import 'notification_page.dart';
import 'ranking_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'aboutus_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 4;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  File? _image;
  String? _userId;
  String? _username;
  String? _email;
  String? _profilePicUrl;
  
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  final List<TabItem> items = [
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.volunteer_activism, title: 'Donate'),
    TabItem(icon: Icons.request_page, title: 'Request'),
    TabItem(icon: Icons.notifications, title: 'Notification'),
    TabItem(icon: Icons.person, title: 'You'),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      _userId = currentUser.uid;
      _email = currentUser.email;
      
      // First check Firestore for user data
      try {
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(_userId).get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          
          setState(() {
            _user = currentUser;
            _username = userData['username'] ?? currentUser.displayName ?? '';
            _profilePicUrl = userData['profilePic'] ?? currentUser.photoURL;
            _nameController.text = _username ?? '';
          });
        } else {
          // If no document exists yet, use Firebase Auth data and create a document
          String displayName = currentUser.displayName ?? '';
          String photoURL = currentUser.photoURL ?? '';
          
          // Create user document for first-time users (including Google sign-in)
          await _firestore.collection("users").doc(_userId).set({
            "username": displayName,
            "email": _email,
            "profilePic": photoURL,
            "uid": _userId,
            "createdAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          
          setState(() {
            _user = currentUser;
            _username = displayName;
            _profilePicUrl = photoURL;
            _nameController.text = displayName;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        // Fallback to Firebase Auth data
        setState(() {
          _user = currentUser;
          _username = currentUser.displayName ?? '';
          _profilePicUrl = currentUser.photoURL;
          _nameController.text = _username ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null || _userId == null) return;

    try {
      // Show loading indicator
      _showLoadingDialog("Uploading image...");
      
      // Upload to Firebase Storage
      Reference ref = _storage.ref().child("profile_pics/$_userId.jpg");
      await ref.putFile(_image!);
      String firebaseImageUrl = await ref.getDownloadURL();
      
      // Also upload to ImgBB for backup/CDN
      String? imgbbUrl = await _uploadImageToImgBB();
      
      // Use ImgBB URL if successful, otherwise use Firebase URL
      String finalImageUrl = imgbbUrl ?? firebaseImageUrl;
      
      // Update user's profile pic URL in both Auth and Firestore
      if (_user != null) {
        await _user!.updatePhotoURL(finalImageUrl);
      }
      
      await _firestore.collection("users").doc(_userId).update({
        "profilePic": finalImageUrl,
      });
      
      // Update local state
      setState(() {
        _profilePicUrl = finalImageUrl;
      });
      
      // Hide loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully"))
      );
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();
      
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile picture: $e"))
      );
    }
  }

  Future<String?> _uploadImageToImgBB() async {
    if (_image == null) return null;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.imgbb.com/1/upload?key=b1964c76eec82b6bc38b376b91e42c1a"),
      );
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);

      if (json["success"]) {
        return json["data"]["url"];
      }
    } catch (e) {
      print("Error uploading to ImgBB: $e");
    }
    return null;
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateUsername() async {
    if (_userId != null && _nameController.text.isNotEmpty) {
      String newUsername = _nameController.text.trim();
      
      // Don't update if username hasn't changed
      if (newUsername == _username) return;
      
      try {
        _showLoadingDialog("Updating username...");
        
        // Check if username is already taken
        QuerySnapshot existingUser = await _firestore
            .collection("users")
            .where("username", isEqualTo: newUsername)
            .get();

        if (existingUser.docs.isNotEmpty && existingUser.docs.first.id != _userId) {
          // Hide loading dialog
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Username already taken"))
          );
          return;
        }

        // Update username in Firebase Auth
        if (_user != null) {
          await _user!.updateDisplayName(newUsername);
        }
        
        // Update username in Firestore
        await _firestore.collection("users").doc(_userId).update({
          "username": newUsername,
        });

        // Update any donations associated with this user
        QuerySnapshot donationSnapshot = await _firestore
            .collection("donations")
            .where("userID", isEqualTo: _userId)
            .get();

        for (var doc in donationSnapshot.docs) {
          await doc.reference.update({
            "username": newUsername
          });
        }
        
        // Update local state
        setState(() {
          _username = newUsername;
        });
        
        // Hide loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username updated successfully"))
        );
      } catch (e) {
        // Hide loading dialog
        Navigator.of(context).pop();
        
        print("Error updating username: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update username: $e"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: const EdgeInsets.only(top: 5, bottom: 15),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: _profilePicUrl != null
                            ? NetworkImage(_profilePicUrl!)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: _profilePicUrl == null
                            ? Icon(Icons.camera_alt,
                                color: Colors.grey[700], size: 30)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your username",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    onSubmitted: (value) => _updateUsername(),
                  ),
                ),
                Text(
                  _email ?? "No email found",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildCard(
                    ListTile(
                      title: const Text("Account Details",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountDetailsPage()),
                      ),
                    ),
                  ),
                  _buildCard(
                    Column(
                      children: [
                        _buildOption(Icons.leaderboard, "Ranking", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TopDonorsPage()),
                          );
                        }),
                        _buildOption(Icons.notifications, "Notification", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationPage()),
                          );
                        }),
                        _buildOption(Icons.list, "List", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DonationListPage()),
                          );
                        }),
                      ],
                    ),
                  ),
                  _buildCard(
                    Column(
                      children: [
                        _buildOption(Icons.message, "Message us", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackPage()),
                          );
                        }),
                        _buildOption(Icons.share, "Share"),
                        _buildOption(Icons.group, "About us", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutUsPage()),
                          );
                        }),
                      ],
                    ),
                  ),
                  _buildCard(
                    ListTile(
                      title: const Text("Log Out",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      onTap: () async {
                        await _auth.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                Colors.black,
        color: Colors.black,
        colorSelected: Colors.black,
        indexSelected: selectedIndex,
        onTap: (int index) {
          if (index != selectedIndex) {
            List<Widget> pages = [
              HomePage(),
              DonationPage(),
              RequestPage(),
              NotificationPage(),
              ProfilePage()
            ];
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => pages[index]));
          }
        },
        chipStyle:
            const ChipStyle(convexBridge: true, background: Colors.white),
        itemStyle: ItemStyle.circle,
        titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        animated: true,
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: child,
      ),
    );
  }
}