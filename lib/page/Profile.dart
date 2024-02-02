import 'package:eligtas_resident/page/Edit_Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  ProfileScreen({required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userInfo = {};
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Fetch image data when the widget is initialized
    fetchData();
  }

  Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      // User is signed out.
    } catch (e) {
      print('Error signing out: $e');
      // Handle sign-out errors, if any.
    }
  }

  // Function to fetch image data
  Future<void> fetchData() async {
    try {
      // Replace "http://your-server/retrieve_image.php" with your actual server URL
      var response = await http.get(Uri.parse("https://eligtas.site/public/storage/get_profile_info.php?uid=${widget.uid}"));

      if (response.statusCode == 200) {
        setState(() {
          userInfo = json.decode(response.body);
        });
      }
    } catch (error) {
      print('Error fetching image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 1.5;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 4.0,
        toolbarHeight: 60.0,
        shadowColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(1.h, 4.h, 1.h, 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 90.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: userInfo.containsKey('image') && userInfo['image'] != null
                      ? Image.memory(base64Decode(userInfo['image']!)).image
                      : AssetImage('Assets/appIcon.png'), // Placeholder image
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Edit_ProfileScreen(uid: uid)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(51, 71, 246, 1),
                    padding: EdgeInsets.all(16.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text('Edit Profile', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.0),
            Padding(
              padding: EdgeInsets.fromLTRB(1.h, 2.h, 1.h, 0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Details',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat-Bold",
                    ),
                  ),
                  SizedBox(height: 5.0),
                  buildDetailRow('Name:', '${userInfo['name'] ?? 'Not Available'}'),
                  buildDetailRow('Address:', '${userInfo['address'] ?? 'Not Available'}'),
                  buildDetailRow('Phone Number:', '+${userInfo['phoneNumber'] ?? 'Not Available'}'),
                  //buildDetailRow('UID:', uid ?? 'No UID available'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.0),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(text: '$label\n'),
              TextSpan(text: value, style: TextStyle(fontWeight: FontWeight.normal)),
            ],
          ),
        ),
      ],
    );
  }
}
