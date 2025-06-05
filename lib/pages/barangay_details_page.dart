import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BarangayDetailsPage extends StatelessWidget {
  final String barangayName;
  final String date;
  final String location;

  const BarangayDetailsPage({
    Key? key,
    required this.barangayName,
    required this.date,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> donations = [
      {
        'date': '01/05/2025',
        'total': '50 canned goods',
        'item': 'Recurring donor',
      },
      {
        'date': '01/20/2025',
        'total': '5 rice packs',
        'item': 'Individual contributor',
      },
      {
        'date': '02/15/2025',
        'total': '3 boxes of noodles',
        'item': 'Event-based donation',
      },
      {
        'date': '03/10/2025',
        'total': '20 hygiene kits',
        'item': 'School initiative',
      },
    ];

    final List<String> galleryImages = [
      'lib/images/can goods.jpeg',
      'lib/images/rice.jpeg',
      'lib/images/noodles.jpg',
      'lib/images/hygiene+kits+2020.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          barangayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 28,
                        child: Icon(Icons.volunteer_activism, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barangayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Location: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(location),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Table header
                  Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Total Donation', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Donator', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Table rows
                  ...donations.map((donation) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(donation['date']!)),
                            Expanded(flex: 2, child: Text(donation['total']!)),
                            Expanded(flex: 2, child: Text(donation['item']!)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  const Text(
                    'Gallery',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 180.0,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      viewportFraction: 1.0,
                    ),
                    items: galleryImages.map((imgPath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imgPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 