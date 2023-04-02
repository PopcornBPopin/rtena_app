import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../SignUp/sign_page_1.dart';

class CivHomePage extends StatefulWidget {
  const CivHomePage({Key? key}) : super(key: key);

  @override
  State<CivHomePage> createState() => _CivHomePageState();
}

class _CivHomePageState extends State<CivHomePage> {
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
  bool _timerRunning = false;
  late StreamSubscription subscription;

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

  //Popup
  void quickAlert(QuickAlertType animtype, String title, String text, Color color) {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade200,
      context: context,
      type: animtype,
      title: title,
      text: text,
      confirmBtnColor: Colors.white,
      confirmBtnTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      onConfirmBtnTap: () {
        if (animtype == QuickAlertType.success)
          Get.to(
            () => const CivHomePage(),
            transition: Transition.fadeIn,
            duration: Duration(milliseconds: 300),
          );
        else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  void quickForgotAlert(QuickAlertType animtype, String title, String text, Color color) {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade200,
      context: context,
      type: animtype,
      title: title,
      text: text,
      confirmBtnColor: Colors.white,
      confirmBtnTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  static const maxSeconds = 6;
  int seconds = maxSeconds;
  Timer? timer;
  //Countdown timer
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() {
          _timerRunning = true;
          seconds--;
        });
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      seconds = maxSeconds;
      _timerRunning = false;
    });
  }

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
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              top: 30,
                              right: -10,
                              child: Opacity(
                                opacity: 0.15,
                                child: Container(
                                  child: Image.asset(
                                    'assets/RLOGO.png',
                                    scale: 2.5,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 60.h),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(Sign1Page());
                                      },
                                      child: Text(
                                        'Welcome Back!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 37.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    //Substring
                                    Text(
                                      'What kind of emergency are you involved in?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(height: 30.h),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        //Form Starts HERE
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                                      spreadRadius: 7,
                                      blurRadius: 10,
                                      offset: Offset(0, 0),
                                    )
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    SizedBox(height: 30.h),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          "Tap the button that corresponds to the emergency you are currently involved in.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    //Grid of buttons starts here
                                    //Fire and Health
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _timerRunning ? Color.fromRGBO(252, 58, 72, 32) : Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: _timerRunning ? Color.fromRGBO(252, 58, 72, 32) : Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            startTimer();
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Visibility(
                                                    visible: _timerRunning,
                                                    child: GestureDetector(
                                                      child: Container(
                                                        height: 100.h,
                                                        width: 165.w,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              '$seconds',
                                                              style: TextStyle(
                                                                fontSize: 30,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Tap to cancel",
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        print("STOP TIMER");
                                                        stopTimer();
                                                      },
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: !_timerRunning,
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          FontAwesomeIcons.fire,
                                                          color: Colors.red,
                                                          size: 35,
                                                        ),
                                                        SizedBox(height: 2.h),
                                                        Text(
                                                          "Fire",
                                                          style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.health_and_safety,
                                                    color: Colors.red,
                                                    size: 40,
                                                  ),
                                                  Text(
                                                    "Health",
                                                    style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20.h),

                                    //Murder and Assault
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.solidFaceDizzy,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    "Murder",
                                                    style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.handFist,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    "Assault",
                                                    style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),

                                    //Flood and Earthquake
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.water,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    "Flood",
                                                    style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.houseChimneyCrack,
                                                    color: Colors.red,
                                                    size: 33,
                                                  ),
                                                  SizedBox(height: 5.h),
                                                  Text(
                                                    "Earthquake",
                                                    style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20.h),

                                    //Kidnapping and Robbery
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.solidFaceSadCry,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    "Kidnapping",
                                                    style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: SizedBox(
                                            height: 100.h,
                                            width: 165.w,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.userNinja,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    "Robbery",
                                                    style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 30.h),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.keyboard_double_arrow_down,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(
                                                  "Don't know the emergency? Just press the 'Alert' button below",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {});
                                      },
                                      child: SizedBox(
                                        height: 100.h,
                                        width: 165.w,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.notifications_active,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                              Text(
                                                "Alert",
                                                style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 30.h),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
