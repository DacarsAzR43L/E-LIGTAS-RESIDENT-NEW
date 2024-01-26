
import 'package:eligtas_resident/CustomDialog/GalleryErrorDialog.dart';
import 'package:eligtas_resident/CustomDialog/LoginSuccessDialog.dart';
import 'package:eligtas_resident/CustomDialog/RegisterSucessDialog.dart';
import 'package:eligtas_resident/CustomDialog/RequestSuccessDialog.dart';
import 'package:eligtas_resident/CustomDialog/SetUpSuccessDialog.dart';
import 'package:eligtas_resident/page/Edit_Profile.dart';
import 'package:eligtas_resident/page/History.dart';
import 'package:eligtas_resident/page/Home.dart';
import 'package:eligtas_resident/page/Navigation_Pages/Request_Page.dart';
import 'package:eligtas_resident/page/Profile.dart';
import 'package:eligtas_resident/page/Settings.dart';
import 'package:eligtas_resident/page/login_page.dart';
import 'package:eligtas_resident/page/onboarding_page.dart';
import 'package:eligtas_resident/page/setup_profile.dart';
import 'package:eligtas_resident/page/sign_up.dart';
import 'package:eligtas_resident/page/verify_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


int? isviewed;
bool? isLoggedIn;
String? uid = FirebaseAuth.instance.currentUser?.uid;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top], );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
  isLoggedIn = prefs.getBool('isLoggedin');

  print(isviewed);
  runApp(MyApp());
}

Future<bool?> checkUserVerification() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    await user.reload(); // Reload user data to get the latest emailVerified status.
    user = auth.currentUser; // Refresh the user object after reloading.

    return user?.emailVerified;
  } else {
    return false;
  }
}



class MyApp extends StatelessWidget {
  String? uid = FirebaseAuth.instance.currentUser?.uid;



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Title',
            theme: ThemeData(primarySwatch: Colors.blue),
              home: isviewed != 0 ? OnBoardingPage() : isLoggedIn ==true ? HomeScreen(uid: uid) : FutureBuilder(
                  future: checkUserVerification(), builder: (context, snapshot){

    if (snapshot.hasError || snapshot.data == false) {
    // User is not logged in or email is not verified.
    return LoginPage();
    } else {
    // User is logged in and email is verified.
    return HomeScreen(uid: uid,);
    }})
          );
        }
    );
  }
}