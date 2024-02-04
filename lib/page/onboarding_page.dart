import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:eligtas_resident/page/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class OnBoardingPage extends StatefulWidget {


  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  _storeOnboardInfo() async {
    print("Shared pref called");
    int isViewed = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
    print(prefs.getInt('onBoard'));
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) => SafeArea(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: 'Disaster Guideline Procedures',
              body: 'Providing safety guidelines in every disasters.',
              image: buildImage('Assets/onboarding_images/info.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Emergency Hotlines',
              body: 'Available right at your fingerprints.' ,
              image: buildImage('Assets/onboarding_images/emergency-call.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'Emergency Queue Ticket',
              body: 'For rescue reservations options.',
              image: buildImage('Assets/onboarding_images/ticket.png'),
              decoration: getPageDecoration(),
            ),
          ],
          done: Text('Done',
              style: TextStyle(fontWeight: FontWeight.w600)),
          onDone: () async {
            await _storeOnboardInfo();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginPage()));
          },
          showSkipButton: true,
          skip: Text('Skip'),
          onSkip: () async{
            await _storeOnboardInfo();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginPage()));
          },
          next: Icon(Icons.arrow_forward),
          dotsDecorator: getDotDecoration(),
          onChange: (index) => print('Page $index selected'),
          skipOrBackFlex: 0,
          nextFlex: 0,
            controlsPadding: EdgeInsets.all(8.0),
            safeAreaList: [true,true,true,true],
            controlsMargin: EdgeInsets.symmetric(vertical: 1.0,horizontal: 10.0),
          // isProgressTap: false,
          // isProgress: false,
          // showNextButton: false,
          // freeze: true,
          // animationDuration: 1000,
        ),
      );

  Widget buildImage(String path) =>
      Center(child: Image.asset(path, width: 350));

  DotsDecorator getDotDecoration() => DotsDecorator(
        color: Color(0xFFBDBDBD),
        activeColor: Colors.lightBlueAccent,
        size: Size(10, 10),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );

  PageDecoration getPageDecoration() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 20),
        bodyPadding: EdgeInsets.all(16).copyWith(bottom: 0),
        imagePadding: EdgeInsets.fromLTRB(24.0,24.0,24.0,0),
        //boxDecoration: BoxDecoration(
          //image: DecorationImage(
      //image: new ExactAssetImage('Assets/splash.png'),
            //fit: BoxFit.cover,
          //),
        //),
    bodyAlignment: Alignment.topCenter,
    imageAlignment: Alignment.centerRight,
  );
}