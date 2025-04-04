import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonatorPage extends StatefulWidget {
  @override
  _DonatorPageState createState() => _DonatorPageState();
}

class _DonatorPageState extends State<DonatorPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController additionalInfoController =
      TextEditingController();

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
      await FirebaseFirestore.instance.collection('physical_donations').add({
        'name': name,
        'contact': contact,
        'pickup_location': pickupLocation,
        'additional_info': additionalInfoController.text.trim(),
        'donated_items': donatedItems,
        'latitude': 14.1084,
        'longitude': 121.1416,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation submitted successfully!')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);

      // Optionally, clear the form
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save donation: $e')),
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
