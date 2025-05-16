import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'profile_page.dart';
import 'Notification_page.dart';
import 'Donate_page.dart';
import 'request_page.dart';
import 'process_page.dart';
import 'readmore_page.dart';
import 'gamification_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'donationbreakdown.dart';
import 'gettoknowus.dart';
import 'view_all_articles.dart';

void main() {
  runApp(PantryPalApp());
}

class PantryPalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  double xPos = 20; // Initial X position
  double yPos = 100;
  bool showRewardIcon = true;
  Timer? rewardTimer;
  final String apiKey = '6fcadc69ffdb20610a2c118ab14c5f50';
  List<dynamic> articles = [];
  bool isLoading = true;
  bool hasError = false;

  final List<TabItem> items = [
    TabItem(icon: Icons.home, title: 'Home'),
    TabItem(icon: Icons.volunteer_activism, title: 'Donate'),
    TabItem(icon: Icons.request_page, title: 'Request'),
    TabItem(icon: Icons.notifications, title: 'Notification'),
    TabItem(icon: Icons.person, title: 'You'),
  ];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  void dispose() {
    rewardTimer?.cancel();
    super.dispose();
  }

  void _hideRewardIcon() {
    setState(() {
      showRewardIcon = false;
    });
    
    // Cancel existing timer if any
    rewardTimer?.cancel();
    
    // Timer to show them again after 1 minute
    rewardTimer = Timer(Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          showRewardIcon = true;
        });
      }
    });
  }

  Future<void> fetchNews() async {
    try {
      final query = 'food OR hunger OR health OR disaster';
      final url = Uri.parse(
          'https://gnews.io/api/v4/search?q=$query&country=ph&lang=en&max=10&token=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawArticles = data['articles'] ?? [];

        final filteredArticles = rawArticles.where((article) {
          final dateStr = article['publishedAt'] ?? '';
          if (dateStr.isEmpty) return false;

          final pubDate = DateTime.tryParse(dateStr);
          if (pubDate == null) return false;

          return pubDate.year >= 2024 && pubDate.year <= 2025;
        }).toList();

        setState(() {
          articles = filteredArticles.isNotEmpty ? filteredArticles : rawArticles;
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
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
        backgroundColor: Colors.green,
        title: const Text('PantryPal', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        // Removes the back arrow
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hey, World-Changer!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "With just ₱40.00 you can share a meal with someone in need.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Placeholder widgets for your sections
                FeaturedGoalsSection(),
                PowerToEndHungerSection(),
                InviteFriendsSection(),
                GetToKnowUsSection(),
                DonationBreakdownSection(),
                EmergencyAidSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Sticky Reward Icon (Hidden When X is Clicked)
          if (showRewardIcon)
            Positioned(
              left: xPos,
              top: yPos,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    xPos += details.delta.dx;
                    yPos += details.delta.dy;
                  });
                },
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Gamification Navigation (Rewards Icon)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GamificationPage()),
                        );
                      },
                      child: Image.asset(
                        'lib/images/coin.png', // Ensure the asset is added correctly
                        width: 80, // Adjust size as needed
                        height: 80,
                      ),
                    ),

                    // X Button (Closes Both Icons for 1 Minute)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: _hideRewardIcon,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: Colors.green,
        color: Colors.black,
        colorSelected: Colors.black,
        indexSelected: selectedIndex,
        onTap: (int index) {
          if (index == 1) {
            // Navigate to Donate Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DonationPage()),
            );
          } else if (index == 2) {
            // Navigate to Request Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RequestPage()),
            );
          } else if (index == 3) {
            // Navigate to Notification Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          } else if (index == 4) {
            // Navigate to Profile Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else {
            setState(() {
              selectedIndex = index;
            });
          }
        },
        chipStyle: const ChipStyle(
          convexBridge: true,
          background: Colors.white,
        ),
        itemStyle: ItemStyle.circle,
        titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        animated: true,
      ),
    );
  }
}

class FeaturedGoalsSection extends StatefulWidget {
  @override
  _FeaturedGoalsSectionState createState() => _FeaturedGoalsSectionState();
}

