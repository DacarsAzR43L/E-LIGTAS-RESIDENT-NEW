import 'package:eligtas_resident/page/Navigation_Pages/Request_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Report_Home extends StatefulWidget {
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  Report_Home({required this.uid});

  @override
  State<Report_Home> createState() => _Report_HomeState();
}

class _Report_HomeState extends State<Report_Home> {

  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            uid ?? 'No UID available',
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold
            ),
          ),

          SizedBox(height: 20.0,),

          ElevatedButton(
            onPressed: () {
              // Navigate to the second screen with the entered name
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Request_Page(uid: uid,),
                ),
              );
            },
            child: Text('Go to Second Screen'),
          ),
        ],
      ),
    );
  }
}
