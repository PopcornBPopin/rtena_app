import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rtena_app/Civilian/civilian_contacts_page.dart';
import 'package:rtena_app/Civilian/civilian_home_page.dart';
import 'package:rtena_app/Civilian/civilian_profile_page.dart';

class CivStartPage extends StatefulWidget {
  const CivStartPage({Key? key}) : super(key: key);

  @override
  State<CivStartPage> createState() => _CivStartPageState();
}

class _CivStartPageState extends State<CivStartPage> {
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

  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  bool _hasInternet = false;
  late StreamSubscription subscription;
  int _selectedIndex = 0;

  //Text Controllers

  //Snackbar
  final notConnectedSnackbar = SnackBar(
    content: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 25,
            color: Colors.white,
          ),
          Expanded(
            child: Center(
              child: Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: Colors.black,
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.fixed,
    elevation: 1,
  );

  final connectedSnackbar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_outlined,
          size: 25,
          color: Colors.green,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Connection Restored',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.black,
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.fixed,
    elevation: 1,
  );

  // FUNCTIONS
  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        _hasInternet = await InternetConnectionChecker().hasConnection;
        if (!_hasInternet) {
          print("No internet");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(notConnectedSnackbar);
        } else {
          print("Connected");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(connectedSnackbar);
        }
      },
    );
  }

  //All pages for Civilian Dashboard
  static final List<Widget> _NavScreens = <Widget>[
    CivHomePage(),
    CivContactsPage(),
    CivProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  icon: Icons.contact_emergency,
                  text: "Contacts",
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
    );
  }
}
