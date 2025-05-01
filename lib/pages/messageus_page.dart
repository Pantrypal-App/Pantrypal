import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int selectedStars = 0;
  List<String> categories = [
    "Overall Service",
    "User Interface (UI)",
    "Features",
    "Data Protection",
    "Privacy Settings",
    "Additional Features"
  ];

  Set<String> selectedCategories = {};
  final TextEditingController feedbackController = TextEditingController();

  Future<void> submitFeedback() async {
    if (selectedStars == 0 && feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide a rating or feedback.")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must be logged in to submit feedback.")),
        );
        return;
      }

      // Get username from users collection
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final username = userDoc.data()?['username'] ?? 'Unknown';
      final email = user.email ?? 'No email';

      await FirebaseFirestore.instance.collection("feedbacks").add({
        "rating": selectedStars,
        "categories": selectedCategories.toList(),
        "feedback": feedbackController.text.trim(),
        "username": username,
        "email": email,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Thank you for your feedback!")),
      );

      setState(() {
        selectedStars = 0;
        selectedCategories.clear();
        feedbackController.clear();
      });
    } catch (e) {
      print("Error saving feedback: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit feedback.")),
      );
    }
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Feedback",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rate Your Experience",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Are you satisfied with the service?"),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedStars ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedStars = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            Text("Tell us what can be improved?"),
            Wrap(
              spacing: 8,
              children: categories.map((category) {
                return Chip(
                  label: Text(category),
                  backgroundColor: Colors.grey[300],
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tell us on how we can improve.",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(93, 0, 255, 68),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: submitFeedback,
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
