import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReadMorePage extends StatefulWidget {
  final String articleUrl; // The URL of the article to fetch
  
  // Constructor to pass the URL of the article
  ReadMorePage({required this.articleUrl});
  
  @override
  _ReadMorePageState createState() => _ReadMorePageState();
}

class _ReadMorePageState extends State<ReadMorePage> {
  late bool isLoading;
  late bool hasError;
  late Map<String, dynamic> article;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    hasError = false;
    article = {};
    fetchArticleDetails();
  }

  // Function to fetch article details using the provided URL
  Future<void> fetchArticleDetails() async {
    try {
      final response = await http.get(Uri.parse(widget.articleUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          article = {
            'title': data['title'] ?? 'No title',
            'description': data['description'] ?? 'No description available.',
            'content': data['content'] ?? 'No content available.',
            'image_url': data['image_url'] ?? 'https://via.placeholder.com/150',
          };
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print("Error: Failed to load article with status code ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Text(
                    'Failed to load article.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display article image
                      Stack(
                        children: [
                          Image.network(
                            article['image_url'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Text(
                              article['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Article overview section
                            Text(
                              'OVERVIEW',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              article['description'],
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              article['content'],
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16),
                            // Additional content or updates section
                            Text(
                              'IMAGE GALLERY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Image.network(
                              article['image_url'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 16),
                            // Call to action: Donate Now
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                ),
                                onPressed: () {
                                  
                                },
                                child: Text(
                                  'Donate Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
