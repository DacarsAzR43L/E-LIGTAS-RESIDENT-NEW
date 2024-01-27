import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DetailsPage extends StatefulWidget {
  final String id;
  final String name;

  DetailsPage({required this.id, required this.name});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<List<Map<String, dynamic>>> beforeData;
  late Future<List<Map<String, dynamic>>> duringData;
  late Future<List<Map<String, dynamic>>> afterData;

  @override
  void initState() {
    super.initState();
    beforeData = fetchGuidelinesData(widget.id, 'Before');
    duringData = fetchGuidelinesData(widget.id, 'During');
    afterData = fetchGuidelinesData(widget.id, 'After');
  }

  Future<List<Map<String, dynamic>>> fetchGuidelinesData(String guidelinesId, String section) async {
    final apiUrl = 'http://192.168.100.7/e-ligtas-resident/get_${section}_guidelines.php?guidelines_id=$guidelinesId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
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
        title: Text(widget.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Before
              FutureBuilder(
                future: beforeData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Placeholder for 'Before' section
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    List<Map<String, dynamic>> data = snapshot.data as List<Map<String, dynamic>>;
                    if (data.isNotEmpty) {
                      return SectionWidget(
                        heading: 'Before',
                        guidelinesId: widget.id,
                        imageData: base64Decode(data[0]['image']),
                        sampleText: data[0]['description'],
                      );
                    } else {
                      return Text("No data available for 'Before' section");
                    }
                  }
                },
              ),
              SizedBox(height: 20),

              // During
              FutureBuilder(
                future: duringData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Placeholder for 'During' section
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    List<Map<String, dynamic>> data = snapshot.data as List<Map<String, dynamic>>;
                    if (data.isNotEmpty) {
                      return SectionWidget(
                        heading: 'During',
                        guidelinesId: widget.id,
                        imageData: base64Decode(data[0]['image']),
                        sampleText: data[0]['description'],
                      );
                    } else {
                      return Text("No data available for 'During' section");
                    }
                  }
                },
              ),
              SizedBox(height: 20),

              // After
              FutureBuilder(
                future: afterData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Placeholder for 'After' section
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    List<Map<String, dynamic>> data = snapshot.data as List<Map<String, dynamic>>;
                    if (data.isNotEmpty) {
                      return SectionWidget(
                        heading: 'After',
                        guidelinesId: widget.id,
                        imageData: base64Decode(data[0]['image']),
                        sampleText: data[0]['description'],
                      );
                    } else {
                      return Text("No data available for 'After' section");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String heading;
  final String guidelinesId;
  final Uint8List? imageData;
  final String sampleText;

  SectionWidget({
    required this.heading,
    required this.guidelinesId,
    required this.imageData,
    required this.sampleText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.sp),
        Center(
          child: imageData != null
              ? Image.memory(
            imageData!,
            width: 500.sp, // Adjust the width as needed
            height: 150.sp, // Adjust the height as needed
            fit: BoxFit.contain,
          )
              : Container(), // Placeholder for the image
        ),
        SizedBox(height: 10.sp),
        Text(
          sampleText,
          style: TextStyle(fontSize: 16.sp),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 20.sp),
      ],
    );
  }
}
