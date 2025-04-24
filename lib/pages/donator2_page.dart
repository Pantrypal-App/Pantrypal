import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;

class Donator2Page extends StatefulWidget {
  @override
  _Donator2PageState createState() => _Donator2PageState();
}

class _Donator2PageState extends State<Donator2Page> {
  String selectedPayment = 'Gcash'; // Default payment method
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController additionalInfoController =
      TextEditingController();

  // Function to get dynamic label
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

  File? _pickedImage;

// Function to pick image
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Compress the image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        final compressedBytes =
            img.encodeJpg(image, quality: 60); // reduce quality
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
          _pickedImage = imageFile; // fallback to original
        });
      }
    }
  }

// Function to upload image to Firebase Storage
  Future<String?> uploadImageToFirebase() async {
    if (_pickedImage == null) return null;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('receipts/$fileName');

    await ref.putFile(_pickedImage!);
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

// Function to upload image to ImgBB
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
    // Trim spaces from input fields
    String name = nameController.text.trim();
    String eWalletNumber = numberController.text.trim();
    String amount = amountController.text.trim();

    if (name.isEmpty || eWalletNumber.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Please fill in all required fields and upload a receipt')));
      return; // Exit the function if validation fails
    }

    // Validate that the amount is a valid number
    if (double.tryParse(amount) == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
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

      final existingUserSnapshot = await FirebaseFirestore.instance
          .collection('donators')
          .where('name', isEqualTo: name)
          .where('e_wallet_number', isEqualTo: eWalletNumber)
          .limit(1)
          .get();

      String userId;

      if (existingUserSnapshot.docs.isNotEmpty) {
        // User exists, reuse their ID
        userId = existingUserSnapshot.docs.first.id;
      } else {
        // New user, create and get ID
        final newUserRef =
            await FirebaseFirestore.instance.collection('donators').add({
          'name': name,
          'e_wallet_number': eWalletNumber,
          'created_at': FieldValue.serverTimestamp(),
        });
        userId = newUserRef.id;
      }

      final parentDocRef = FirebaseFirestore.instance
          .collection('monetary_donations')
          .doc(userId);

      // ✅ Create parent doc first to avoid subcollection warning
      await parentDocRef.set({
        'name': name,
        'e_wallet_number': eWalletNumber,
        'exists': true,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final donationsRef = parentDocRef.collection('donations');

      final donationData = {
        'userId': userId,
        'name': name,
        'payment_method': selectedPayment,
        'e_wallet_number': eWalletNumber,
        'amount': double.parse(amount),
        'additional_info': additionalInfoController.text,
        'latitude': latitude,
        'longitude': longitude,
        'receipt_url': receiptUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await donationsRef.add(donationData);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation saved successfully!')));

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving donation: $e')));
    }
  }

  Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false, // prevent closing it accidentally
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
                CircularProgressIndicator(
                  color: Colors.green,
                ),
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
            Text('',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildTextField('Name', controller: nameController),
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
            SizedBox(height: 20),
            Text('The location for your donation:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildMapView(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                // Save the donation information and then navigate to PaymentPage
                saveDonation();
              },
              child: Text('Donate Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {int maxLines = 1, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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
