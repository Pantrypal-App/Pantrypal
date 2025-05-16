import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonatorPage extends StatefulWidget {
  final Map<String, dynamic>? articleData;

  DonatorPage({this.articleData});

  @override
  _DonatorPageState createState() => _DonatorPageState();
}

class _DonatorPageState extends State<DonatorPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController additionalInfoController =
      TextEditingController();
  LatLng currentLocation = LatLng(14.1084, 121.1416); // Default location
  MapController mapController = MapController();

  String? selectedCity;
  bool isOtherSelected = false;

  final List<String> cities = [
    'Manila',
    'Quezon',
    'Davao',
    'Cebu',
    'Zamboanga',
    'Batangas',
    'Taguig',
    'Pasig',
    'Cagayan de Oro',
    'Bacolod',
    'Makati',
    'Other'
  ];
  bool donateFood = false;
  bool donateMedicine = false;
  bool donateClothes = false;
  bool donateAnimalFood = false;

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

  Future<void> _updateLocationFromCity(String? city) async {
    if (city == null || city == 'Other') return;

    try {
      // Add ", Philippines" to make the search more accurate
      List<Location> locations = await locationFromAddress('$city, Philippines');
      if (locations.isNotEmpty) {
        setState(() {
          currentLocation = LatLng(locations.first.latitude, locations.first.longitude);
        });
        mapController.move(currentLocation, 12.0);
      }
    } catch (e) {
      print('Error getting location from city: $e');
    }
  }

  Future<void> saveDonation() async {
    String name = nameController.text.trim();
    String contact = contactController.text.trim();
    String pickupLocation =
        isOtherSelected ? addressController.text.trim() : selectedCity ?? '';

    // Check for required fields
    if (name.isEmpty || contact.isEmpty || pickupLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    // At least one item should be selected
    if (!donateFood && !donateMedicine && !donateClothes && !donateAnimalFood) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one item to donate.')),
      );
      return;
    }

    List<String> donatedItems = [];
    if (donateFood) donatedItems.add('Food');
    if (donateMedicine) donatedItems.add('Medicine');
    if (donateClothes) donatedItems.add('Clothes');
    if (donateAnimalFood) donatedItems.add('Animal Food');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please sign in to donate.')),
        );
        return;
      }

      // Save donation data
      await FirebaseFirestore.instance.collection('physical_donations').add({
        'userId': user.uid,
        'name': name,
        'contact': contact,
        'pickup_location': pickupLocation,
        'additional_info': additionalInfoController.text.trim(),
        'donated_items': donatedItems,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': 'Donation Submitted!',
        'message': 'Thank you for your donation of ${donatedItems.join(", ")}. We will contact you soon!',
        'icon': 'volunteer_activism',
        'color': 'green',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Donation submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      setState(() {
        nameController.clear();
        contactController.clear();
        addressController.clear();
        additionalInfoController.clear();
        selectedCity = null;
        isOtherSelected = false;
        donateFood = false;
        donateMedicine = false;
        donateClothes = false;
        donateAnimalFood = false;
      });

      // Navigate back to home page
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save donation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Physical Goods Donation'),
        backgroundColor: Color(0xFF78A85A),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                    labelText: 'Contact Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(border: OutlineInputBorder()),
                value: selectedCity,
                hint: Text('Select Pickup Location'),
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                    isOtherSelected = value == 'Other';
                  });
                  _updateLocationFromCity(value);
                },
              ),
              if (isOtherSelected)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                        labelText: 'Enter Address',
                        border: OutlineInputBorder()),
                  ),
                ),
              SizedBox(height: 12),
              _buildMapView(),
              SizedBox(height: 12),
              // Additional Information Field (Placed under the map)
              // Donation type checkboxes
              Text('Items to Donate:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Food'),
                value: donateFood,
                onChanged: (val) => setState(() => donateFood = val ?? false),
              ),
              CheckboxListTile(
                title: Text('Medicine'),
                value: donateMedicine,
                onChanged: (val) =>
                    setState(() => donateMedicine = val ?? false),
              ),
              CheckboxListTile(
                title: Text('Clothes'),
                value: donateClothes,
                onChanged: (val) =>
                    setState(() => donateClothes = val ?? false),
              ),
              CheckboxListTile(
                title: Text('Animal Food'),
                value: donateAnimalFood,
                onChanged: (val) =>
                    setState(() => donateAnimalFood = val ?? false),
              ),

              TextField(
                controller: additionalInfoController,
                decoration: InputDecoration(
                  labelText: 'Additional Information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allows multiline input
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Center(
                    child: Text('Donate Now',
                        style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
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
}
