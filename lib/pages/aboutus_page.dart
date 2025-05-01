import 'package:flutter/material.dart';

void main() {
  runApp(PantryPalApp());
}

class PantryPalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryPal',
      home: AboutUsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'About us',
          style: TextStyle(fontSize: 18),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Welcome to PantryPal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'PantryPal connects people who care with communities in need.\n\n'
              'We make it easy to donate food, essentials, or funds to local pantries — all in one place. '
              'Whether you’re giving a little or a lot, every contribution helps stock shelves and support neighbors.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('lib/images/family.jpg'), // Replace with your image
            ),
            const SizedBox(height: 24),
            const Text(
              'Our Mission',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our mission is to make the act of giving as efficient and straightforward as possible, seamlessly connecting compassionate individuals with trusted local causes and food pantries. We aim to make a meaningful impact, one donation at a time.\n\n'
              'We’re driven by community, powered by compassion, and committed to creating a world where no one has to wonder where their next meal is coming from. With PantryPal, giving isn’t just easy — it’s meaningful, transparent, and part of something bigger.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'How We Work',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You browse. Find local pantries or causes that need support.\n\n'
              'You give. Donate food, funds, or essentials directly through our platform.\n\n'
              'We deliver joy. Your help goes straight to the shelves (and hearts) of those who need it most.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'Be part of something bigger.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Every small act of giving creates a ripple of change — helping fill shelves, feed families, and strengthen communities. Join PantryPal and make your impact today.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('lib/images/donation coin.jpg'), // Replace with your image
            ),
          ],
        ),
      ),
    );
  }
}
