import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;

class Donator2Page extends StatefulWidget {
  final String userId;
  final String name;

  Donator2Page({required this.userId, required this.name});

  @override
  _Donator2PageState createState() => _Donator2PageState();
}

class _Donator2PageState extends State<Donator2Page> {
  String selectedPayment = 'Gcash';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController additionalInfoController =
      TextEditingController();
  bool isNameLocked = false;

  File? _pickedImage;
  String profilePicUrl = '';
  String userName = '';
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    isNameLocked = true;
    _fetchUserProfileData();
  }

  // Fetching user profile data
  Future<void> _fetchUserProfileData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          profilePicUrl = userSnapshot.get('image') ?? '';
          userName = userSnapshot.get('name') ?? '';
          totalAmount = userSnapshot.get('totalAmount') ?? 0.0;
        });
        print("User data fetched: $userName, $profilePicUrl, $totalAmount");
      } else {
        print("User data not found");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  String getPaymentLabel() {
    switch (selectedPayment) {
      case 'PayPal':
        return 'PayPal Email';
      case 'Bank Transfer':
        return 'Bank Account Number';
      case 'PayMaya':
        return 'PayMaya Number';
      default:
        return 'Gcash Number';
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        final compressedBytes = img.encodeJpg(image, quality: 60);
        final tempDir = Directory.systemTemp;
        final targetPath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final compressedFile =
            await File(targetPath).writeAsBytes(compressedBytes);
        setState(() {
          _pickedImage = compressedFile;
        });
      } else {
        setState(() {
          _pickedImage = imageFile;
        });
      }
    }
  }

  Future<String?> uploadImageToImgBB(File imageFile) async {
    final apiKey = 'b1964c76eec82b6bc38b376b91e42c1a';
    final base64Image = base64Encode(await imageFile.readAsBytes());

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {
        'key': apiKey,
        'image': base64Image,
      },
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data']['url'];
    } else {
      throw Exception('Failed to upload');
    }
  }

  Future<void> saveDonation() async {
    String eWalletNumber = numberController.text.trim();
    String amount = amountController.text.trim();

    if (eWalletNumber.isEmpty || amount.isEmpty || _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please complete all fields and upload a receipt.')),
      );
      return;
    }

    if (double.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    try {
      showLoadingDialog(context);
      String? receiptUrl = await uploadImageToImgBB(_pickedImage!);

      if (receiptUrl == null) {
        throw Exception('Failed to upload receipt image');
      }

      double latitude = 14.1084;
      double longitude = 121.1416;

      final donationData = {
        'userId': widget.userId,
        'amount': double.parse(amount),
        'additional_info': additionalInfoController.text,
        'receipt_url': receiptUrl,
        'payment_method': selectedPayment,
        'ewallet_number': eWalletNumber,
        'location': GeoPoint(latitude, longitude),
        'timestamp': FieldValue.serverTimestamp(),
      };

      final userDoc = FirebaseFirestore.instance
          .collection('monetary_donations')
          .doc(widget.userId);

      final donationsCollection = userDoc.collection('donations');

      await donationsCollection.add(donationData);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentTotal =
            snapshot.exists && snapshot.data()!.containsKey('totalAmount')
                ? snapshot.get('totalAmount')
                : 0.0;

        transaction.set(
          userDoc,
          {
            'totalAmount': currentTotal + double.parse(amount),
            'name': widget.name,
            'image': receiptUrl,
            'userId': widget.userId,
          },
          SetOptions(merge: true),
        );
      });

      await FirebaseFirestore.instance.collection("notifications").add({
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "title": "You are a Hero Today!",
        "message": "Your generous donation has been received. Thank you!",
        "icon": "favorite",
        "color": "blue",
        "timestamp": FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation saved successfully!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving donation: $e')),
      );
    }
  }

  Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 20),
                Text(
                  'Hang Tight...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monetary Donation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Name',
                controller: nameController, readOnly: isNameLocked),
            _buildTextField(getPaymentLabel(), controller: numberController),
            _buildTextField('Amount', controller: amountController),
            _buildTextField('Additional Information',
                maxLines: 3, controller: additionalInfoController),
            SizedBox(height: 20),
            Text('Select Payment Method:'),
            DropdownButton<String>(
              value: selectedPayment,
              items: ['Gcash', 'PayMaya', 'PayPal', 'Bank Transfer']
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPayment = value!;
                });
              },
            ),
            Text('Upload your e-wallet receipt:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.upload_file),
              label: Text('Upload Receipt'),
            ),
            SizedBox(height: 10),
            _pickedImage != null
                ? Image.file(_pickedImage!, height: 150)
                : Text('No receipt uploaded yet.'),
            SizedBox(height: 20),
            Text('The location for your donation:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildMapView(),
            SizedBox(height: 20),
            // Profile Info Section
            profilePicUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profilePicUrl),
                  )
                : Container(),
            SizedBox(height: 10),
            Text(userName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Total Donations: \$${totalAmount.toStringAsFixed(2)}'),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: saveDonation,
              child: Text('Donate Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {int maxLines = 1,
      TextEditingController? controller,
      bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(14.1084, 121.1416),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
