import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CivHomePage extends StatefulWidget {
  const CivHomePage({Key? key}) : super(key: key);

  @override
  State<CivHomePage> createState() => _CivHomePageState();
}

class _CivHomePageState extends State<CivHomePage> {
  @override
  void initState() {
    initConnectivity();
    getUserData();
    super.initState();

    var collection = FirebaseFirestore.instance.collection('emergencies');
    var docReference = collection.doc(_emailAddress);
    print(_emailAddress);

    //Retains the status of reported emergency
    docReference.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var status = data?['Status'];
        if (status == 'Ongoing') {
          Future.delayed(Duration(milliseconds: 1000)).then((_) {
            Navigator.popUntil(context, (Route<dynamic> route) {
              return !(route is PopupRoute);
            });
            quickAlert(QuickAlertType.loading, "Emergency Selected!", "Waiting for confirmation of the responders near you. Please hang tight", Colors.green);
          });
          docReference.snapshots().listen((docSnapshot) {
            if (status == 'Confirmed') {
              Navigator.popUntil(context, (Route<dynamic> route) {
                return !(route is PopupRoute);
              });
              showEmergencyDetails(context);
            }
          });
        }
        if (status == 'Confirmed') {
          // Navigator.of(context).popUntil((route) => route is MaterialPageRoute);
          Navigator.popUntil(context, (Route<dynamic> route) {
            return !(route is PopupRoute);
          });

          showEmergencyDetails(context);
        }
      } else {
        Navigator.popUntil(context, (Route<dynamic> route) {
          return !(route is PopupRoute);
        });
      }
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    timer?.cancel();
  }

  bool _hasInternet = true;
  bool _timerRunning = false;
  bool _liveLocationUpdate = false;
  bool _emergencySelected = false;
  bool _fireEmergencySelected = false;
  bool _medicalEmergencySelected = false;
  bool _deathEmergencySelected = false;
  bool _traumaEmergencySelected = false;
  bool _floodEmergencySelected = false;
  bool _equakeEmergencySelected = false;
  bool _vehicularEmergencySelected = false;
  bool _shootingEmergencySelected = false;
  bool _alertEmergencySelected = false;

  late String _fullName = "";
  late String _firstName = "";
  late String _emailAddress = "";
  late String _address = "";
  late String _type = "";
  late String _userCoordinates = "";
  late String _userContactNumber = "";
  late String _userLocation = "";
  late String _responderName = "";
  late String _responderOccupation = "";
  late String _responderContactNumber = "";
  late String _responderEmployer = "";

  // FUNCTIONS
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> subscription;
  void initConnectivity() async {
    connectivityResult = await Connectivity().checkConnectivity();
    _hasInternet = await InternetConnectionChecker().hasConnection;
    subscription = Connectivity().onConnectivityChanged.listen(updateConnectivity);
    setState(() {});
  }

  void updateConnectivity(ConnectivityResult result) async {
    connectivityResult = result;
    _hasInternet = await InternetConnectionChecker().hasConnection;
    setState(() {});
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
      barrierDismissible: true,
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
            --seconds;
            _timerRunning = true;
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

  void _sendSMS(String message, List<String> recipients) async {
    if (await Permission.sms.request().isGranted) {
      String _result = await sendSMS(message: message, recipients: recipients, sendDirect: true).catchError((onError) {
        print(onError);
      });
      print(_result);
    } else {
      print("SMS permission not granted");
    }
  }

  String generateMessage(String fullName, String latitude, String longitude) {
    return 'Civilian: $fullName\nLocation: https://www.google.com/maps/search/$latitude%2C$longitude';
  }

  void startTimerOffline(String emergencyType) {
    setState(() {
      timer = Timer.periodic(Duration(seconds: 1), (_) async {
        if (seconds > 0) {
          setState(() {
            --seconds;
            _timerRunning = true;
          });
        } else {
          timer?.cancel();
          quickAlert(QuickAlertType.loading, "Emergency Selected!", "Waiting for confirmation of the responders near you. Please hang tight", Colors.green);
          await getCurrentLocation();
          print("Civilian: " + _fullName.toString());
          print("Coordinate: " + _coordinates.toString());
          String _userLatitude = _coordinates.toString().split('Latitude: ')[1].split(',')[0];
          String _userLongitude = _coordinates.toString().split('Longitude: ')[1];
          String message = generateMessage(_fullName, _userLatitude, _userLongitude);
          List<String> recipients = [
            "+639496678884",
            "+639152028287"
          ];
          print(message);
          _sendSMS(message, recipients);
          Navigator.of(context).pop();
          quickAlert(QuickAlertType.success, "Emergency Sent!", "You'll receive an emergency confirmation SMS on your device", Colors.green);
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
      _medicalEmergencySelected = false;
      _deathEmergencySelected = false;
      _traumaEmergencySelected = false;
      _floodEmergencySelected = false;
      _equakeEmergencySelected = false;
      _vehicularEmergencySelected = false;
      _shootingEmergencySelected = false;
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
      'Civilian': _fullName,
      'Email Address': _emailAddress,
      'Type': type,
      'Status': status,
      'Coordinates': coordinates,
      'Address': address,
      'Civilian Contact Number': _userContactNumber,
    });
  }

  Future updateEmergencyDetails(
    String status,
  ) async {
    await FirebaseFirestore.instance.collection('emergencies').doc(_emailAddress.toLowerCase()).update({
      'Status': status,
    });
  }

  Future updateCivilianLocation() async {
    await getCurrentLocation();
    print(_coordinates.toString());
  }

  Future updateCivilianLocationDetails(
    String coordinates,
  ) async {
    await FirebaseFirestore.instance.collection('emergencies').doc(_emailAddress.toLowerCase()).update({
      'Coordinates': coordinates,
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
        // await emergency.update({
        //   'Status': "Resolved",
        // });
        await emergency.delete();
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
                  height: 700.h,
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
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 30),
                                          child: Text(
                                            "Dear ${_firstName}, we understand that the current situation may be causing concern and anxiety.\n\nThe responders are now on their way to address the issue and ensure your safety. \n",
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 40.h),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: Color.fromRGBO(82, 82, 82, 1),
                                                  width: 1,
                                                ),
                                              ),
                                              elevation: 3,
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                _liveLocationUpdate = !_liveLocationUpdate;
                                              });
                                              Timer? liveDelay;
                                              if (_liveLocationUpdate) {
                                                liveDelay = Timer.periodic(Duration(seconds: 2), (timer) async {
                                                  await updateCivilianLocation();
                                                  await updateCivilianLocationDetails(_coordinates.toString());
                                                  print("Updated Location");
                                                  if (!_liveLocationUpdate) {
                                                    print("Stop LIVE");
                                                    liveDelay?.cancel();
                                                  }
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: 50.h,
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          _liveLocationUpdate ? "Live Location On" : "Live Location Off",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 17.sp,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        SizedBox(width: 10.h),
                                                        Icon(
                                                          _liveLocationUpdate ? Icons.location_on : Icons.location_off,
                                                          color: Colors.red,
                                                          size: 25,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20.h),
                                        Container(
                                          height: 320.h,
                                          width: MediaQuery.of(context).size.width,
                                          child: ScrollConfiguration(
                                            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                                            child: RawScrollbar(
                                              thickness: 7.5,
                                              thumbColor: Colors.redAccent,
                                              thumbVisibility: true,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Container(
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
                                                            _responderName = userData['Responder'];
                                                            _responderOccupation = userData['Responder Occupation'];
                                                            _responderContactNumber = userData['Responder Contact Number'];
                                                            _responderEmployer = userData['Responder Employer'];
                                                          } catch (e) {
                                                            print(e.toString());
                                                            return Container();
                                                          }
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 30),
                                                            child: Column(
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
                                                                    Expanded(
                                                                      child: Text(
                                                                        _type,
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
                                                                        "Somewhere near " + _userLocation,
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
                                                                SizedBox(height: 20.h),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'Responder Details:',
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
                                                                      'Responder:\t\t\t',
                                                                      textAlign: TextAlign.left,
                                                                      style: TextStyle(
                                                                        fontSize: 17.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        _responderName,
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
                                                                SizedBox(height: 10),
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      'Occupation:\t\t\t',
                                                                      textAlign: TextAlign.left,
                                                                      style: TextStyle(
                                                                        fontSize: 17.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        _responderOccupation,
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
                                                                      'Contact Number:\t\t\t',
                                                                      textAlign: TextAlign.left,
                                                                      style: TextStyle(
                                                                        fontSize: 17.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        _responderContactNumber,
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
                                                                      'Employer:\t\t\t',
                                                                      textAlign: TextAlign.left,
                                                                      style: TextStyle(
                                                                        fontSize: 17.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        _responderEmployer,
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
                                                                SizedBox(height: 60.h),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(height: 50.h),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
                    physics: _hasInternet ? ScrollPhysics() : NeverScrollableScrollPhysics(),
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
                                        _fullName = '${userData['First Name']} ${userData['M.I']}. ${userData['Surname']}';
                                        _userContactNumber = userData['Contact Number'];
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
                                    Visibility(
                                      visible: !_hasInternet,
                                      child: Column(
                                        children: [
                                          SizedBox(height: 80.h),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Expanded(
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              "You are currently not connected to the internet. All emergency sent will be marked as an alert emergency",
                                                              textAlign: TextAlign.justify,
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 18.sp,
                                                              ),
                                                            ),
                                                            SizedBox(height: 20.h),
                                                            Text(
                                                              "An SMS will be sent to your device after a responder has confirmed your emergency.",
                                                              textAlign: TextAlign.justify,
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 18.sp,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 80.h),
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
                                                        if (!_timerRunning && !_alertEmergencySelected) {
                                                          setState(() {
                                                            _alertEmergencySelected = true;
                                                            _emergencySelected = true;
                                                          });
                                                          startTimerOffline("Alert Emergency");
                                                        }
                                                        if (_timerRunning && _alertEmergencySelected) {
                                                          setState(() {
                                                            stopTimer();
                                                          });
                                                        }
                                                      },
                                                      child: SizedBox(
                                                        height: 150.h,
                                                        width: 200.w,
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
                                                  SizedBox(height: 500.h),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: _hasInternet,
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
                                          //Grid of buttons starts here

                                          //Medical and Vehicular
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Opacity(
                                                opacity: _timerRunning && !_medicalEmergencySelected ? 0.6 : 1,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _medicalEmergencySelected ? const Color.fromRGBO(153, 0, 51, 1) : Colors.white,
                                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                      side: BorderSide(
                                                        color: _medicalEmergencySelected ? const Color.fromRGBO(153, 0, 51, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    elevation: _timerRunning && !_medicalEmergencySelected ? 1 : 3,
                                                  ),
                                                  onPressed: () {
                                                    if (!_timerRunning && !_emergencySelected) {
                                                      setState(() {
                                                        _medicalEmergencySelected = true;
                                                        _emergencySelected = true;
                                                      });
                                                      startTimer("Medical Emergency");
                                                    }
                                                    if (_timerRunning && _medicalEmergencySelected) {
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
                                                            visible: _medicalEmergencySelected,
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
                                                            visible: !_medicalEmergencySelected,
                                                            child: Column(
                                                              children: [
                                                                Icon(
                                                                  Icons.health_and_safety,
                                                                  color: const Color.fromRGBO(153, 0, 51, 1),
                                                                  size: 40,
                                                                ),
                                                                Text(
                                                                  "Medical",
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
                                                opacity: _timerRunning && !_vehicularEmergencySelected ? 0.6 : 1,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _vehicularEmergencySelected ? const Color.fromRGBO(157, 2, 8, 1) : Colors.white,
                                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                      side: BorderSide(
                                                        color: _vehicularEmergencySelected ? const Color.fromRGBO(157, 2, 8, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    elevation: _timerRunning && !_vehicularEmergencySelected ? 1 : 3,
                                                  ),
                                                  onPressed: () {
                                                    if (!_timerRunning && !_vehicularEmergencySelected) {
                                                      setState(() {
                                                        _vehicularEmergencySelected = true;
                                                        _emergencySelected = true;
                                                      });
                                                      startTimer("Vehicular Emergency");
                                                    }
                                                    if (_timerRunning && _vehicularEmergencySelected) {
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
                                                            visible: _vehicularEmergencySelected,
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
                                                            visible: !_vehicularEmergencySelected,
                                                            child: Column(
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons.carBurst,
                                                                  color: const Color.fromRGBO(157, 2, 8, 1),
                                                                  size: 35,
                                                                ),
                                                                SizedBox(height: 2.h),
                                                                Text(
                                                                  "Vehicular",
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

                                          //Trauma and Fire
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Opacity(
                                                opacity: _timerRunning && !_traumaEmergencySelected ? 0.6 : 1,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _traumaEmergencySelected ? const Color.fromARGB(255, 163, 49, 70) : Colors.white,
                                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                      side: BorderSide(
                                                        color: _traumaEmergencySelected ? const Color.fromRGBO(184, 58, 67, 0.878) : Color.fromRGBO(82, 82, 82, 1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    elevation: _timerRunning && !_traumaEmergencySelected ? 1 : 3,
                                                  ),
                                                  onPressed: () {
                                                    if (!_timerRunning && !_traumaEmergencySelected) {
                                                      setState(() {
                                                        _traumaEmergencySelected = true;
                                                        _emergencySelected = true;
                                                      });
                                                      startTimer("Trauma Emergency");
                                                    }
                                                    if (_timerRunning && _traumaEmergencySelected) {
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
                                                            visible: _traumaEmergencySelected,
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
                                                            visible: !_traumaEmergencySelected,
                                                            child: Column(
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons.handFist,
                                                                  color: const Color.fromRGBO(184, 58, 67, 0.878),
                                                                  size: 35,
                                                                ),
                                                                SizedBox(height: 2.h),
                                                                Text(
                                                                  "Trauma",
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
                                                      startTimer("Fire Emergency");
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
                                            ],
                                          ),
                                          SizedBox(height: 15.h),

                                          //Death and Shooting
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Opacity(
                                                opacity: _timerRunning && !_deathEmergencySelected ? 0.6 : 1,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _deathEmergencySelected ? const Color.fromARGB(223, 177, 28, 38) : Colors.white,
                                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                      side: BorderSide(
                                                        color: _deathEmergencySelected ? const Color.fromARGB(223, 177, 28, 38) : Color.fromRGBO(82, 82, 82, 1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    elevation: _timerRunning && !_deathEmergencySelected ? 1 : 3,
                                                  ),
                                                  onPressed: () {
                                                    if (!_timerRunning && !_deathEmergencySelected) {
                                                      setState(() {
                                                        _deathEmergencySelected = true;
                                                        _emergencySelected = true;
                                                      });
                                                      startTimer("Death Emergency");
                                                    }
                                                    if (_timerRunning && _deathEmergencySelected) {
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
                                                            visible: _deathEmergencySelected,
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
                                                            visible: !_deathEmergencySelected,
                                                            child: Column(
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons.solidFaceDizzy,
                                                                  color: const Color.fromARGB(223, 177, 28, 38),
                                                                  size: 35,
                                                                ),
                                                                SizedBox(height: 2.h),
                                                                Text(
                                                                  "Death",
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
                                                opacity: _timerRunning && !_shootingEmergencySelected ? 0.6 : 1,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: _shootingEmergencySelected ? const Color.fromRGBO(220, 47, 2, 1) : Colors.white,
                                                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                      side: BorderSide(
                                                        color: _shootingEmergencySelected ? const Color.fromRGBO(220, 47, 2, 1) : Color.fromRGBO(82, 82, 82, 1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    elevation: _timerRunning && !_shootingEmergencySelected ? 1 : 3,
                                                  ),
                                                  onPressed: () {
                                                    if (!_timerRunning && !_shootingEmergencySelected) {
                                                      setState(() {
                                                        _shootingEmergencySelected = true;
                                                        _emergencySelected = true;
                                                      });
                                                      startTimer("Shooting Emergency");
                                                    }
                                                    if (_timerRunning && _shootingEmergencySelected) {
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
                                                            visible: _shootingEmergencySelected,
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
                                                            visible: !_shootingEmergencySelected,
                                                            child: Column(
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons.userNinja,
                                                                  color: const Color.fromRGBO(220, 47, 2, 1),
                                                                  size: 35,
                                                                ),
                                                                SizedBox(height: 2.h),
                                                                Text(
                                                                  "Shooting",
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
                                                    if (!_timerRunning && !_floodEmergencySelected) {
                                                      setState(() {
                                                        _floodEmergencySelected = true;
                                                        _emergencySelected = true;
                                                      });
                                                      startTimer("Flood Emergency");
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
                                                    if (!_timerRunning && !_equakeEmergencySelected) {
                                                      setState(() {
                                                        _equakeEmergencySelected = true;
                                                        _emergencySelected = true;
                                                      });
                                                      startTimer("Earthquake Emergency");
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
                                                if (!_timerRunning && !_alertEmergencySelected) {
                                                  setState(() {
                                                    _alertEmergencySelected = true;
                                                    _emergencySelected = true;
                                                  });
                                                  startTimer("Alert Emergency");
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
