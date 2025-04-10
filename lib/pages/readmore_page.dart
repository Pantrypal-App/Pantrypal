import 'process_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

class ReadMorePage extends StatefulWidget {
  final String articleUrl;

  ReadMorePage({required this.articleUrl});

  @override
  _ReadMorePageState createState() => _ReadMorePageState();
}

class _ReadMorePageState extends State<ReadMorePage> {
  String articleContent = '';
  String articleImage = '';
  String articleTitle = '';
  String articleDescription = '';
  bool isLoading = true;
  bool hasError = false;

  final List<String> blacklistKeywords = [
  'no comments yet',
  'how does this make you feel',
  'follow us',
  'subscribe',
  'advertisement',
  'ad:',
  'share this story',
  'sponsored content',
  'join our newsletter',
  'please abide by rappler',
  'checking your rappler+',
  'upgrade to rappler+',
  'all right reserved',
];


  @override
  void initState() {
    super.initState();
    fetchArticle();
  }

  Future<void> fetchArticle() async {
    try {
      final response = await http.get(Uri.parse(widget.articleUrl));

      if (response.statusCode == 200) {
        var document = html.parse(response.body);

        String title = document.querySelector('title')?.text ?? 'No title available';
        String image = document.querySelector('img')?.attributes['src'] ?? '';
        String description = document
                .querySelector('meta[name="description"]')
                ?.attributes['content'] ??
            'No description available';

        if (image.isEmpty || image.startsWith('data:image')) {
          image = 'https://media.licdn.com/dms/image/v2/D5612AQEvNyNDzsTosA/article-cover_image-shrink_720_1280/B56ZYLonVPH0AI-/0/1743951919345?e=2147483647&v=beta&t=bFYrq44qSgoyOHr4H_xXw31N_JkVNrL5Emd7zjUNEOk';
        }

        String content = '';
        var paragraphs = document.querySelectorAll('p');

        for (var p in paragraphs) {
          String text = p.text.trim();
          // Filter out unwanted content
          bool isClean = !blacklistKeywords.any((phrase) => text.toLowerCase().contains(phrase));
          if (isClean && text.isNotEmpty) {
            content += text + "\n\n";
          }
        }

        setState(() {
          articleTitle = title;
          articleImage = image;
          articleDescription = description;
          articleContent = content;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load article');
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(93, 0, 255, 68),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProcessPage()),
            );
          },
          child: Text(
            'Donate Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Text(
                    "Failed to load article.",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      articleImage.isNotEmpty
                          ? Image.network(
                              articleImage,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            )
                          : Container(height: 250, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        articleTitle,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        articleDescription,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 20),
                      Text(
                        articleContent,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 100), // To leave space above the bottom button
                    ],
                  ),
                ),
    );
  }
}
