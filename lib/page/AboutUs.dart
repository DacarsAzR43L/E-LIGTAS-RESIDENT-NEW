import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  String aboutUsContent = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final aboutUsData = await fetchAboutUsData('About Us');

    // Process the fetched data as needed
    String content = '';
    for (var item in aboutUsData) {
      content += "${item['settings_description']} ";
    }

    // Update the state with the fetched content
    setState(() {
      aboutUsContent = content.trim();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAboutUsData(String settingsName) async {
    final apiUrl = 'https://eligtas.site/public/storage/get_about_us.php?settings_name=$settingsName';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        List<dynamic> data = json.decode(response.body);

        // Return the fetched data
        return List<Map<String, dynamic>>.from(data);
      } else {
        // Handle errors
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Handle network or other errors
      print("Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            aboutUsContent.isNotEmpty
                ? Text(
              aboutUsContent,
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
