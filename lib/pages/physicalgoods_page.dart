import 'package:flutter/material.dart';
import 'donator_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PhysicalGoodsDonationPage extends StatefulWidget {
  @override
  _PhysicalGoodsDonationPageState createState() =>
      _PhysicalGoodsDonationPageState();
}

class _PhysicalGoodsDonationPageState extends State<PhysicalGoodsDonationPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> donations = [];
  List<Map<String, String>> filteredDonations = [];
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  bool isLoading = true;
  bool hasError = false;
  StreamSubscription? _requestsSubscription;

  final String apiKey = '40d90771b221f00df174794556caf8e5';

  String ongoingUrl = '';
  String loveUrl = '';

  @override
  void initState() {
    super.initState();
    ongoingUrl = 'https://gnews.io/api/v4/search?q=Philippines+hunger&token=$apiKey';
    loveUrl = 'https://gnews.io/api/v4/search?q=Philippines+food+insecurity+hunger&token=$apiKey';
    
    fetchNews();
    _setupRequestsListener();
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    super.dispose();
  }

  void _setupRequestsListener() {
    _requestsSubscription = FirebaseFirestore.instance
        .collection('requests')
        .where('type', isEqualTo: 'physical')
        .snapshots()
        .listen((snapshot) {
      final List<Map<String, dynamic>> loadedRequests = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        loadedRequests.add({
          'id': doc.id,
          'title': data['title'] ?? 'No Title',
          'subtitle': data['description'] ?? 'No Description',
          'count': '${data['donationCount'] ?? 0} donations',
          'isRequest': true,
          'userId': data['userId'],
          'userName': data['userName'] ?? 'Anonymous',
          'timestamp': data['timestamp'],
          'items': data['items'] ?? [],
          'address': data['address'] ?? '',
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
        });
      }

      setState(() {
        requests = loadedRequests;
        filteredRequests = loadedRequests;
        _updateFilteredContent(searchController.text);
      });
    }, onError: (error) {
      print("Error fetching requests: $error");
      setState(() {
        hasError = true;
      });
    });
  }

  void _updateFilteredContent(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredDonations = donations.where((donation) =>
          donation['title']!.toLowerCase().contains(lowerQuery)).toList();
      
      filteredRequests = requests.where((request) =>
          request['title']!.toLowerCase().contains(lowerQuery)).toList();
    });
  }

  void filterDonations(String query) {
    _updateFilteredContent(query);
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

      final List<Map<String, String>> loadedDonations =
          filteredArticles.map<Map<String, String>>((article) {
        return {
          'title': article['title']?.toString() ?? 'No Title',
          'subtitle': article['description']?.toString() ?? 'No Description',
          'count': '${(1000 + article['title'].hashCode % 3000)} donations',
          'source': article['source']?['name']?.toString() ?? 'Unknown Source',
        };
      }).toList();

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
              'Physical Goods Donation',
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
            SizedBox(height: 20),
            TextField(
              controller: searchController,
              onChanged: filterDonations,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search donations and requests...',
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
                  child: Text("Failed to load content.",
                      style: TextStyle(color: Colors.red)))
            else ...[
              if (filteredRequests.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.volunteer_activism, color: Colors.orange.shade800),
                      SizedBox(width: 8),
                      Text(
                        'Active Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          if (index > 0)
                            Divider(height: 1, color: Colors.orange.shade200),
                          _requestItem(
                            filteredRequests[index]['title']!,
                            filteredRequests[index]['subtitle']!,
                            filteredRequests[index]['count']!,
                            filteredRequests[index],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
              ],
              if (filteredDonations.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.newspaper, color: Colors.blue.shade800),
                      SizedBox(width: 8),
                      Text(
                        'News & Updates',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _requestItem(String title, String subtitle, String count, Map<String, dynamic> request) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, size: 12, color: Colors.orange.shade800),
                            SizedBox(width: 2),
                            Text(
                              request['userName'] ?? 'Anonymous',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.orange.shade900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (request['items'] != null && (request['items'] as List).isNotEmpty) ...[
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2, size: 12, color: Colors.orange.shade800),
                          SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              'Items: ${(request['items'] as List).join(", ")}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (request['address'] != null && request['address'].toString().isNotEmpty) ...[
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.orange.shade800),
                          SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              'Location: ${request['address']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 4),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
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
                  builder: (context) => DonatorPage(
                    articleData: {
                      'title': title,
                      'subtitle': subtitle,
                      'count': count,
                      'isRequest': true,
                      'requestId': request['id'],
                      'userId': request['userId'],
                      'userName': request['userName'],
                      'items': request['items'],
                      'address': request['address'],
                      'latitude': request['latitude'],
                      'longitude': request['longitude'],
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(93, 0, 255, 68),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: Size(90, 36),
            ),
            child: Text(
              'Donate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _donationItem(String title, String subtitle, String count) {
    final Map<String, String> donation = filteredDonations.firstWhere(
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
                  builder: (context) => DonatorPage(
                    articleData: {
                      'title': title,
                      'subtitle': subtitle,
                      'count': count,
                      'source': donation['source'] ?? 'Unknown Source',
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
              minimumSize: Size(90, 36),
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
