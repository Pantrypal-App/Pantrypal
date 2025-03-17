import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'profile_page.dart';
import 'Home_page.dart';
import 'Donate_page.dart';
import 'Notification_page.dart';

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

  final Map<String, String> donationImages = {
    "MONEY": "lib/images/pig 2.png",
    "CLOTHES": "lib/images/clothe 2.png",
    "FOOD": "lib/images/food 2.png",
    "MEDICINE": "lib/images/medicine 2.png",
    "ANIMAL FOOD": "lib/images/animal-food 2.png",
  };

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
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Text("ASK FOR DONATIONS!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildTextField("Full Name"),
              SizedBox(height: 8),
              _buildTextField("Address"),
              SizedBox(height: 16),
              _buildMapView(),
              SizedBox(height: 16),
              Text("SELECT REQUEST DONATION TYPE:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildDonationSelection(),
              if (selectedDonations["OTHER"] == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildTextField("Specify Other Donation", controller: otherController),
                ),
              SizedBox(height: 16),
              _buildTextField("Additional Information"),
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

  Widget _buildTextField(String label, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
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
      title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(text, style: TextStyle(color: Colors.black)),
    );
  }
}
