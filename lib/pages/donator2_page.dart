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
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:geocoding/geocoding.dart';

class Donator2Page extends StatefulWidget {
  final String userId;
  final String name;
  final Map<String, dynamic>? articleData;

  Donator2Page({
    required this.userId, 
    required this.name,
    this.articleData,
  });

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
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isVerifyingReceipt = false;
  String? _receiptVerificationError;
  
  // Add location variables
  late LatLng donationLocation;
  final defaultLocation = LatLng(14.1084, 121.1416); // Default location if none provided
  String detectedLocationName = '';

  // Updated philippinePlaces with more locations and variations
  final List<Map<String, String>> philippinePlaces = [
    // Metro Manila Cities
    {'name': 'Metro Manila', 'type': 'region'},
    {'name': 'NCR', 'type': 'region'},
    {'name': 'Quezon City', 'type': 'city'},
    {'name': 'Manila', 'type': 'city'},
    {'name': 'Makati', 'type': 'city'},
    {'name': 'Taguig', 'type': 'city'},
    {'name': 'Pasig', 'type': 'city'},
    {'name': 'Mandaluyong', 'type': 'city'},
    {'name': 'Parañaque', 'type': 'city'},
    {'name': 'Las Piñas', 'type': 'city'},
    {'name': 'Muntinlupa', 'type': 'city'},
    {'name': 'Marikina', 'type': 'city'},
    {'name': 'San Juan', 'type': 'city'},
    {'name': 'Valenzuela', 'type': 'city'},
    {'name': 'Caloocan', 'type': 'city'},
    {'name': 'Malabon', 'type': 'city'},
    {'name': 'Navotas', 'type': 'city'},
    {'name': 'Pasay', 'type': 'city'},
    {'name': 'Pateros', 'type': 'municipality'},

    // Major Cities
    {'name': 'Cebu City', 'type': 'city'},
    {'name': 'Cebu', 'type': 'province'},
    {'name': 'Davao City', 'type': 'city'},
    {'name': 'Davao', 'type': 'province'},
    {'name': 'Baguio City', 'type': 'city'},
    {'name': 'Baguio', 'type': 'place'},
    {'name': 'Iloilo City', 'type': 'city'},
    {'name': 'Iloilo', 'type': 'province'},
    {'name': 'Bacolod City', 'type': 'city'},
    {'name': 'Bacolod', 'type': 'place'},
    {'name': 'Cagayan de Oro', 'type': 'city'},
    {'name': 'Zamboanga City', 'type': 'city'},
    {'name': 'Zamboanga', 'type': 'province'},
    {'name': 'Naga City', 'type': 'city'},
    {'name': 'Naga', 'type': 'place'},
    {'name': 'Tacloban City', 'type': 'city'},
    {'name': 'Tacloban', 'type': 'place'},
    {'name': 'Lucena City', 'type': 'city'},
    {'name': 'Lucena', 'type': 'place'},
    {'name': 'Dagupan City', 'type': 'city'},
    {'name': 'Dagupan', 'type': 'place'},
    {'name': 'Olongapo City', 'type': 'city'},
    {'name': 'Olongapo', 'type': 'place'},
    {'name': 'Angeles City', 'type': 'city'},
    {'name': 'Angeles', 'type': 'place'},
    {'name': 'Batangas City', 'type': 'city'},
    {'name': 'Batangas', 'type': 'province'},

    // Regions
    {'name': 'Calabarzon', 'type': 'region'},
    {'name': 'Region IV-A', 'type': 'region'},
    {'name': 'Bicol Region', 'type': 'region'},
    {'name': 'Bicol', 'type': 'region'},
    {'name': 'Central Luzon', 'type': 'region'},
    {'name': 'Region III', 'type': 'region'},
    {'name': 'Western Visayas', 'type': 'region'},
    {'name': 'Region VI', 'type': 'region'},
    {'name': 'Central Visayas', 'type': 'region'},
    {'name': 'Region VII', 'type': 'region'},
    {'name': 'Eastern Visayas', 'type': 'region'},
    {'name': 'Region VIII', 'type': 'region'},
    {'name': 'Northern Mindanao', 'type': 'region'},
    {'name': 'Region X', 'type': 'region'},

    // Provinces
    {'name': 'Cavite', 'type': 'province'},
    {'name': 'Laguna', 'type': 'province'},
    {'name': 'Batangas', 'type': 'province'},
    {'name': 'Rizal', 'type': 'province'},
    {'name': 'Quezon', 'type': 'province'},
    {'name': 'Pampanga', 'type': 'province'},
    {'name': 'Bulacan', 'type': 'province'},
    {'name': 'Nueva Ecija', 'type': 'province'},
    {'name': 'Pangasinan', 'type': 'province'},
    {'name': 'La Union', 'type': 'province'},
    {'name': 'Ilocos Norte', 'type': 'province'},
    {'name': 'Ilocos Sur', 'type': 'province'},
    {'name': 'Benguet', 'type': 'province'},
  ];

