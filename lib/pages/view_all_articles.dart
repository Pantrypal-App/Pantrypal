import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'process_page.dart';
import 'readmore_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewAllArticlesPage extends StatefulWidget {
  final bool isRewardMode;
  final int? rewardPoints;
  final String? taskKey;

  const ViewAllArticlesPage({
    this.isRewardMode = false,
    this.rewardPoints,
    this.taskKey,
    Key? key,
  }) : super(key: key);

  @override
  _ViewAllArticlesPageState createState() => _ViewAllArticlesPageState();
}

class _ViewAllArticlesPageState extends State<ViewAllArticlesPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> allArticles = [];
  bool isLoading = true;
  String selectedFilter = 'All';
  DateTime? startReadingTime;
  String? currentArticleId;
  Map<String, Duration> articleReadTimes = {};
  bool rewardClaimed = false;
  static const String defaultImage = 'https://media.licdn.com/dms/image/v2/D5612AQEvNyNDzsTosA/article-cover_image-shrink_720_1280/B56ZYLonVPH0AI-/0/1743951919345?e=2147483647&v=beta&t=bFYrq44qSgoyOHr4H_xXw31N_JkVNrL5Emd7zjUNEOk';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchAllNews();
    _loadSavedReadingTimes();
    _checkRewardStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveReadingTime();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveReadingTime();
    } else if (state == AppLifecycleState.resumed) {
      _resumeReadingTime();
    }
  }

  Future<void> _loadSavedReadingTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimes = prefs.getString('article_read_times');
    if (savedTimes != null) {
      final Map<String, dynamic> savedData = json.decode(savedTimes);
      articleReadTimes = Map.fromEntries(
        savedData.entries.map((e) => MapEntry(e.key, Duration(seconds: e.value))),
      );
    }
  }

  Future<void> _saveReadingTime() async {
    if (currentArticleId != null && startReadingTime != null) {
      final timeSpent = DateTime.now().difference(startReadingTime!);
      articleReadTimes[currentArticleId!] = (articleReadTimes[currentArticleId!] ?? Duration.zero) + timeSpent;
      
      final prefs = await SharedPreferences.getInstance();
      final savedData = Map<String, int>.fromEntries(
        articleReadTimes.entries.map((e) => MapEntry(e.key, e.value.inSeconds)),
      );
      await prefs.setString('article_read_times', json.encode(savedData));

      print('Debug: Total reading time for ${currentArticleId!}: ${articleReadTimes[currentArticleId!]?.inSeconds}s');

      // Check if total reading time exceeds 5 minutes and reward hasn't been claimed
      if (widget.isRewardMode && !rewardClaimed) {
        final totalTime = articleReadTimes.values.fold<Duration>(
          Duration.zero, (prev, curr) => prev + curr);
        
        print('Debug: Total reading time across all articles: ${totalTime.inMinutes}m ${totalTime.inSeconds % 60}s');
        
        if (totalTime.inMinutes >= 5) {
          print('Debug: Task completed! Claiming reward of ${widget.rewardPoints} coins');
          await _claimReward();
        }
      }
    }
  }

  void _resumeReadingTime() {
    if (currentArticleId != null) {
      startReadingTime = DateTime.now();
    }
  }

  Future<void> _checkRewardStatus() async {
    if (widget.isRewardMode && widget.taskKey != null) {
      final prefs = await SharedPreferences.getInstance();
      rewardClaimed = prefs.getBool('${widget.taskKey}_completed') ?? false;
    }
  }

  Future<void> _claimReward() async {
    if (!rewardClaimed && widget.rewardPoints != null && widget.taskKey != null) {
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = prefs.getInt('coinBalance') ?? 0;
      print('Debug: Current coins before reward: $currentCoins');
      await prefs.setInt('coinBalance', currentCoins + widget.rewardPoints!);
      await prefs.setBool('${widget.taskKey}_completed', true);
      print('Debug: Task ${widget.taskKey} marked as completed');
      print('Debug: New coin balance: ${currentCoins + widget.rewardPoints!}');
      
      setState(() {
        rewardClaimed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Congratulations! You\'ve earned ${widget.rewardPoints} coins!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String determineCategory(String title, String description) {
    title = title.toLowerCase();
    description = description.toLowerCase();
    
    final Map<String, List<String>> categoryKeywords = {
      'Disaster Relief': ['disaster', 'typhoon', 'earthquake', 'flood', 'emergency', 'relief', 'calamity', 'storm'],
      'Food Security': ['food', 'hunger', 'nutrition', 'meal', 'feeding', 'starv', 'food security', 'food bank', 'pantry'],
      'Health Crisis': ['health', 'medical', 'disease', 'hospital', 'clinic', 'medicine', 'treatment', 'patient', 'malnutrition'],
      'Community Aid': ['community', 'poverty', 'poor', 'assistance', 'support', 'help', 'donation', 'charity', 'volunteer']
    };

    // Check content against keywords
    for (var entry in categoryKeywords.entries) {
      for (var keyword in entry.value) {
        if (title.contains(keyword) || description.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'Other News';
  }

  Future<bool> _isImageValid(String imageUrl) async {
    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode == 200 &&
             response.headers['content-type']?.startsWith('image/') == true;
    } catch (e) {
      return false;
    }
  }

  Future<String> _getValidImageUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty || imageUrl.startsWith('data:image')) {
      return defaultImage;
    }

    if (await _isImageValid(imageUrl)) {
      return imageUrl;
    }

    return defaultImage;
  }

  Future<void> fetchAllNews() async {
    final String apiKey = 'bb76d874b282d359358fdad4110607f9';
    
    try {
      final List<String> queries = [
        'Philippines food hunger',
        'Philippines disaster relief',
        'Philippines health crisis',
        'Philippines community aid poverty',
        'Philippines charity donation',
      ];

      List<Map<String, dynamic>> tempArticles = [];
      
      for (String query in queries) {
        final url = Uri.parse(
            'https://gnews.io/api/v4/search?q=$query&country=ph&lang=en&max=10&token=$apiKey');
        
        final response = await http.get(url);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final articles = data['articles'] as List;
          
          // Process each article to validate and fix image URLs
          for (var article in articles) {
            if (article is Map<String, dynamic>) {
              final processedArticle = {
                'title': article['title'] ?? 'No title',
                'description': article['description'] ?? 'No description',
                'url': article['url'] ?? '',
                'image': await _getValidImageUrl(article['image']),
                'category': determineCategory(
                  article['title'] ?? '', 
                  article['description'] ?? ''
                ),
              };
              tempArticles.add(processedArticle);
            }
          }
        }
      }

      // Remove duplicates based on URL
      final seen = Set<String>();
      tempArticles.removeWhere((article) {
        final url = article['url'] as String;
        return url.isEmpty || !seen.add(url);
      });

      if (mounted) {
        setState(() {
          allArticles = tempArticles;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching news: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> getFilteredArticles() {
    if (selectedFilter == 'All') {
      return allArticles;
    }
    return allArticles.where((article) => article['category'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = getFilteredArticles();
    final Set<String> categories = {'All', ...allArticles.map((article) => article['category'] as String)};
    
    return Scaffold(
      appBar: AppBar(
        title: Text('All Articles'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          if (widget.isRewardMode && !rewardClaimed)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep reading for 5 minutes to earn ${widget.rewardPoints} coins!',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Category chips with count
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(8),
            child: Row(
              children: categories.map((category) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: category,
                  count: category == 'All' 
                      ? allArticles.length 
                      : allArticles.where((a) => a['category'] == category).length,
                  selected: selectedFilter == category,
                  onSelected: (selected) {
                    setState(() => selectedFilter = category);
                  },
                ),
              )).toList(),
            ),
          ),
          
          // Articles list
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading articles...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredArticles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No articles found in this category',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = filteredArticles[index];
                          return _buildArticleCard(
                            article['title'] as String,
                            article['description'] as String,
                            article['image'] as String,
                            article['url'] as String,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String description, String imageUrl, String articleUrl) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    defaultImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReadMorePage(articleUrl: articleUrl),
                            ),
                          );
                        },
                        child: Text('Read More',
                            style: TextStyle(color: Colors.blue)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProcessPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Donate"),
                      ),
                    ],
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

class CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Function(bool) onSelected;

  const CategoryChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          SizedBox(width: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.green,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
    );
  }
} 