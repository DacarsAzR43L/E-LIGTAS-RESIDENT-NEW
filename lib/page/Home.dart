import 'package:eligtas_resident/page/Profile.dart';
import 'package:eligtas_resident/page/Settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:eligtas_resident/page/login_page.dart';
import 'package:eligtas_resident/page/Navigation_Pages/Guidelines_Page.dart';
import 'package:eligtas_resident/page/Navigation_Pages/Hotlines_Page.dart';
import 'package:eligtas_resident/page/Navigation_Pages/Request_Page.dart';
import 'package:eligtas_resident/page/Navigation_Pages/Report_Home.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


class HomeScreen extends StatefulWidget {


  //Firebase Auth
  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;




  HomeScreen({required this.uid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}





class _HomeScreenState extends State<HomeScreen>  with AutomaticKeepAliveClientMixin {

  final auth = FirebaseAuth.instance;
  User? user;
  String? uid = FirebaseAuth.instance.currentUser?.uid;


  //Navigation Index
  var _selectedPageIndex;
  late List<Widget> _pages;
  late PageController _pageController;



  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _selectedPageIndex = 1;
    _pages = [
      GuidelinesPage(),
      Request_Page(uid: uid),
      Hotlines_Page(),
    ];
    _pageController = PageController(initialPage: _selectedPageIndex);
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



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.white,
        elevation: 4,
        toolbarHeight:60.0,
        shadowColor: Colors.black,
        title: Text('E-LIGTAS',
            style:TextStyle(
                fontFamily: "Montserrat-Bold",
                fontWeight: FontWeight.bold,
                fontSize: 24)
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(uid: uid)));
              print('Babawi ako para sa atin <3 Nandito ako palagi to wait for youu until you are okay <3');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage(uid: uid)));
              print('Settings icon pressed');
            },
          ),
        ],
      ),

      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedPageIndex,
        onTap: (selectedPageIndex) {
          setState(() {
            _selectedPageIndex = selectedPageIndex;
            _pageController.jumpToPage(selectedPageIndex);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Guidelines',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions_outlined),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_in_talk),
            label: 'Hotlines',
          ),
        ],
        selectedItemColor: Colors.blue, // Set the color for the selected item
        unselectedItemColor: Colors.grey, // Set the color for unselected items
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;




}











