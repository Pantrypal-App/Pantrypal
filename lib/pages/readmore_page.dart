import 'process_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' show Document;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ReadMorePage extends StatefulWidget {
  final String articleUrl;
  final bool isRewardMode;
  final int? rewardPoints;
  final String? taskKey;
  final String? category;
  final Function? onReadTimeUpdate;

  ReadMorePage({
    required this.articleUrl,
    this.isRewardMode = false,
    this.rewardPoints,
    this.taskKey,
    this.category,
    this.onReadTimeUpdate,
  });

  @override
  _ReadMorePageState createState() => _ReadMorePageState();
}

class _ReadMorePageState extends State<ReadMorePage> with WidgetsBindingObserver {
  String articleContent = '';
  String articleImage = '';
  String articleTitle = '';
  String articleDescription = '';
  bool isLoading = true;
  bool hasError = false;
  bool rewardClaimed = false;
  bool isImageLoading = true;

  static const String defaultImage = 'https://media.licdn.com/dms/image/v2/D5612AQEvNyNDzsTosA/article-cover_image-shrink_720_1280/B56ZYLonVPH0AI-/0/1743951919345?e=2147483647&v=beta&t=bFYrq44qSgoyOHr4H_xXw31N_JkVNrL5Emd7zjUNEOk';

  // Reading time tracking
  DateTime? startReadingTime;
  DateTime? lastActiveTime;
  Duration totalReadingTime = Duration.zero;
  bool isUserActive = true;
  Timer? inactivityTimer;
  Timer? saveTimer;

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
    WidgetsBinding.instance.addObserver(this);
    fetchArticle();
    _initializeReadingTracking();
    _startInactivityTimer();
    _startPeriodicSave();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    inactivityTimer?.cancel();
    saveTimer?.cancel();
    _saveReadingProgress();
    super.dispose();
  }

  void _startInactivityTimer() {
    inactivityTimer?.cancel();
    inactivityTimer = Timer(const Duration(minutes: 2), () {
      if (mounted) {
        setState(() {
          isUserActive = false;
          _pauseReading();
        });
      }
    });
  }

  void _startPeriodicSave() {
    saveTimer?.cancel();
    saveTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (isUserActive) {
        _saveReadingProgress();
      }
    });
  }

  void _resetInactivityTimer() {
    setState(() {
      isUserActive = true;
    });
    _startInactivityTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseReading();
    } else if (state == AppLifecycleState.resumed) {
      _resumeReading();
    }
  }

  void _initializeReadingTracking() async {
    startReadingTime = DateTime.now();
    lastActiveTime = startReadingTime;

    // Load previous reading time if exists
    if (widget.taskKey != null) {
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getInt('${widget.taskKey}_time') ?? 0;
      totalReadingTime = Duration(seconds: savedTime);
      rewardClaimed = prefs.getBool('${widget.taskKey}_completed') ?? false;
    }
  }

  void _pauseReading() {
    if (startReadingTime != null && isUserActive) {
      final sessionTime = DateTime.now().difference(startReadingTime!);
      totalReadingTime += sessionTime;
      _saveReadingProgress();
      startReadingTime = null;
    }
  }

  void _resumeReading() {
    startReadingTime = DateTime.now();
    lastActiveTime = startReadingTime;
    _resetInactivityTimer();
  }

  Future<void> _saveReadingProgress() async {
    if (!isUserActive || widget.taskKey == null) return;

    final currentSession = startReadingTime != null 
        ? DateTime.now().difference(startReadingTime!)
        : Duration.zero;
    final totalTime = totalReadingTime + currentSession;

    // Save progress
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${widget.taskKey}_time', totalTime.inSeconds);

    // Update parent if callback exists
    widget.onReadTimeUpdate?.call(totalTime);

    // Check for task completion
    if (widget.isRewardMode && !rewardClaimed && totalTime.inMinutes >= 5) {
      await _claimReward();
    }

    // Category-specific tracking
    if (widget.category != null) {
      final categoryTime = prefs.getInt('${widget.category}_read_time') ?? 0;
      await prefs.setInt('${widget.category}_read_time', categoryTime + currentSession.inSeconds);
    }
  }

  Future<void> _claimReward() async {
    if (rewardClaimed || widget.rewardPoints == null || widget.taskKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt('coinBalance') ?? 0;
    await prefs.setInt('coinBalance', currentCoins + widget.rewardPoints!);
    await prefs.setBool('${widget.taskKey}_completed', true);
    setState(() {
      rewardClaimed = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Congratulations! You\'ve earned ${widget.rewardPoints} coins!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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

  Future<String> _findValidImage(dynamic document) async {
    // Try meta og:image first
    final ogImage = document.querySelector('meta[property="og:image"]')?.attributes['content'];
    if (ogImage != null && await _isImageValid(ogImage)) {
      return ogImage;
    }

    // Try meta twitter:image
    final twitterImage = document.querySelector('meta[name="twitter:image"]')?.attributes['content'];
    if (twitterImage != null && await _isImageValid(twitterImage)) {
      return twitterImage;
    }

    // Try first article image
    final articleImage = document.querySelector('article img')?.attributes['src'];
    if (articleImage != null && await _isImageValid(articleImage)) {
      return articleImage;
    }

    // Try any image in the content
    final images = document.querySelectorAll('img');
    for (var img in images) {
      final src = img.attributes['src'];
      if (src != null && src.startsWith('http') && await _isImageValid(src)) {
        return src;
      }
    }

    // Return default image if no valid image found
    return defaultImage;
  }

  Future<void> fetchArticle() async {
    try {
      final response = await http.get(Uri.parse(widget.articleUrl));

      if (response.statusCode == 200) {
        var document = html.parse(response.body);

        String title = document.querySelector('title')?.text ?? 'No title available';
        String description = document
                .querySelector('meta[name="description"]')
                ?.attributes['content'] ??
            document.querySelector('meta[property="og:description"]')?.attributes['content'] ??
            'No description available';

        // Find a valid image
        String image = await _findValidImage(document);

        String content = '';
        var paragraphs = document.querySelectorAll('p');

        for (var p in paragraphs) {
          String text = p.text.trim();
          bool isClean = !blacklistKeywords.any((phrase) => text.toLowerCase().contains(phrase));
          if (isClean && text.isNotEmpty) {
            content += text + "\n\n";
          }
        }

        if (mounted) {
          setState(() {
            articleTitle = title;
            articleImage = image;
            articleDescription = description;
            articleContent = content;
            isLoading = false;
            isImageLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load article');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
          isImageLoading = false;
          articleImage = defaultImage;
        });
      }
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSession = startReadingTime != null && isUserActive
        ? DateTime.now().difference(startReadingTime!)
        : Duration.zero;
    final totalTime = totalReadingTime + currentSession;

    return GestureDetector(
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      onVerticalDragUpdate: (_) => _resetInactivityTimer(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (widget.isRewardMode)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Reading time: ${totalTime.inMinutes}m ${totalTime.inSeconds % 60}s',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isRewardMode && !rewardClaimed && totalTime.inMinutes < 5)
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.orange.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Keep reading! ${5 - totalTime.inMinutes} minutes left to earn ${widget.rewardPoints} coins',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            Container(
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
          ],
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            articleImage,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                defaultImage,
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
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
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
      ),
    );
  }
}
