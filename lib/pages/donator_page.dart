import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DonatorPage extends StatefulWidget {
  @override
  _DonatorPageState createState() => _DonatorPageState();
}

class _DonatorPageState extends State<DonatorPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController additionalInfoController = TextEditingController();

  String? selectedCity;
  bool isOtherSelected = false;

  final List<String> cities = [
    'Manila', 'Quezon', 'Davao', 'Cebu', 'Zamboanga', 'Batangas',
    'Taguig', 'Pasig', 'Cagayan de Oro', 'Bacolod', 'Makati',
    'Other'
  ];

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
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder()),
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
                    decoration: InputDecoration(labelText: 'Enter Address', border: OutlineInputBorder()),
                  ),
                ),
              SizedBox(height: 12),
              _buildMapView(),
              SizedBox(height: 12),
              // Additional Information Field (Placed under the map)
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
                onPressed: () {
                  // Handle donation submission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Center(child: Text('Donate Now', style: TextStyle(color: Colors.white))),
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
