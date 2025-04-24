import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
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

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 4;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    setState(() {
      _user = _auth.currentUser;
      _nameController.text = _user?.displayName ?? "";
    });

    if (_user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(_user!.uid).get();
      if (userDoc.exists) {
        String? profilePic = userDoc["profilePic"];
        if (profilePic != null) {
          setState(() {
            _user!.updatePhotoURL(profilePic);
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
      _uploadImageToImgBB();
    }
  }

  Future<void> _uploadImageToImgBB() async {
    if (_image == null || _user == null) return;

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
        String imageUrl = json["data"]["url"];
        await _user!.updatePhotoURL(imageUrl);
        await _firestore.collection("users").doc(_user!.uid).set({
          "profilePic": imageUrl,
        }, SetOptions(merge: true));
        _getCurrentUser();
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null || _user == null) return;

    try {
      Reference ref = _storage.ref().child("profile_pics/${_user!.uid}.jpg");
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();

      await _user!.updatePhotoURL(imageUrl);
      await _firestore.collection("users").doc(_user!.uid).set({
        "profilePic": imageUrl,
      }, SetOptions(merge: true));
      _getCurrentUser();
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _updateUsername() async {
    if (_user != null && _nameController.text.isNotEmpty) {
      try {
        await _user!.updateDisplayName(_nameController.text);
        await _firestore.collection("users").doc(_user!.uid).set({
          "username": _nameController.text,
          "email": _user!.email,
        }, SetOptions(merge: true));
        _getCurrentUser();
      } catch (e) {
        print("Error updating username: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                        backgroundImage: _user?.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                        backgroundColor: Colors.grey[300],
                        child: _user?.photoURL == null
                            ? Icon(Icons.camera_alt, color: Colors.grey[700], size: 30)
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
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your username",
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    onSubmitted: (value) => _updateUsername(),
                  ),
                ),
                Text(
                  _user?.email ?? "No email found",
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
                      title: const Text("Account Details", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountDetailsPage()),
                      ),
                    ),
                  ),
                  _buildCard(
                    Column(
                      children: [
                        _buildOption(Icons.leaderboard, "Ranking", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TopDonorsPage()),
                          );
                        }),
                        _buildOption(Icons.notifications, "Notification", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NotificationPage()),
                          );
                        }),
                        _buildOption(Icons.list, "List", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DonationListPage()),
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
                            MaterialPageRoute(builder: (context) => FeedbackPage()),
                          );
                        }),
                        _buildOption(Icons.share, "Share"),
                        _buildOption(Icons.group, "About us"),
                      ],
                    ),
                  ),
                  _buildCard(
                    ListTile(
                      title: const Text("Log Out",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.black,
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
        chipStyle: const ChipStyle(convexBridge: true, background: Colors.white),
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
