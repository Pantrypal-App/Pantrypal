import 'package:flutter/material.dart';
import 'donator2_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class MonetaryDonationPage extends StatefulWidget {
  @override
  _MonetaryDonationPageState createState() => _MonetaryDonationPageState();
}

class _MonetaryDonationPageState extends State<MonetaryDonationPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> donations = [];
  List<Map<String, dynamic>> filteredDonations = [];
  bool isLoading = true;
  bool hasError = false;

  final String apiKey = '1d263f1b383b160fd54e77d76a89d077';

  String ongoingUrl = '';
  String loveUrl = '';

  // Predefined Philippine locations for better reliability
  final List<LatLng> philippineLocations = [
    LatLng(14.5995, 120.9842), // Manila
    LatLng(14.6091, 121.0223), // Quezon City
    LatLng(10.3157, 123.8854), // Cebu
    LatLng(7.1907, 125.4553),  // Davao
    LatLng(10.6713, 122.9511), // Iloilo
  ];

  @override
  void initState() {
    super.initState();
    ongoingUrl =
        'https://gnews.io/api/v4/search?q=Philippines+hunger&token=$apiKey';
    loveUrl =
        'https://gnews.io/api/v4/search?q=Philippines+food+insecurity+hunger&token=$apiKey';

    fetchNews();
  }

  Future<LatLng> getLocationFromArticle(String title, String description) async {
    // Get a consistent but random-looking location based on the title
    int index = title.hashCode.abs() % philippineLocations.length;
    return philippineLocations[index];
  }

  Future<void> fetchNews() async {
    try {
      final query = 'food OR hunger OR health OR disaster';
      final searchUrl = Uri.parse(
          'https://gnews.io/api/v4/search?q=$query&country=ph&lang=en&max=10&token=$apiKey');

      // Create futures for all the URLs
      final searchFuture = http.get(searchUrl);
      final ongoingFuture = http.get(Uri.parse(ongoingUrl));
      final loveFuture = http.get(Uri.parse(loveUrl));

      // Wait for all of them to complete
      final responses = await Future.wait([searchFuture, ongoingFuture, loveFuture]);

      List<dynamic> allArticles = [];

      // Parse the responses from all three URLs
      for (final response in responses) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> articles = data['articles'] ?? [];
          allArticles.addAll(articles);
        } else {
          throw Exception('Failed to load news from one or more sources');
        }
      }

      // Remove duplicates based on 'url'
      Set<String> seenUrls = Set();
      allArticles = allArticles.where((article) {
        final url = article['url'];
        if (url == null || seenUrls.contains(url)) {
          return false;
        } else {
          seenUrls.add(url);
          return true;
        }
      }).toList();

      final filteredArticles = allArticles.where((article) {
        final dateStr = article['publishedAt'] ?? '';
        if (dateStr.isEmpty) return false;
        final pubDate = DateTime.tryParse(dateStr);
        if (pubDate == null) return false;
        return pubDate.year >= 2024 && pubDate.year <= 2025;
      }).toList();

      final List<Map<String, dynamic>> loadedDonations = [];
      
      for (var article in filteredArticles) {
        final title = article['title']?.toString() ?? 'No Title';
        final description = article['description']?.toString() ?? 'No Description';
        final location = await getLocationFromArticle(title, description);
        
        loadedDonations.add({
          'title': title,
          'subtitle': description,
          'count': '${(1000 + title.hashCode % 3000)} donations',
          'location': location,
          'url': article['url'],
          'source': article['source']?['name'] ?? 'Unknown Source',
        });
      }

      setState(() {
        donations = loadedDonations;
        filteredDonations = loadedDonations;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void filterDonations(String query) {
    setState(() {
      filteredDonations = donations
          .where((donation) =>
              donation['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monetary Donation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'lib/images/graph.png',
                      fit: BoxFit.contain,
                      height: 120,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Statistics',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    'As of year 2024, our donations were on the rise. Thanks to your generosity! Let\'s keep this momentum going.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            // GCash Donation Section
            SizedBox(height: 30),
            Text(
              'Donate via GCash',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 10),
            Text(
              'You can send your donations via GCash to the number below:',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 10),
            Container(
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
                    'GCash Number: +63 927 367 943',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Please ensure to send your donations to the GCash number above. Your generosity will help those in need. Thank you!',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: searchController,
              onChanged: filterDonations,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search Here...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (hasError)
              Center(
                  child: Text("Failed to load news.",
                      style: TextStyle(color: Colors.red)))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredDonations.length,
                itemBuilder: (context, index) {
                  return _donationItem(
                    filteredDonations[index]['title']!,
                    filteredDonations[index]['subtitle']!,
                    filteredDonations[index]['count']!,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _donationItem(String title, String subtitle, String count) {
    final Map<String, dynamic> donation = filteredDonations.firstWhere(
      (d) => d['title'] == title && d['subtitle'] == subtitle,
      orElse: () => {},
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$subtitle\n$count as of Dec 2024',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Donator2Page(
                    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    name: FirebaseAuth.instance.currentUser?.displayName ?? 'Guest',
                    articleData: {
                      'title': title,
                      'subtitle': subtitle,
                      'count': count,
                      'url': donation['url'],
                      'source': donation['source'],
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(93, 0, 255, 68),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Donate',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
