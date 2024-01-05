

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:eligtas_resident/page/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Home.dart';

class SettingsPage extends StatelessWidget {

  //Firebase Auth
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;




  SettingsPage({required this.uid});


  Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();

    } catch (e) {
      print('Error signing out: $e');
      // Handle sign-out errors, if any.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                InkWell(
                  onTap: () {
                    // Handle Legal Policies click
                  },
                  child: ListTile(
                    title: Text(
                      'Legal Policies',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Your legal policies description goes here.',
                      style: TextStyle(fontSize: 16),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    // Handle About E-Ligtas click
                  },
                  child: ListTile(
                    title: Text(
                      'About E-Ligtas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Your about E-Ligtas description goes here.',
                      style: TextStyle(fontSize: 16),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                Divider(),
              ],
            ),
          ),
          Container(
            width: double.infinity, // Adjust the width as needed
            margin: EdgeInsets.fromLTRB(10, 8, 10, 16), // Adjust margin as needed
            child:TextButton(
              onPressed: () {

                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.rightSlide,
                  btnOkColor: Color.fromRGBO(51, 71, 246, 1),
                  title: "Confirm Sign Out",
                  desc: 'Are you sure you want to sign up?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    signOutUser();
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => LoginPage()), (
                            route) => false);
                  },
                  dismissOnTouchOutside: false,
                )..show();
              },
              child: Text('Sign Out',
                style: TextStyle(
                  fontFamily: 'Montserrat-Regular',
                  fontSize:24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Color.fromRGBO(51, 71, 246, 1)),
                  ),
                ),
                backgroundColor: MaterialStatePropertyAll<Color>(Color.fromRGBO(51, 71, 246, 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}