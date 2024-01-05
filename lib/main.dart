import 'package:eligtas_resident/page/Home.dart';
import 'package:eligtas_resident/page/login_page.dart';
import 'package:eligtas_resident/page/onboarding_page.dart';
import 'package:eligtas_resident/page/setup_profile.dart';
import 'package:eligtas_resident/page/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


int? isviewed;
String? uid = FirebaseAuth.instance.currentUser?.uid;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top], );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
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
            home:HomeScreen(uid: uid,),/*isviewed != 0 ? OnBoardingPage() : FutureBuilder
            (future: checkUserVerification(), builder: (context, snapshot){

       if (snapshot.hasError || snapshot.data == false) {
        // User is not logged in or email is not verified.
        return LoginPage();
        } else {
        // User is logged in and email is verified.
        return HomeScreen(uid: uid,);
     }
          })*/
          );
        }
    );
  }
}