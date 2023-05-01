import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rtena_app/Civilian/civilian_contacts_page.dart';
import 'package:rtena_app/Civilian/civilian_home_page.dart';
import 'package:rtena_app/Civilian/civilian_profile_page.dart';
import 'package:rtena_app/Civilian/civilian_settings_page.dart';
import 'package:rtena_app/Responder/responder_home_page.dart';
import 'package:rtena_app/Responder/responder_list_page.dart';
import 'package:rtena_app/Responder/responder_profile_page.dart';
import 'package:rtena_app/Responder/responder_settings_page.dart';

class ResStartPage extends StatefulWidget {
  const ResStartPage({Key? key}) : super(key: key);

  @override
  State<ResStartPage> createState() => _ResStartPageState();
}

class _ResStartPageState extends State<ResStartPage> {
  @override
  void initState() {
    getConnectivity();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitDown,
    // ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _hasInternet = false;
  late StreamSubscription subscription;
  int _selectedIndex = 0;

  //Text Controllers

  // FUNCTIONS
  ConnectivityResult result = ConnectivityResult.none;
  void getConnectivity() async {
    _hasInternet = await InternetConnectionChecker().hasConnection;
    if (result != ConnectivityResult.none) {
      setState(() {
        _hasInternet = true;
      });
    }
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        result = await Connectivity().checkConnectivity();
        _hasInternet = await InternetConnectionChecker().hasConnection;
        if (!_hasInternet) {
          print("No internet");
        } else {
          print("Connected");
        }
      },
    );
  }

  //All pages for Responder Dashboard
  static final List<Widget> _NavScreens = <Widget>[
    ResHomePage(),
    ResListPage(),
    ResProfilePage(),
    ResSettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(252, 58, 72, 1),
              Color.fromRGBO(70, 18, 32, 1),
            ],
          ),
        ),
        child: Scaffold(
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: GNav(
                haptic: true,
                backgroundColor: Colors.white,
                tabBackgroundColor: Colors.white,
                tabActiveBorder: Border.all(color: Colors.grey.shade700),
                tabBorderRadius: 30,
                padding: EdgeInsets.all(12),
                duration: Duration(milliseconds: 300),
                gap: 10,
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: "Home",
                  ),
                  GButton(
                    icon: Icons.more_horiz,
                    text: "List",
                  ),
                  GButton(
                    icon: Icons.person_pin_rounded,
                    text: "Profile",
                  ),
                  GButton(
                    icon: Icons.settings,
                    text: "Settings",
                  )
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: _NavScreens.elementAt(_selectedIndex),
          ),
        ),
      ),
    );
  }
}
