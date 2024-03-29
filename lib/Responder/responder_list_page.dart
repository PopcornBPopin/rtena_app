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

class ResListPage extends StatefulWidget {
  const ResListPage({Key? key}) : super(key: key);

  @override
  State<ResListPage> createState() => _ResListPageState();
}

class _ResListPageState extends State<ResListPage> {
  @override
  void initState() {
    initConnectivity();
    getUserData();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  bool _hasInternet = false;

  late String _firstName = "";
  late String _fullName = "";
  late String _contactNumber = "";
  late String _emailAddress = "";
  late String _occupation = "";
  late String _employer = "";
  late String _address = "";
  late String _type = "";
  late String _userCoordinates = "";
  late String _userLocation = "";

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
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
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
                                            thumbColor: Color.fromRGBO(70, 18, 32, 1),
                                            thumbVisibility: true,
                                            child: ListView.builder(
                                              itemCount: snap.length,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                                          child: ElevatedButton(
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
                                                            },
                                                            child: SizedBox(
                                                              height: 200.h,
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Stack(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(left: 20),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              snap[index]['Civilian'],
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                fontWeight: FontWeight.normal,
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
                                                                              'Type:\t\t\t',
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(
                                                                                fontSize: 17.sp,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              snap[index]['Type'],
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
                                                                                snap[index]['Coordinates'],
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
                                                                              'Location:\t\t\t',
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(
                                                                                fontSize: 17.sp,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                snap[index]['Address'],
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
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20.h),
                                                      ],
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
