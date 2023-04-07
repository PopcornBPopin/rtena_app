import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rtena_app/SignUp/sign_page_1.dart';

class CivHomePage extends StatefulWidget {
  const CivHomePage({Key? key}) : super(key: key);

  @override
  State<CivHomePage> createState() => _CivHomePageState();
}

class _CivHomePageState extends State<CivHomePage> {
  @override
  void initState() {
    getConnectivity();
    getUserData();
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
    subscription.cancel();
    timer?.cancel();
  }

  bool _hasInternet = false;
  bool _timerRunning = false;
  bool _emergencySelected = false;
  bool _fireEmergencySelected = false;
  bool _healthEmergencySelected = false;
  bool _murderEmergencySelected = false;
  bool _assaultEmergencySelected = false;
  bool _floodEmergencySelected = false;
  bool _equakeEmergencySelected = false;
  bool _kidnapEmergencySelected = false;
  bool _robberyEmergencySelected = false;
  bool _alertEmergencySelected = false;

  late StreamSubscription subscription;
  late String _firstName = "";
  late String _emailAddress = "";
  late String _latitude = "";
  late String _longitude = "";

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
          setState(() {
            _hasInternet = false;
          });
        } else {
          setState(() {
            _hasInternet = true;
          });
        }
      },
    );
  }

  //Grab user document from Firebase Firestone
  void getUserData() async {
    print(_emailAddress);
    User? user = FirebaseAuth.instance.currentUser;
    _emailAddress = user!.email!;
  }

  //Popup
  void quickAlert(QuickAlertType animtype, String title, String text, Color color) {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade200,
      context: context,
      barrierDismissible: false,
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

  static const maxSeconds = 5;
  int seconds = maxSeconds;
  Timer? timer;
  //Countdown timer
  void startTimer(String emergencyType, String latitude, String longitude) {
    setState(() {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (seconds > 0) {
          setState(() {
            _timerRunning = true;
            --seconds;
          });
        } else {
          timer?.cancel();
          SendEmergency(emergencyType, 'Ongoing', latitude, longitude);
          stopTimer();
        }
      });
    });
  }

  void stopTimer() {
    setState(() {
      timer?.cancel();
      _timerRunning = false;
      _emergencySelected = false;
      _fireEmergencySelected = false;
      _healthEmergencySelected = false;
      _murderEmergencySelected = false;
      _assaultEmergencySelected = false;
      _floodEmergencySelected = false;
      _equakeEmergencySelected = false;
      _kidnapEmergencySelected = false;
      _robberyEmergencySelected = false;
      _alertEmergencySelected = false;
      seconds = maxSeconds;
    });
  }

  //Writing emergency deets to Firestone DB
  Future sendEmergencyDetails(
    String type,
    String status,
    String latitude,
    String longitude,
  ) async {
    await FirebaseFirestore.instance.collection('emergencies').doc(_emailAddress.toLowerCase()).set({
      'Type': type,
      'Status': status,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future SendEmergency(String type, String status, String latitude, String longitude) async {
    sendEmergencyDetails(
      type,
      status,
      latitude,
      longitude,
    );
    print("Added emergency deets to firestone");
    quickAlert(QuickAlertType.loading, "Emergency Selected!", "Waiting for confirmation of the responders near you. Please hang tight", Colors.green);

    var collection = FirebaseFirestore.instance.collection('emergencies');
    var docReference = collection.doc(_emailAddress);

    docReference.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var status = data?['Status'];
        if (status == 'Confirmed') {
          Navigator.of(context).pop();
          quickAlert(QuickAlertType.success, "Alert Acknowledged!", "Responders are on their way. Godspeed!", Colors.green);
        }
      }
    });
  }

  //Get the user location
  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        quickAlert(QuickAlertType.error, "Pemission Denied!", "Location permissions are denied", Colors.green);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      quickAlert(QuickAlertType.error, "Pemission Denied!", "Location permissions are permanently denied, we cannot request permissions", Colors.green);
    }
    return await Geolocator.getCurrentPosition();
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
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance.collection('users').doc(_emailAddress).snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text(
                                            'Hello!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 37.sp,
                                            ),
                                          );
                                        }
                                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                                        _firstName = userData['First Name'];
                                        return Text(
                                          'Hello! $_firstName',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 37.sp,
                                          ),
                                        );
                                      },
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
                                    SizedBox(height: 15.h),
                                    // Text("Timer: " + _timerRunning.toString()),
                                    // Text("Switch: " + _emergencySelected.toString()),
                                    // Text("Fire: " + _fireEmergencySelected.toString()),
                                    // Text("Health: " + _healthEmergencySelected.toString()),
                                    // Text("Murder: " + _murderEmergencySelected.toString()),
                                    // Text("Assault: " + _assaultEmergencySelected.toString()),
                                    // Text("Flood: " + _floodEmergencySelected.toString()),
                                    // Text("Equake: " + _equakeEmergencySelected.toString()),
                                    // Text("Kidd: " + _kidnapEmergencySelected.toString()),
                                    // Text("Rob: " + _robberyEmergencySelected.toString()),
                                    //Grid of buttons starts here
                                    //Fire and Health
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity: _timerRunning && !_fireEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _fireEmergencySelected ? const Color.fromRGBO(102, 0, 0, 1) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _fireEmergencySelected ? const Color.fromRGBO(102, 0, 0, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_fireEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                setState(() {
                                                  _fireEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                getCurrentLocation().then((value) {
                                                  _latitude = '${value.latitude}';
                                                  _longitude = '${value.longitude}';
                                                });
                                                startTimer("Fire Emergency", _latitude, _longitude);
                                              }
                                              if (_timerRunning && _fireEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _fireEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_fireEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons.fire,
                                                            color: const Color.fromRGBO(102, 0, 0, 1),
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
                                        ),
                                        SizedBox(width: 10.w),
                                        Opacity(
                                          opacity: _timerRunning && !_healthEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _healthEmergencySelected ? const Color.fromRGBO(153, 0, 51, 1) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _healthEmergencySelected ? const Color.fromRGBO(153, 0, 51, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_healthEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                print("Pressed");
                                                setState(() {
                                                  _healthEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                // startTimer("Health Emergency");
                                              }
                                              if (_timerRunning && _healthEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _healthEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_healthEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.health_and_safety,
                                                            color: const Color.fromRGBO(153, 0, 51, 1),
                                                            size: 40,
                                                          ),
                                                          Text(
                                                            "Health",
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
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 15.h),

                                    //Murder and Assault
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity: _timerRunning && !_murderEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _murderEmergencySelected ? const Color.fromARGB(223, 177, 28, 38) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _murderEmergencySelected ? const Color.fromARGB(223, 177, 28, 38) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_murderEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                print("Pressed");
                                                setState(() {
                                                  _murderEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                // startTimer("Murder Emergency");
                                              }
                                              if (_timerRunning && _murderEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _murderEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_murderEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons.solidFaceDizzy,
                                                            color: const Color.fromARGB(223, 177, 28, 38),
                                                            size: 35,
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            "Murder",
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
                                        ),
                                        SizedBox(width: 10.w),
                                        Opacity(
                                          opacity: _timerRunning && !_assaultEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _assaultEmergencySelected ? const Color.fromARGB(255, 163, 49, 70) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _assaultEmergencySelected ? const Color.fromRGBO(184, 58, 67, 0.878) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_assaultEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                print("Pressed");
                                                setState(() {
                                                  _assaultEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                // startTimer("Assault Emergency");
                                              }
                                              if (_timerRunning && _assaultEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _assaultEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_assaultEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons.handFist,
                                                            color: const Color.fromRGBO(184, 58, 67, 0.878),
                                                            size: 35,
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            "Assault",
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
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15.h),

                                    //Flood and Earthquake
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity: _timerRunning && !_floodEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _floodEmergencySelected ? const Color.fromRGBO(255, 144, 0, 1) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _floodEmergencySelected ? const Color.fromRGBO(255, 144, 0, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_floodEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                print("Pressed");
                                                setState(() {
                                                  _floodEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                // startTimer("Flood Emergency");
                                              }
                                              if (_timerRunning && _floodEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _floodEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_floodEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons.water,
                                                            color: const Color.fromRGBO(255, 144, 0, 1),
                                                            size: 35,
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            "Flood",
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
                                        ),
                                        SizedBox(width: 10.w),
                                        Opacity(
                                          opacity: _timerRunning && !_equakeEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _equakeEmergencySelected ? Color.fromARGB(255, 255, 102, 0) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _equakeEmergencySelected ? Color.fromARGB(255, 255, 102, 0) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_equakeEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                print("Pressed");
                                                setState(() {
                                                  _equakeEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                // startTimer("Earthquake Emergency");
                                              }
                                              if (_timerRunning && _equakeEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _equakeEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_equakeEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons.houseChimneyCrack,
                                                            color: Color.fromARGB(255, 255, 102, 0),
                                                            size: 35,
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            "Earthquake",
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
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15.h),

                                    //Kidnapping and Robbery
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity: _timerRunning && !_kidnapEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _kidnapEmergencySelected ? const Color.fromRGBO(157, 2, 8, 1) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _kidnapEmergencySelected ? const Color.fromRGBO(157, 2, 8, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_kidnapEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                print("Pressed");
                                                setState(() {
                                                  _kidnapEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                // startTimer("Kidnap Emergency");
                                              }
                                              if (_timerRunning && _kidnapEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _kidnapEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_kidnapEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons.solidFaceSadCry,
                                                            color: const Color.fromRGBO(157, 2, 8, 1),
                                                            size: 35,
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            "Kidnapping",
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
                                        ),
                                        SizedBox(width: 10.w),
                                        Opacity(
                                          opacity: _timerRunning && !_robberyEmergencySelected ? 0.6 : 1,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _robberyEmergencySelected ? const Color.fromRGBO(220, 47, 2, 1) : Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: _robberyEmergencySelected ? const Color.fromRGBO(220, 47, 2, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: _timerRunning && !_robberyEmergencySelected ? 1 : 3,
                                            ),
                                            onPressed: () {
                                              if (!_timerRunning && !_emergencySelected) {
                                                print("Pressed");
                                                setState(() {
                                                  _robberyEmergencySelected = true;
                                                  _emergencySelected = true;
                                                });
                                                // startTimer("Robbery Emergency");
                                              }
                                              if (_timerRunning && _robberyEmergencySelected) {
                                                setState(() {
                                                  stopTimer();
                                                });
                                              }
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
                                                      visible: _robberyEmergencySelected,
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
                                                    Visibility(
                                                      visible: !_robberyEmergencySelected,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons.userNinja,
                                                            color: const Color.fromRGBO(220, 47, 2, 1),
                                                            size: 35,
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Text(
                                                            "Robbery",
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
                                    SizedBox(height: 15.h),

                                    Opacity(
                                      opacity: _timerRunning && !_alertEmergencySelected ? 0.6 : 1,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _alertEmergencySelected ? const Color.fromARGB(255, 202, 68, 27) : Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            side: BorderSide(
                                              color: _alertEmergencySelected ? const Color.fromARGB(255, 202, 68, 27) : Color.fromRGBO(82, 82, 82, 1),
                                              width: 1,
                                            ),
                                          ),
                                          elevation: _timerRunning && !_alertEmergencySelected ? 1 : 3,
                                        ),
                                        onPressed: () {
                                          if (!_timerRunning && !_emergencySelected) {
                                            print("Pressed");
                                            setState(() {
                                              _alertEmergencySelected = true;
                                              _emergencySelected = true;
                                            });
                                            // startTimer("Alert Emergency");
                                          }
                                          if (_timerRunning && _alertEmergencySelected) {
                                            setState(() {
                                              stopTimer();
                                            });
                                          }
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
                                                  visible: _alertEmergencySelected,
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
                                                Visibility(
                                                  visible: !_alertEmergencySelected,
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.notifications_active,
                                                        color: const Color.fromARGB(255, 202, 68, 27),
                                                        size: 40,
                                                      ),
                                                      Text(
                                                        "Alert",
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
                                    ),
                                    SizedBox(height: 50.h),
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
