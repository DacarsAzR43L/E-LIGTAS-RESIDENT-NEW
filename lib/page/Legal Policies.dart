import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LegalPolicies extends StatefulWidget {
  @override
  State<LegalPolicies> createState() => _LegalPoliciesState();
}

class _LegalPoliciesState extends State<LegalPolicies> {
  String legalPoliciesContent = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final legalPolicies = await fetchLegalPolicies('Legal Policies');

    // Process the fetched data as needed
    String content = '';
    for (var item in legalPolicies) {
      content += "${item['settings_description']} ";
    }

    // Update the state with the fetched content
    setState(() {
      legalPoliciesContent = content.trim();
    });
  }

  Future<List<Map<String, dynamic>>> fetchLegalPolicies(String settingsName) async {
    final apiUrl = 'http://192.168.100.185/e-ligtas-resident/get_about_us.php?settings_name=$settingsName';

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
        title: Text('Legal Policies'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legal Policies',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            legalPoliciesContent.isNotEmpty
                ? Text(
              legalPoliciesContent,
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