  // Update payment method specific patterns
  final Map<String, Map<String, dynamic>> paymentMethodPatterns = {
    'Gcash': {
      'keywords': [
        'Sent via GCash',
        'Via GCash',
        'GCash',
        'You sent',
        'Amount',
        'Total Amount',
        'PHP',
        '₱',
      ],
      'amountPattern': [
        r'Amount:?\s*(?:PHP|₱)?\s*([\d,]+(?:\.\d{2})?)',
        r'You sent:?\s*(?:PHP|₱)?\s*([\d,]+(?:\.\d{2})?)',
        r'Total Amount:?\s*(?:PHP|₱)?\s*([\d,]+(?:\.\d{2})?)',
        r'(?:PHP|₱)\s*([\d,]+(?:\.\d{2})?)',
        r'([\d,]+\.\d{2})',
      ],
      'requiredKeywordMatches': 1,  // Only require 1 keyword match
    },
    'PayMaya': {
      'keywords': [
        'PayMaya',
        'Reference ID',
        'PHP',
      ],
      'refPattern': r'Reference #:\s*([A-Z0-9]+)',
      'amountPattern': [
        r'PHP\s*(\d+\.\d{2})',
        r'Amount:\s*PHP\s*(\d+\.\d{2})',
      ],
      'datePattern': r'(\d{2}\s+[A-Za-z]+\s+\d{4},\s*\d{1,2}:\d{2}\s*[AP]M)',
    },
    'PayPal': {
      'keywords': [
        'PayPal',
        'INVOICE',
        'Invoice number',
        'Invoice date',
      ],
      'refPattern': r'Invoice number\s*(\d+)',
      'amountPattern': [
        r'Total\s*£(\d+\.\d{2})',
        r'Amount\s*£(\d+\.\d{2})',
        r'\$(\d+\.\d{2})',
        r'PHP\s*(\d+\.\d{2})',
      ],
      'datePattern': r'(\d{2}/\d{2}/\d{4})',
    },
    'Bank Transfer': {
      'keywords': [
        'transfer',
        'transaction',
        'reference',
        'account',
        'date',
        'amount',
      ],
      'refPattern': r'Reference(?:\s*#)?\s*:\s*([A-Z0-9]+)',
      'amountPattern': [
        r'Amount\s*:\s*PHP\s*(\d+\.\d{2})',
        r'PHP\s*(\d+\.\d{2})',
        r'₱\s*(\d+\.\d{2})',
      ],
      'datePattern': r'(\d{2}/\d{2}/\d{4})',
    },
  };