class _FeaturedGoalsSectionState extends State<FeaturedGoalsSection> {
  List<dynamic> articles = [];
  bool isLoading = true;
  bool hasError = false;
  final String apiKey = '6fcadc69ffdb20610a2c118ab14c5f50';

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final query = 'food OR hunger OR health OR disaster';
      final url = Uri.parse(
          'https://gnews.io/api/v4/search?q=$query&country=ph&lang=en&max=10&token=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawArticles = data['articles'] ?? [];

        final filteredArticles = rawArticles.where((article) {
          final dateStr = article['publishedAt'] ?? '';
          if (dateStr.isEmpty) return false;

          final pubDate = DateTime.tryParse(dateStr);
          if (pubDate == null) return false;

          return pubDate.year >= 2024 && pubDate.year <= 2025;
        }).toList();

        setState(() {
          articles = filteredArticles.isNotEmpty ? filteredArticles : rawArticles;
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FEATURED GOALS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewAllArticlesPage()),
                  );
                },
                child: Text("See all", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
              height: 350,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : hasError
                      ? Center(
                          child: Text(
                            "Failed to load news.",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            final articleUrl = article['url'] ?? '';
                            return _buildArticleCard(
                              article['title'] ?? 'No title',
                              article['description'] ?? 'No description',
                              article['image'] ?? 'https://via.placeholder.com/300x160.png?text=No+Image',
                              articleUrl,
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
      margin: EdgeInsets.only(right: 16),
      child: Container(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 160,
                  width: 300,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    SizedBox(height: 10),
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
            ),
          ],
        ),
      ),
    );
  }
}

class PowerToEndHungerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title placed above the card
          Text(
            "Together, we have the power to end hunger",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8), // Space between title and card

          Center(
            child: Container(
              width: 390, // Keeps width smaller
              height: 380, // Increased height of the box
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'lib/images/map.jpg',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20), // More space between map and stats

                      // Keeping stats inside to avoid stretching
                      Column(
                        children: [
                          StatItem(
                            title: "12,345,678 meals",
                            subtitle: "Meals Shared",
                            additionalText: "+8,000",
                            highlightColor: Colors.green,
                            timeLabel: "in the last day",
                          ),
                          StatItem(
                            title: "234,567 supporters",
                            subtitle: "Fighting Hunger",
                            additionalText: "+150",
                            highlightColor: Colors.green,
                            timeLabel: "in the last day",
                          ),
                          StatItem(
                            title: "25 goals",
                            subtitle: "Completed",
                            additionalText: "+2",
                            highlightColor: Colors.green,
                            timeLabel: "in the last 90 days",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String additionalText;
  final String timeLabel;
  final Color highlightColor;

  const StatItem({
    required this.title,
    required this.subtitle,
    required this.additionalText,
    required this.timeLabel,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                additionalText,
                style: TextStyle(
                    color: highlightColor, fontWeight: FontWeight.bold),
              ),
              Text(timeLabel,
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class InviteFriendsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Adds spacing
      child: Center(
        // Centers the box horizontally
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 120, // Adjust as needed
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Image.asset(
                'lib/images/invite your friends.png', // Update this path as needed
                width: 80, // Adjust image size
                height: 80,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10), // Add spacing

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Invite your friends",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "and fight hunger together",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {}, // Add invite function
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Invite"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GetToKnowUsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Left-align the title
        children: [
          Text(
            "Get To Know Us",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Center(
            // Centers the image and button
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 390,
                height: 370,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/images/get to know us.jpg',
                      fit: BoxFit.cover,
                      width: 370,
                      height: 370,
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20, // Ensures text wraps properly
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Follow how PantryPal delivers your donation",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22, // Adjust size as needed
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OverviewPage()),
                            );
                        },
                        child: Text("Read More"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Button background color
                          foregroundColor:
                              Colors.white, // Text color set to black
                          shape: RoundedRectangleBorder(
                            // Makes it a rectangle
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonationBreakdownSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DONATION BREAKDOWN",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Center(
            child: Container(
              width: 370, // Adjust width freely
              height: 150, // Adjust height freely
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center content
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center text vertically
                      children: [
                        Text(
                          "How is my donation used?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 17),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DonationBreakdownPage()),
                            );
                          },
                          child: Text("Learn More"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(33, 150, 243, 1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 100, // Adjust size freely
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('lib/images/donation.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmergencyAidSection extends StatefulWidget {
  @override
  _EmergencyAidSectionState createState() => _EmergencyAidSectionState();
}

class _EmergencyAidSectionState extends State<EmergencyAidSection> {
  int _currentIndex = 0;

  final List<String> images = [
    'lib/images/emergency aid.jpg',
    'lib/images/schoold feeding.jpg',
    'lib/images/nutrition support.jpg',
  ];

  final List<String> titles = [
    "Emergency Aid",
    "School Feeding",
    "Nutrition Support",
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double carouselHeight = screenHeight * 0.20; // 30% of screen height
    double carouselWidth = screenWidth * 0.83; // 90% of screen width

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: carouselWidth,
            height: carouselHeight,
            child: CarouselSlider(
              options: CarouselOptions(
                height: carouselHeight,
                autoPlay: true,
                viewportFraction: 1.0, // Show only one image fully
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: List.generate(images.length, (index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: carouselHeight,
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Text(
                          titles[index], // Dynamic text based on image index
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index ? Colors.orange : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
