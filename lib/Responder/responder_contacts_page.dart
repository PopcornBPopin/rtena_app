import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rtena_app/Civilian/civilian_start_page.dart';

class ResContactsPage extends StatefulWidget {
  const ResContactsPage({Key? key}) : super(key: key);

  @override
  State<ResContactsPage> createState() => _ResContactsPageState();
}

class _ResContactsPageState extends State<ResContactsPage> {
  @override
  void initState() {
    getConnectivity();
    getUserData();
    super.initState();
    DefaultAssetBundle.of(context).loadString('assets/maptheme/night_theme.json').then((value) => {
          mapTheme = value
        });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setState(() {});
  }

  //Disposes controllers when not in used
  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _customInfoWindowController.dispose();
    subscription.cancel();
    super.dispose();
  }

  bool _hasInternet = false;

  bool _fireEmergencyFiltered = false;
  bool _healthEmergencyFiltered = false;
  bool _murderEmergencyFiltered = false;
  bool _assaultEmergencyFiltered = false;
  bool _floodEmergencyFiltered = false;
  bool _earthquakeEmergencyFiltered = false;
  bool _kidnappingEmergencyFiltered = false;
  bool _robberyEmergencyFiltered = false;

  late StreamSubscription subscription;
  late String _emailAddress = "";
  late String _civCoordinates = "";
  late String _civEmergencyType = "";
  late double _civLatitude = 0.0;
  late double _civLongitude = 0.0;
  late double _totalLatitude = 0.0;
  late double _totalLongitude = 0.0;
  late double _averageLatitude = 0.0;
  late double _averageLongitude = 0.0;
  late int _markerSelected = 0;

  late String _fullName = "";
  late String _firstName = "";
  late String _address = "";
  late String _type = "";
  late String _userCoordinates = "";
  late String _userLocation = "";
  late String _responderName = "";
  late String _responderOccupation = "";
  late String _responderContactNumber = "";
  late String _responderEmployer = "";

  late String _contactNumber = "";
  late String _occupation = "";
  late String _employer = "";

  late GoogleMapController mapController;

  BitmapDescriptor _getMarkerIcon(String emergencyType) {
    switch (emergencyType) {
      case 'Fire Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'Health Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'Murder Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case 'Assault Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'Flood Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
      case 'Earthquake Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'Kidnapping Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
      case 'Robbery Emergency':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  String mapTheme = "";
  //Text Controllers
  final _nameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationshipController = TextEditingController();

  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  void _onMapCreated(GoogleMapController controller) {
    _customInfoWindowController.googleMapController = controller;
    controller.setMapStyle(mapTheme);
  }

  //SNACKBAR
  final incompleteFieldSnackbar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: 25,
          color: Colors.white,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Invalid form. Check your inputs.',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.redAccent,
    duration: Duration(seconds: 5),
    behavior: SnackBarBehavior.fixed,
    elevation: 1,
  );

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

  void getUserData() async {
    print(_emailAddress);
    User? user = FirebaseAuth.instance.currentUser;
    _emailAddress = user!.email!;
  }

  void quickAlert(QuickAlertType animtype, String title, String text, String confirmText, Color color) {
    QuickAlert.show(
      context: context,
      barrierDismissible: false,
      backgroundColor: Colors.grey.shade200,
      type: animtype,
      title: title,
      text: text,
      confirmBtnText: confirmText,
      confirmBtnColor: Colors.white,
      confirmBtnTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      cancelBtnTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  //Writing new contact to Firestone DB
  Future registerNewContactDetails(
    String fullname,
    String relationship,
    String contactNumber,
    String emailAddress,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(_emailAddress.toLowerCase()).collection('contact numbers').doc(fullname).set({
      'Full Name': fullname,
      'Relationship': relationship,
      'Contact Number': contactNumber,
      'Email Address': emailAddress,
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
                                                                    Text(
                                                                      _responderOccupation,
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
                                                                      'Contact Number:\t\t\t',
                                                                      textAlign: TextAlign.left,
                                                                      style: TextStyle(
                                                                        fontSize: 17.sp,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      _responderContactNumber,
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
                                                                SizedBox(height: 50.h),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
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

  Future RegisterContact() async {
    registerNewContactDetails(
      _nameController.text.trim(),
      _relationshipController.text.trim(),
      _contactNumberController.text.trim(),
      _emailController.text.trim(),
    );
    print("Added contact deets to firestone");

    Navigator.of(context).pop();

    quickAlert(QuickAlertType.success, "Register Successful!", "New emergency contact added", "Okay", Colors.green);
  }

  void showLegend(BuildContext context) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(true);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 150),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 350.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color.fromRGBO(82, 82, 82, 1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tap on the emergency type you want to filter",
                          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _fireEmergencyFiltered = !_fireEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _fireEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.red,
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Colors.red,
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Fire Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _healthEmergencyFiltered = !_healthEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _healthEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Color.fromRGBO(0, 127, 255, 1),
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Color.fromRGBO(0, 127, 255, 1),
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Health Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _murderEmergencyFiltered = !_murderEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _murderEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.cyan,
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Colors.cyan,
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Murder Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _assaultEmergencyFiltered = !_assaultEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _assaultEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Colors.green,
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Assault Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _floodEmergencyFiltered = !_floodEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _floodEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Color.fromRGBO(255, 0, 255, 1),
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Color.fromRGBO(255, 0, 255, 1),
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Flood Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _earthquakeEmergencyFiltered = !_earthquakeEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _earthquakeEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.orange,
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Colors.orange,
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Earthquake Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _kidnappingEmergencyFiltered = !_kidnappingEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _kidnappingEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Color.fromRGBO(255, 0, 85, 1),
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Color.fromRGBO(255, 0, 85, 1),
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Kidnapping Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _robberyEmergencyFiltered = !_robberyEmergencyFiltered;
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _robberyEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Color.fromRGBO(138, 43, 226, 1),
                                        )
                                      : Icon(
                                          Icons.radio_button_checked,
                                          color: Color.fromRGBO(138, 43, 226, 1),
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Robbery Emergency",
                                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.normal),
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
              ),
            ),
          );
        },
      ),
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
            Color.fromRGBO(70, 18, 32, 1),
            Color.fromRGBO(70, 18, 32, 1),
          ],
        ),
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showLegend(context);
          },
          backgroundColor: Colors.white,
          child: Container(
            height: 100.h,
            width: 100.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Color.fromRGBO(82, 82, 82, 1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.menu,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                                    _contactNumber = userData['Contact Number'];
                                    _occupation = userData['Occupation'];
                                    _employer = userData['Employer'];
                                    _fullName = '${userData['First Name']} ${userData['M.I']}. ${userData['Surname']}';
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
                                  'You\'re making a difference. Don\'t stop now!',
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
                    Expanded(
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                                child: Container(
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
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 700.h,
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
                                            List<LatLng> coordinatesList = [];
                                            Set<Marker> _markers = {};

                                            for (var i = 0; i < snap.length; i++) {
                                              _civEmergencyType = snap[i]['Type'];
                                              _civCoordinates = snap[i]['Coordinates'];
                                              _civLatitude = double.parse(_civCoordinates.split('Latitude: ')[1].split(',')[0]);
                                              _civLongitude = double.parse(_civCoordinates.split('Longitude: ')[1]);
                                              LatLng _coordinate = LatLng(_civLatitude, _civLongitude);
                                              coordinatesList.add(_coordinate);
                                              Marker marker = Marker(
                                                markerId: MarkerId(_coordinate.toString()),
                                                position: _coordinate,
                                                icon: _getMarkerIcon(
                                                  _civEmergencyType,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    _markerSelected = i;
                                                  });
                                                  print(_markerSelected);
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => StatefulBuilder(
                                                      builder: (context, setState) {
                                                        return WillPopScope(
                                                          onWillPop: () {
                                                            return Future.value(true);
                                                          },
                                                          child: Scaffold(
                                                            backgroundColor: Colors.transparent,
                                                            body: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                                                child: Container(
                                                                  height: 420.h,
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
                                                                  width: MediaQuery.of(context).size.width,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      SizedBox(height: 20.h),
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width,
                                                                        child: Stack(
                                                                          children: [
                                                                            Positioned(
                                                                              right: 20,
                                                                              child: IconButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                icon: Icon(Icons.close),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 30),
                                                                              child: Container(
                                                                                child: Icon(
                                                                                  {
                                                                                        'Fire Emergency': FontAwesomeIcons.fire,
                                                                                        'Health Emergency': Icons.health_and_safety,
                                                                                        'Murder Emergency': FontAwesomeIcons.solidFaceDizzy,
                                                                                        'Assault Emergency': FontAwesomeIcons.handFist,
                                                                                        'Flood Emergency': FontAwesomeIcons.water,
                                                                                        'Earthquake Emergency': FontAwesomeIcons.houseChimneyCrack,
                                                                                        'Kidnap Emergency': FontAwesomeIcons.solidFaceSadCry,
                                                                                        'Robbery Emergency': FontAwesomeIcons.userNinja,
                                                                                        'Alert Emergency': Icons.notifications_active,
                                                                                      }[snap[_markerSelected]['Type']] ??
                                                                                      Icons.warning,
                                                                                  size: 50,
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
                                                                            "Emergency Details",
                                                                            textAlign: TextAlign.left,
                                                                            style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 20.h),
                                                                      Expanded(
                                                                        child: Container(
                                                                          child: Expanded(
                                                                            child: Column(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: RawScrollbar(
                                                                                    thickness: 7.5,
                                                                                    thumbColor: Color.fromRGBO(70, 18, 32, 1),
                                                                                    thumbVisibility: true,
                                                                                    child: ScrollConfiguration(
                                                                                      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                                                                                      child: ListView.builder(
                                                                                        itemCount: 1,
                                                                                        itemBuilder: (context, index) {
                                                                                          return Padding(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                SizedBox(height: 20.h),
                                                                                                Row(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      'Civilian:\t\t\t',
                                                                                                      textAlign: TextAlign.left,
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 20.sp,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        color: Colors.black,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      snap[_markerSelected]['Civilian'],
                                                                                                      textAlign: TextAlign.left,
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 20.sp,
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
                                                                                                      'Emergency Type:\t\t\t',
                                                                                                      textAlign: TextAlign.left,
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 20.sp,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        color: Colors.black,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        snap[_markerSelected]['Type'],
                                                                                                        textAlign: TextAlign.left,
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 20.sp,
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
                                                                                                      'Emergency Location:\t\t\t',
                                                                                                      textAlign: TextAlign.left,
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 20.sp,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        color: Colors.black,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        snap[_markerSelected]['Address'],
                                                                                                        textAlign: TextAlign.left,
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 20.sp,
                                                                                                          fontWeight: FontWeight.normal,
                                                                                                          color: Colors.black,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                SizedBox(height: 20.h),
                                                                                              ],
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
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
                                                                          var emergencies = FirebaseFirestore.instance.collection('emergencies');
                                                                          var querySnapshots = await emergencies.get();
                                                                          for (var doc in querySnapshots.docs) {
                                                                            await doc.reference.update({
                                                                              'Status': 'Confirmed',
                                                                              'Responder': _fullName,
                                                                              'Responder Contact Number': _contactNumber,
                                                                              'Responder Occupation': _occupation,
                                                                              'Responder Employer': _employer,
                                                                            });
                                                                          }
                                                                          var collection = FirebaseFirestore.instance.collection('emergencies');
                                                                          print(snap[_markerSelected]['Email Address']);
                                                                          var docReference = collection.doc(snap[_markerSelected]['Email Address']);

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
                                                                                      "Respond",
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
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                              _markers.add(marker);
                                            }

                                            for (LatLng coordinates in coordinatesList) {
                                              _totalLatitude += coordinates.latitude;
                                              _totalLongitude += coordinates.longitude;
                                            }
                                            _averageLatitude = _totalLatitude / coordinatesList.length;
                                            _averageLongitude = _totalLongitude / coordinatesList.length;

                                            return Container(
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
                                                    child: Container(
                                                      child: GoogleMap(
                                                        mapType: MapType.normal,
                                                        mapToolbarEnabled: false,
                                                        zoomControlsEnabled: false,
                                                        onMapCreated: _onMapCreated,
                                                        initialCameraPosition: CameraPosition(
                                                          target: LatLng(_averageLatitude, _averageLongitude),
                                                          zoom: 10,
                                                        ),
                                                        markers: _markers,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
