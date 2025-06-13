import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home_page.dart';
import 'Donate_page.dart';
import 'Notification_page.dart';
import 'package:geocoding/geocoding.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  int selectedIndex = 2;
  Map<String, bool> selectedDonations = {
    "MONEY": false,
    "CLOTHES": false,
    "FOOD": false,
    "MEDICINE": false,
    "ANIMAL FOOD": false,
    "OTHER": false,
  };

  TextEditingController otherController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  LatLng currentLocation = LatLng(14.1084, 121.1416); // Default location
  MapController mapController = MapController();

  final Map<String, String> donationImages = {
    "MONEY": "lib/images/pig 2.png",
    "CLOTHES": "lib/images/clothe 2.png",
    "FOOD": "lib/images/food 2.png",
    "MEDICINE": "lib/images/medicine 2.png",
    "ANIMAL FOOD": "lib/images/animal-food 2.png",
  };

  @override
  void initState() {
    super.initState();
    addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    addressController.removeListener(_onAddressChanged);
    addressController.dispose();
    super.dispose();
  }

  Future<void> _onAddressChanged() async {
    if (addressController.text.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(addressController.text);
      if (locations.isNotEmpty) {
        setState(() {
          currentLocation = LatLng(locations.first.latitude, locations.first.longitude);
        });
        mapController.move(currentLocation, 15.0);
      }
    } catch (e) {
      print('Error getting location from address: $e');
    }
  }

  Future<String> getProfilePhotoUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.get('profilePic') ?? '';
    }
    return '';
  }

  Future<void> saveRequestData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Collect selected donation types
        List<String> donationTypes = selectedDonations.keys
            .where((key) => selectedDonations[key] == true)
            .toList();

        // Add the "other" donation if it's selected
        if (selectedDonations["OTHER"] == true &&
            otherController.text.isNotEmpty) {
          donationTypes.add("OTHER: ${otherController.text}");
        }

        // Validate required fields
        if (nameController.text.isEmpty || 
            addressController.text.isEmpty || 
            descriptionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("All fields are required!"),
            backgroundColor: Colors.red,
          ));
          return;
        }

        // Validate amount for monetary requests
        if (selectedDonations["MONEY"] == true && amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please specify the amount needed for monetary donation"),
            backgroundColor: Colors.red,
          ));
          return;
        }

        // Determine if this is a monetary or physical request
        bool isMonetaryRequest = donationTypes.contains("MONEY");
        String requestType = isMonetaryRequest ? "monetary" : "physical";

        // Get user data for the request
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        String userName = userDoc.get('name') ?? 'Anonymous';

        // Create the request data
        Map<String, dynamic> requestData = {
          'userId': user.uid,
          'userName': userName,
          'title': 'Request Donation', // Default title
          'description': descriptionController.text,
          'type': requestType,
          'donations': donationTypes,
          'address': addressController.text,
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
          'timestamp': FieldValue.serverTimestamp(),
          'donationCount': 0,
        };

        // Add amount field for monetary requests
        if (isMonetaryRequest) {
          double amount = double.tryParse(amountController.text) ?? 0.0;
          requestData['amount'] = amount;
        }

        // Save request data
        await FirebaseFirestore.instance.collection('requests').add(requestData);

        // Add notification
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': user.uid,
          'title': 'Request Submitted!',
          'message': 'Your request for ${donationTypes.join(", ")} has been submitted. We will process it soon!',
          'icon': 'request_page',
          'color': 'blue',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Request submitted successfully!"),
          backgroundColor: Colors.green,
        ));

        // Clear form
        setState(() {
          nameController.clear();
          addressController.clear();
          otherController.clear();
          descriptionController.clear();
          amountController.clear();
          selectedDonations.forEach((key, value) {
            selectedDonations[key] = false;
          });
        });

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to submit request: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  final List<TabItem> items = [
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.volunteer_activism, title: 'Donate'),
    TabItem(icon: Icons.request_page, title: 'Request'),
    TabItem(icon: Icons.notifications, title: 'Notification'),
    TabItem(icon: Icons.person, title: 'You'),
  ];

  void _onNavBarTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DonationPage()));
    } else if (index == 3) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NotificationPage()));
    } else if (index == 4) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfilePage()));
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PantryPal"),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: FutureBuilder<String>(
                  future: getProfilePhotoUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        child:
                            Icon(Icons.person, size: 40, color: Colors.white),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              Text("ASK FOR DONATIONS!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildTextField("Full Name", controller: nameController),
              SizedBox(height: 8),
              _buildTextField("Address", controller: addressController),
              SizedBox(height: 16),
              _buildMapView(),
              SizedBox(height: 16),
              Text("SELECT REQUEST DONATION TYPE:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildDonationSelection(),
              if (selectedDonations["MONEY"] == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildTextField("Amount Needed (₱)", 
                    controller: amountController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              if (selectedDonations["OTHER"] == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildTextField("Specify Other Donation",
                      controller: otherController),
                ),
              SizedBox(height: 16),
              Text("ADDITIONAL INFORMATION:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildTextField("Description", 
                controller: descriptionController, 
                maxLines: 3,
                hintText: "Please provide any additional details about your request...",
              ),
              SizedBox(height: 16),
              _buildButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: Colors.green,
        color: Colors.black,
        colorSelected: Colors.black,
        indexSelected: selectedIndex,
        onTap: _onNavBarTap,
        chipStyle:
            const ChipStyle(convexBridge: true, background: Colors.white),
        itemStyle: ItemStyle.circle,
        titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        animated: true,
      ),
    );
  }

  Widget _buildTextField(String label, {
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 200,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation,
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: currentLocation,
                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonationSelection() {
    return Column(
      children: [
        ...selectedDonations.keys.map((label) => _buildDonationType(label)),
      ],
    );
  }

  Widget _buildDonationType(String label) {
    return ListTile(
      leading: donationImages.containsKey(label)
          ? Image.asset(donationImages[label]!, width: 40, height: 40)
          : Icon(Icons.add_circle, size: 40, color: Colors.grey),
      title: Text(label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: Checkbox(
        value: selectedDonations[label] ?? false,
        onChanged: (value) {
          setState(() {
            selectedDonations[label] = value!;
          });
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _styledButton("Cancel", Colors.grey),
        _styledButton("Submit", const Color.fromARGB(93, 0, 255, 68)),
      ],
    );
  }

  Widget _styledButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {
        if (text == "Submit") {
          saveRequestData(); // Call saveRequestData when Submit is pressed
        } else if (text == "Cancel") {
          // You can either clear the form or navigate to another page
          setState(() {
            nameController.clear();
            addressController.clear();
            otherController.clear();
            descriptionController.clear();
            amountController.clear();
            selectedDonations = {
              "MONEY": false,
              "CLOTHES": false,
              "FOOD": false,
              "MEDICINE": false,
              "ANIMAL FOOD": false,
              "OTHER": false,
            };
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(
        text, // Make sure the 'text' parameter is passed correctly
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
