import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rtena_app/Civilian/civilian_start_page.dart';

class CivContactsPage extends StatefulWidget {
  const CivContactsPage({Key? key}) : super(key: key);

  @override
  State<CivContactsPage> createState() => _CivContactsPageState();
}

class _CivContactsPageState extends State<CivContactsPage> {
  void initState() {
    getConnectivity();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  bool _hasInternet = false;
  late StreamSubscription subscription;

  // FUNCTIONS
  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        _hasInternet = await InternetConnectionChecker().hasConnection;
        if (!_hasInternet) {
          print("No internet");
        } else {
          print("Connected");
        }
      },
    );
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
                                    SizedBox(height: 75.h),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(CivStartPage());
                                      },
                                      child: Text(
                                        'Emergency Contacts',
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
                                      'Who do you want to call?',
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
                                          'Test',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
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
