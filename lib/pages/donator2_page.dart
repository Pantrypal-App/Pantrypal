import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final String userId;
  final String name;

  // Updated constructor to accept the userId and name parameters
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

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    isNameLocked = true;
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

  File? _pickedImage;

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

    if (eWalletNumber.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please fill in all required fields and upload a receipt')),
      );
      return;
    }

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

      final donationData = {
        'userId': widget.userId,
        'amount': double.parse(amount),
        'additional_info': additionalInfoController.text,
        'receipt_url': receiptUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final parentDocRef = FirebaseFirestore.instance
          .collection('monetary_donations')
          .doc(widget.userId)
          .collection('donations');

      await parentDocRef.add(donationData);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation saved successfully!')));
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving donation: $e')));
    }

    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "title": "You are a Hero Today!",
      "message": "Your generous donation has been received. Thank you!",
      "icon": "favorite",
      "color": "blue",
      "timestamp": FieldValue.serverTimestamp(),
    });
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
                Text('Hang Tight...',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
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
