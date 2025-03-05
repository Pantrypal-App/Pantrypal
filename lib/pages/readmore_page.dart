import 'package:flutter/material.dart';
import 'process_page.dart';

class ReadMorePage extends StatelessWidget {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset('lib/images/typhon.jpg',
                    width: double.infinity, height: 200, fit: BoxFit.cover),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    'Feed Families in Typhoon-Affected Areas',
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
                  Text('OVERVIEW',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text(
                    'Shared meals will provide emergency food, nutrition support, school meals, and resilience activities in the Philippines.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Typhoon Yolanda, internationally known as Haiyan, was one of the strongest and deadliest typhoons recorded in history...',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {},
                    child:
                        Text('Read More', style: TextStyle(color: Colors.blue)),
                  ),
                  SizedBox(height: 16),
                  Text('IMAGE GALLERY',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Image.asset('lib/images/yolanda.jpg',
                      width: double.infinity, height: 200, fit: BoxFit.cover),
                  SizedBox(height: 16),
                  Text('Updates',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  _buildUpdateCard('September 9 2013',
                      'A total of 803,281 families from Palawan, Panay, Northern Cebu, and Samar Leyte municipalities have received their assistance out of the 966,341 target families. This is approximately 83% completed.'),
                  SizedBox(height: 8),
                  _buildUpdateCard('September 14 2013',
                      'DSWD has already disbursed 84% of the donations it has received. The amount went to transitional shelter programs, cash for work, ready-to-eat food items and medicines, and other expenses.'),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProcessPage()),
                        );
                      },
                      child: Text(
                        'Donate Now',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
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

  Widget _buildUpdateCard(String date, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(description, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
