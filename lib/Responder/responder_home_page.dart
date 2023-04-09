import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResHomePage extends StatefulWidget {
  const ResHomePage({Key? key}) : super(key: key);

  @override
  State<ResHomePage> createState() => _ResHomePageState();
}

class _ResHomePageState extends State<ResHomePage> {
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
  late String _address = "";
  late String _type = "";
  late String _userCoordinates = "";
  late String _userLocation = "";

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

  static const maxSeconds = 5;
  int seconds = maxSeconds;
  Timer? timer;
  //Countdown timer
  void startTimer(String emergencyType) {
    setState(() {
      timer = Timer.periodic(Duration(seconds: 1), (_) async {
        if (seconds > 0) {
          setState(() {
            _timerRunning = true;
            --seconds;
          });
        } else {
          timer?.cancel();
          quickAlert(QuickAlertType.loading, "Emergency Selected!", "Waiting for confirmation of the responders near you. Please hang tight", Colors.green);
          await getCurrentLocation();
          await convertCoordsToAddress(_coordinates!);
          SendEmergency(emergencyType, 'Ongoing', _coordinates.toString(), _address);
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
    String coordinates,
    String address,
  ) async {
    await FirebaseFirestore.instance.collection('emergencies').doc(_emailAddress.toLowerCase()).set({
      'Type': type,
      'Status': status,
      'Coordinates': coordinates,
      'Address': address,
    });
  }

  Future updateEmergencyDetails(
    String status,
  ) async {
    await FirebaseFirestore.instance.collection('emergencies').doc(_emailAddress.toLowerCase()).update({
      'Status': status,
    });
  }

  Future SendEmergency(String type, String status, String coordinates, String address) async {
    sendEmergencyDetails(
      type,
      status,
      coordinates,
      address,
    );
    print("Added emergency deets to firestone");

    var collection = FirebaseFirestore.instance.collection('emergencies');
    var docReference = collection.doc(_emailAddress);

    docReference.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var status = data?['Status'];
        if (status == 'Confirmed') {
          Navigator.of(context).pop();
          showEmergencyDetails(context);
        }
      }
    });
  }

  //Get the user location
  Position? _coordinates;
  Future<void> getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      _coordinates = position;
    });
  }

  Future<Position> determinePosition() async {
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

  Future<void> convertCoordsToAddress(Position position) async {
    List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemark[0];
    setState(() {
      _address = '${place.name} ${place.administrativeArea} ${place.subAdministrativeArea} ${place.locality} ${place.subLocality} ${place.subThoroughfare}';
    });
  }

  void resolveEmergency() async {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade200,
      context: context,
      type: QuickAlertType.confirm,
      title: "Resolved?",
      text: "Are you sure you want to mark this emergency as resolved?",
      confirmBtnText: "Yes",
      confirmBtnColor: Colors.white,
      confirmBtnTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      cancelBtnTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      onConfirmBtnTap: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        final emergency = FirebaseFirestore.instance.collection('emergencies').doc(_emailAddress);
        emergency.delete();
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  void showEmergencyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Center(
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.3),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                          spreadRadius: 7,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    height: 600.h,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Container(
                                  child: Icon(
                                    Icons.emergency,
                                    size: 60,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            child: const Text(
                              "Alert Acknowledged!",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: Container(
                            height: 100.h,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 30),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Dear ${_firstName}, we understand that the current situation may be causing concern and anxiety.\n\nThe responders are now on their way to address the issue and ensure your safety. \n",
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                            ),
                                            Container(
                                              height: 200.h,
                                              child: StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore.instance.collection('emergencies').doc(_emailAddress).snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Container(
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: Text("Fetching the Emergency Details"),
                                                      ),
                                                    );
                                                  }
                                                  try {
                                                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                                                    _type = userData['Type'];
                                                    _userCoordinates = userData['Coordinates'];
                                                    _userLocation = userData['Address'];
                                                  } catch (e) {
                                                    print(e.toString());
                                                    return Container();
                                                  }
                                                  return Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Emergency Details:',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 20.h),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Emergency Type:\t\t\t',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 17.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Text(
                                                            _type,
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 17.sp,
                                                              fontWeight: FontWeight.normal,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Coordinates:\t\t\t',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 17.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              _userCoordinates,
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 17.sp,
                                                                fontWeight: FontWeight.normal,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Your Location:\t\t\t',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 17.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              _userLocation,
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 17.sp,
                                                                fontWeight: FontWeight.normal,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(252, 58, 72, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                            ),
                            padding: EdgeInsets.all(12),
                          ),
                          onPressed: () async {
                            resolveEmergency();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 40.h,
                            child: Stack(
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Resolved",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.next_plan,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
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
                                      'Salute to you. Keep up doing the good deed!',
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
                                          "Select an emergency you want to respond to",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30.h),
                                    Container(
                                      height: 420.h,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('emergencies').snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Container(
                                              color: Colors.white,
                                              child: Center(
                                                child: Text("Fetching ongoing emergencies"),
                                              ),
                                            );
                                          }
                                          final snap = snapshot.data!.docs;
                                          if (snap.length == 0) {
                                            return Center(
                                              child: Text(
                                                "No active emergency reports at the moment",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 17.sp,
                                                ),
                                              ),
                                            );
                                          }
                                          return ScrollConfiguration(
                                            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                                            child: RawScrollbar(
                                              thickness: 7,
                                              thumbColor: Colors.redAccent,
                                              thumbVisibility: true,
                                              child: ListView.builder(
                                                itemCount: snap.length,
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                                        child: Column(
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
                                                                elevation: 3,
                                                              ),
                                                              onPressed: () {},
                                                              child: SizedBox(
                                                                height: 120.h,
                                                                width: MediaQuery.of(context).size.width,
                                                                child: Stack(
                                                                  children: [
                                                                    Positioned(
                                                                      top: 10,
                                                                      right: 0,
                                                                      child: IconButton(
                                                                        icon: Icon(
                                                                          Icons.delete,
                                                                          color: Colors.red,
                                                                        ),
                                                                        onPressed: () {
                                                                          setState(
                                                                            () {
                                                                              // QuickAlert.show(
                                                                              //   backgroundColor: Colors.grey.shade200,
                                                                              //   context: context,
                                                                              //   barrierDismissible: false,
                                                                              //   type: QuickAlertType.confirm,
                                                                              //   title: "Delete Confirmation",
                                                                              //   text: "Are you sure you want to remove ${snap[index]['Full Name']} from your contacts?",
                                                                              //   confirmBtnText: "Yes",
                                                                              //   confirmBtnColor: Colors.white,
                                                                              //   confirmBtnTextStyle: TextStyle(
                                                                              //     fontSize: 18.sp,
                                                                              //     fontWeight: FontWeight.bold,
                                                                              //     color: Colors.black,
                                                                              //   ),
                                                                              //   cancelBtnTextStyle: TextStyle(
                                                                              //     fontWeight: FontWeight.bold,
                                                                              //     color: Colors.red,
                                                                              //   ),
                                                                              //   onConfirmBtnTap: () {
                                                                              //     var contactNumbers = FirebaseFirestore.instance.collection('users').doc(_emailAddress).collection('contact numbers');
                                                                              //     contactNumbers.doc(snap[index]['Full Name'].toString()).delete();
                                                                              //     Navigator.of(context).pop();
                                                                              //   },
                                                                              //   onCancelBtnTap: () {
                                                                              //     Navigator.of(context).pop();
                                                                              //   },
                                                                              // );
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(left: 20),
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            snap[index]['Full Name'],
                                                                            style: TextStyle(
                                                                              fontSize: 20.sp,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          SizedBox(height: 5.h),
                                                                          Text(
                                                                            'Relationship:\t\t\t\t\t\t\t\t\t' + snap[index]['Relationship'],
                                                                            style: TextStyle(
                                                                              fontSize: 16.sp,
                                                                              fontWeight: FontWeight.normal,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Contact Number:\t ' + snap[index]['Contact Number'],
                                                                            style: TextStyle(
                                                                              fontSize: 16.sp,
                                                                              fontWeight: FontWeight.normal,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Email Address:\t\t\t\t\t' + snap[index]['Email Address'],
                                                                            style: TextStyle(
                                                                              fontSize: 16.sp,
                                                                              fontWeight: FontWeight.normal,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 20.h),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 200.h),
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
