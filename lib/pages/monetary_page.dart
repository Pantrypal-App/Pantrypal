import 'package:flutter/material.dart';
import 'donator2_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  bool isLoading = true;
  bool hasError = false;
  bool isSearching = false;
  StreamSubscription? _requestsSubscription;
  Timer? _searchDebounce;

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
    ongoingUrl = 'https://gnews.io/api/v4/search?q=Philippines+hunger&token=$apiKey';
    loveUrl = 'https://gnews.io/api/v4/search?q=Philippines+food+insecurity+hunger&token=$apiKey';
    
    fetchNews();
    _setupRequestsListener();
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _setupRequestsListener() {
    _requestsSubscription = FirebaseFirestore.instance
        .collection('requests')
        .where('type', isEqualTo: 'monetary')
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
          'amount': data['amount'],
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
    // Cancel previous debounce timer
    _searchDebounce?.cancel();
    
    // Update requests filtering - search in both title and description
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredRequests = requests.where((request) {
        final title = request['title']?.toString().toLowerCase() ?? '';
        final subtitle = request['subtitle']?.toString().toLowerCase() ?? '';
        return title.contains(lowerQuery) || subtitle.contains(lowerQuery);
      }).toList();
    });
    
    // Debounce the API search to avoid too many requests
    _searchDebounce = Timer(Duration(milliseconds: 500), () {
      searchNews(query);
    });
  }

  Future<void> searchNews(String query) async {
    print("Searching for: '$query'"); // Debug print
    
    if (query.trim().isEmpty) {
      // If search is empty, show all original news
      setState(() {
        filteredDonations = donations;
        isSearching = false;
        isLoading = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      isLoading = true;
    });

    try {
      // Search in both title and description by using a broader search query
      final searchUrl = Uri.parse(
          'https://gnews.io/api/v4/search?q=$query&country=ph&lang=en&max=20&token=$apiKey');

      print("Making API call to: $searchUrl"); // Debug print

      final response = await http.get(searchUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        
        print("Found ${articles.length} articles"); // Debug print

        final filteredArticles = articles.where((article) {
          final dateStr = article['publishedAt'] ?? '';
          if (dateStr.isEmpty) return false;
          final pubDate = DateTime.tryParse(dateStr);
          if (pubDate == null) return false;
          return pubDate.year >= 2024 && pubDate.year <= 2025;
        }).toList();

        final List<Map<String, dynamic>> searchResults = [];
        
        for (var article in filteredArticles) {
          final title = article['title']?.toString() ?? 'No Title';
          final description = article['description']?.toString() ?? 'No Description';
          final location = await getLocationFromArticle(title, description);
          
          searchResults.add({
            'title': title,
            'subtitle': description,
            'count': '${(1000 + title.hashCode % 3000)} donations',
            'location': location,
            'url': article['url'],
            'source': article['source']?['name'] ?? 'Unknown Source',
          });
        }

        print("Filtered to ${searchResults.length} results"); // Debug print

        setState(() {
          filteredDonations = searchResults;
          isSearching = false;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      print("Search error: $e");
      setState(() {
        isSearching = false;
        isLoading = false;
        // On error, show original news
        filteredDonations = donations;
      });
    }
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterDonations,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search donations and requests...',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                searchController.clear();
                                filterDonations('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                if (isSearching) ...[
                  SizedBox(width: 10),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            SizedBox(height: 20),
            if (isLoading && !isSearching)
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
                SizedBox(height: 24),
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
                  if (request['amount'] != null) ...[
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
                          Icon(Icons.attach_money, size: 12, color: Colors.orange.shade800),
                          SizedBox(width: 2),
                          Text(
                            'Amount: ₱${request['amount']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade800,
                              fontStyle: FontStyle.italic,
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
                  builder: (context) => Donator2Page(
                    articleData: {
                      'title': title,
                      'subtitle': subtitle,
                      'count': count,
                      'isRequest': true,
                      'requestId': request['id'],
                      'userId': request['userId'],
                      'userName': request['userName'],
                      'amount': request['amount'],
                      'address': request['address'],
                      'latitude': request['latitude'],
                      'longitude': request['longitude'],
                    },
                    userId: request['userId'],
                    name: request['userName'] ?? 'Anonymous',
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
