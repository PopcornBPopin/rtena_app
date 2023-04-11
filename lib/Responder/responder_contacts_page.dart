import 'dart:async';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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

  late StreamSubscription subscription;
  late String _emailAddress = "";
  late String _civCoordinates = "";
  late double _civLatitude = 0.0;
  late double _civLongitude = 0.0;
  late double _totalLatitude = 0.0;
  late double _totalLongitude = 0.0;
  late double _averageLatitude = 0.0;
  late double _averageLongitude = 0.0;

  late GoogleMapController mapController;

  //Text Controllers
  final _nameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationshipController = TextEditingController();

  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  void _onMapCreated(GoogleMapController controller) {
    _customInfoWindowController.googleMapController = controller;
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
                                    'Map Test ',
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
                                        for (var i = 0; i < snap.length; i++) {
                                          _civCoordinates = snap[i]['Coordinates'];
                                          _civLatitude = double.parse(_civCoordinates.split('Latitude: ')[1].split(',')[0]);
                                          _civLongitude = double.parse(_civCoordinates.split('Longitude: ')[1]);
                                          LatLng _coordinate = LatLng(_civLatitude, _civLongitude);
                                          coordinatesList.add(_coordinate);
                                        }
                                        for (LatLng coordinates in coordinatesList) {
                                          _totalLatitude += coordinates.latitude;
                                          _totalLongitude += coordinates.longitude;
                                        }
                                        _averageLatitude = _totalLatitude / coordinatesList.length;
                                        _averageLongitude = _totalLongitude / coordinatesList.length;

                                        return ClipRRect(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                                          child: Container(
                                            height: 500.h,
                                            child: Stack(
                                              children: [
                                                GoogleMap(
                                                  mapType: MapType.normal,
                                                  mapToolbarEnabled: false,
                                                  zoomControlsEnabled: false,
                                                  onMapCreated: _onMapCreated,
                                                  initialCameraPosition: CameraPosition(
                                                    target: LatLng(_averageLatitude, _averageLongitude),
                                                    zoom: 15.0,
                                                  ),
                                                  markers: Set.from(
                                                    coordinatesList.map(
                                                      (coordinate) => Marker(
                                                        markerId: MarkerId(coordinate.toString()),
                                                        position: coordinate,
                                                        onTap: () {
                                                          print("OPEN GAGO");
                                                          _customInfoWindowController.addInfoWindow!(
                                                            Container(
                                                              height: 100,
                                                              width: 300,
                                                              color: Colors.white,
                                                              child: ListView.builder(
                                                                physics: NeverScrollableScrollPhysics(),
                                                                itemCount: snap.length,
                                                                itemBuilder: (context, index) {
                                                                  Column(
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
                                                                      Text(
                                                                        snap[index]['Civilian'],
                                                                        textAlign: TextAlign.left,
                                                                        style: TextStyle(
                                                                          fontSize: 20,
                                                                          fontWeight: FontWeight.normal,
                                                                          color: Colors.black,
                                                                        ),
                                                                      ),
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
                                                                  );
                                                                  return Container();
                                                                },
                                                              ),
                                                            ),
                                                            coordinate,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                CustomInfoWindow(
                                                  controller: _customInfoWindowController,
                                                  height: 100,
                                                  width: 300,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