  Future<LatLng?> detectLocationFromText(String text) async {
    try {
      // Clean and normalize the text
      String normalizedText = text.toLowerCase()
          .replaceAll(RegExp(r'[^\w\s,]'), '') // Remove special characters except commas
          .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
          .trim();

      // First try exact matches from our predefined list
      for (var place in philippinePlaces) {
        String placeName = place['name']!.toLowerCase();
        if (normalizedText.contains(placeName)) {
          try {
            // Try with city/province/region suffix first if it's not already in the name
            String searchLocation = place['name']!;
            if (!searchLocation.toLowerCase().contains(place['type']!.toLowerCase())) {
              searchLocation = "${place['name']}, ${place['type']}, Philippines";
            } else {
              searchLocation = "$searchLocation, Philippines";
            }

            List<Location> locations = await locationFromAddress(searchLocation);
            if (locations.isNotEmpty) {
              setState(() {
                detectedLocationName = "${place['name']} (${place['type']})";
              });
              return LatLng(locations.first.latitude, locations.first.longitude);
            }
          } catch (e) {
            print('Error geocoding location: $e');
            continue;
          }
        }
      }

      // If no exact match found, try to find potential place names
      List<String> words = normalizedText.split(RegExp(r'[,\s]+'));
      List<String> locationIndicators = [
        'in', 'at', 'near', 'around', 'within', 'from', 'to', 'of',
        'city', 'province', 'region', 'municipality', 'town', 'area',
        'north', 'south', 'east', 'west', 'central'
      ];

      for (int i = 0; i < words.length; i++) {
        // Check if current word is preceded by a location indicator
        if (i > 0 && locationIndicators.contains(words[i - 1].toLowerCase())) {
          String possibleLocation = words[i];
          if (possibleLocation.length > 3) {
            try {
              List<Location> locations = await locationFromAddress("$possibleLocation, Philippines");
              if (locations.isNotEmpty) {
                setState(() {
                  detectedLocationName = possibleLocation;
                });
                return LatLng(locations.first.latitude, locations.first.longitude);
              }
            } catch (e) {
              continue;
            }
          }
        }

        // Try combinations of consecutive words
        if (i < words.length - 1 && words[i].length > 2) {
          String combinedLocation = "${words[i]} ${words[i + 1]}";
          try {
            List<Location> locations = await locationFromAddress("$combinedLocation, Philippines");
            if (locations.isNotEmpty) {
              setState(() {
                detectedLocationName = combinedLocation;
              });
              return LatLng(locations.first.latitude, locations.first.longitude);
            }
          } catch (e) {
            continue;
          }
        }
      }

      // If still no location found, try individual words that might be place names
      for (String word in words) {
        if (word.length > 3 && !locationIndicators.contains(word.toLowerCase())) {
          try {
            List<Location> locations = await locationFromAddress("$word, Philippines");
            if (locations.isNotEmpty) {
              setState(() {
                detectedLocationName = word;
              });
              return LatLng(locations.first.latitude, locations.first.longitude);
            }
          } catch (e) {
            continue;
          }
        }
      }
    } catch (e) {
      print('Error in location detection: $e');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchUserProfileData();
  }

  Future<void> _initializeLocation() async {
    if (widget.articleData != null) {
      if (widget.articleData!['isRequest'] == true) {
        // For active requests, use the provided location
        if (widget.articleData!['latitude'] != null && widget.articleData!['longitude'] != null) {
          setState(() {
            donationLocation = LatLng(
              widget.articleData!['latitude'],
              widget.articleData!['longitude']
            );
          });
        }
      } else {
        // For news articles, try to detect location from title and description
        String searchText = '${widget.articleData!['title']} ${widget.articleData!['subtitle']}';
        LatLng? detectedLocation = await detectLocationFromText(searchText);
        setState(() {
          donationLocation = detectedLocation ?? defaultLocation;
        });
      }
    } else {
      setState(() {
        donationLocation = defaultLocation;
      });
    }
  }

  // Fetching user profile data
  Future<void> _fetchUserProfileData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists && mounted) {
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

  Future<bool> verifyReceipt(File imageFile) async {
    if (mounted) {
      setState(() {
        _isVerifyingReceipt = true;
        _receiptVerificationError = null;
      });
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text;
      print("Recognized text: $text"); // Debug print

      // Get patterns for selected payment method
      final methodPatterns = paymentMethodPatterns[selectedPayment];
      if (methodPatterns == null) {
        if (mounted) {
          setState(() {
            _receiptVerificationError = 'Unsupported payment method';
          });
        }
        return false;
      }

      // 1. Check for GCash keywords - now case sensitive
      final keywords = methodPatterns['keywords'] as List<String>;
      bool isGcashReceipt = keywords.any((keyword) => text.contains(keyword));
      print("Is GCash receipt: $isGcashReceipt"); // Debug print
      print("Found keywords: ${keywords.where((keyword) => text.contains(keyword))}"); // Debug print

      if (!isGcashReceipt) {
        if (mounted) {
          setState(() {
            _receiptVerificationError = 'This doesn\'t appear to be a valid GCash receipt. Please upload a GCash receipt.';
          });
        }
        return false;
      }

      // 2. Verify amount with case-sensitive patterns
      final enteredAmount = double.tryParse(amountController.text.replaceAll(',', '').trim()) ?? 0.0;
      final amountPatterns = methodPatterns['amountPattern'] as List<String>;
      
      Set<double> foundAmounts = {};
      for (var pattern in amountPatterns) {
        final regex = RegExp(pattern);
        for (var match in regex.allMatches(text)) {
          String? amountStr = match.group(1)?.replaceAll(',', '');
          print("Found amount string: $amountStr"); // Debug print
          if (amountStr != null) {
            double? amount = double.tryParse(amountStr);
            if (amount != null) {
              foundAmounts.add(amount);
              print("Parsed amount: $amount"); // Debug print
            }
          }
        }
      }

      print("All found amounts: $foundAmounts"); // Debug print
      bool hasMatchingAmount = foundAmounts.any((amount) => 
          (amount - enteredAmount).abs() < 0.01);

      if (!hasMatchingAmount && mounted) {
        setState(() {
          _receiptVerificationError = 'The amount entered (₱${enteredAmount.toStringAsFixed(2)}) doesn\'t match the amount in the receipt.';
        });
        return false;
      }

      return true;
    } catch (e) {
      print("Error verifying receipt: $e");
      if (mounted) {
        setState(() {
          _receiptVerificationError = 'Error verifying receipt. Please try again.';
        });
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingReceipt = false;
        });
      }
    }
  }

  DateTime? _parseDate(String dateStr) {
    // List of possible date formats
    final formats = [
      // GCash formats
      RegExp(r'^([A-Za-z]+)\s+(\d{1,2}),\s*(\d{4})\s+(\d{1,2}):(\d{2})\s*([AP]M)$'),
      // PayMaya formats
      RegExp(r'^(\d{2})\s+([A-Za-z]+)\s+(\d{4}),\s*(\d{1,2}):(\d{2})\s*([AP]M)$'),
      // Standard formats
      RegExp(r'^(\d{2})/(\d{2})/(\d{4})\s+(\d{1,2}):(\d{2})\s*([AP]M)$'),
    ];

    for (var format in formats) {
      final match = format.firstMatch(dateStr);
      if (match != null) {
        try {
          final groups = match.groups([1, 2, 3, 4, 5, 6]);
          
          int year = int.parse(groups[2]!);
          int month;
          int day;
          
          if (RegExp(r'^\d{2}$').hasMatch(groups[0]!)) {
            // DD MM YYYY format
            day = int.parse(groups[0]!);
            month = _getMonthNumber(groups[1]!);
          } else {
            // Month DD, YYYY format
            month = _getMonthNumber(groups[0]!);
            day = int.parse(groups[1]!);
          }
          
          int hour = int.parse(groups[3]!);
          int minute = int.parse(groups[4]!);
          String ampm = groups[5]!;
          
          // Convert to 24-hour format
          if (ampm.toUpperCase() == 'PM' && hour != 12) hour += 12;
          if (ampm.toUpperCase() == 'AM' && hour == 12) hour = 0;
          
          return DateTime(year, month, day, hour, minute);
        } catch (e) {
          print("Error parsing date with format $format: $e");
          continue;
        }
      }
    }
    return null;
  }

  int _getMonthNumber(String month) {
    final months = {
      'January': 1, 'Jan': 1,
      'February': 2, 'Feb': 2,
      'March': 3, 'Mar': 3,
      'April': 4, 'Apr': 4,
      'May': 5,
      'June': 6, 'Jun': 6,
      'July': 7, 'Jul': 7,
      'August': 8, 'Aug': 8,
      'September': 9, 'Sep': 9,
      'October': 10, 'Oct': 10,
      'November': 11, 'Nov': 11,
      'December': 12, 'Dec': 12,
    };
    return months[month] ?? DateTime.now().month;
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
      
      // Verify receipt first
      bool isValidReceipt = await verifyReceipt(_pickedImage!);
      
      if (!isValidReceipt) {
        Navigator.of(context).pop(); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_receiptVerificationError ?? 'Invalid receipt. Please upload a valid receipt.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? receiptUrl = await uploadImageToImgBB(_pickedImage!);

      if (receiptUrl == null) {
        throw Exception('Failed to upload receipt image');
      }

      double latitude = donationLocation.latitude;
      double longitude = donationLocation.longitude;

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
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your donation!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Add a small delay to allow the snackbar to be visible
      await Future.delayed(Duration(seconds: 1));
      
      // Navigate back to home page
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving donation: $e'),
          backgroundColor: Colors.red,
        ),
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
  void dispose() {
    super.dispose();
    _textRecognizer.close();
    nameController.dispose();
    numberController.dispose();
    amountController.dispose();
    additionalInfoController.dispose();
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
            if (widget.articleData != null) Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Donating to help with:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.articleData!['title'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.articleData!['subtitle'] ?? '',
                    style: TextStyle(fontSize: 12),
                  ),
                  if (widget.articleData!['isRequest'] != true) ...[
                    SizedBox(height: 4),
                    Text(
                      'Source: ${widget.articleData!['source'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16),
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
            if (widget.articleData != null && widget.articleData!['isRequest'] == true && widget.articleData!['address'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                child: Text(
                  widget.articleData!['address'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: 10),
            _buildMapView(),
            SizedBox(height: 20),
            // Profile Info Section
            Center(
              child: Column(
                children: [
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
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                onPressed: () async {
                  await saveDonation();
                },
                child: Text(
                  'Donate Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_receiptVerificationError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _receiptVerificationError!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (_isVerifyingReceipt)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Verifying receipt...'),
                  ],
                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detectedLocationName.isNotEmpty && widget.articleData != null && widget.articleData!['isRequest'] != true)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              detectedLocationName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: donationLocation,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: donationLocation,
                      width: 40.0,
                      height: 40.0,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
