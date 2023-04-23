import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';

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
    userIcon = BitmapDescriptor.defaultMarker;
    super.initState();
    DefaultAssetBundle.of(context).loadString('assets/maptheme/night_theme.json').then((value) => {
          mapTheme = value
        });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setState(() {
      getCurrentLocation();
    });
  }

  //Get the user location
  Position? _coordinates;
  Future<void> getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      _coordinates = position;
      _userLatitude = double.parse(_coordinates.toString().split('Latitude: ')[1].split(',')[0]);
      _userLongitude = double.parse(_coordinates.toString().split('Longitude: ')[1]);
    });
  }

  Future<Position> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        quickAlert(QuickAlertType.error, "Pemission Denied!", "Location permissions are denied", "", Colors.green);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      quickAlert(QuickAlertType.error, "Pemission Denied!", "Location permissions are permanently denied, we cannot request permissions", "", Colors.green);
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
  late double _userLatitude = 0.0;
  late double _userLongitude = 0.0;
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
  late BitmapDescriptor userIcon;

  double calculateZoomLevel(double distance) {
    if (distance <= 0.1) {
      return 12.5;
    } else if (distance <= 0.5) {
      return 9.5;
    } else if (distance <= 1.0) {
      return 7.5;
    } else {
      return 5.5;
    }
  }

  final String apiKey = "AIzaSyAy5qAZpPfEk8QFs8BGXUvq8Gd1MFHKo0o";

  // void drawPolyline() async {
  //   var response = http.post(Uri.parse('https://maps/googleapis.com/maps/api/directions/json?key="${apiKey}"&units=metric&origin="${_userLatitude},${_userLongitude}"&destination="${_civLatitude},${_civLongitude}"&mode=driving'));
  // }

  createMarker(context) {
    if (userIcon == BitmapDescriptor.defaultMarker) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, 'assets/user_icon.png').then(
        (Icon) => setState(() {
          userIcon = Icon;
        }),
      );
    }
  }

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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(true);
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
                                    color: Color.fromRGBO(70, 18, 32, 1),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 20,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.close),
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
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
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
                                          _civCoordinates = snap[_markerSelected]['Coordinates'];
                                          _civLatitude = double.parse(_civCoordinates.split('Latitude: ')[1].split(',')[0]);
                                          _civLongitude = double.parse(_civCoordinates.split('Longitude: ')[1]);

                                          _averageLatitude = (_civLatitude + _userLatitude) / 2;
                                          _averageLongitude = (_civLongitude + _userLongitude) / 2;

                                          //Calculate the distance between resloc and selected civLoc
                                          double distance = sqrt(pow(_userLatitude - _civLatitude, 2) + pow(_userLongitude - _civLongitude, 2));
                                          print("ZOOM" + calculateZoomLevel(distance).toString());

                                          var collection = FirebaseFirestore.instance.collection('emergencies');
                                          var docReference = collection.doc(snap[_markerSelected]['Email Address']);

                                          docReference.snapshots().listen((docSnapshot) {
                                            if (!docSnapshot.exists) {
                                              Navigator.of(context).pop();
                                            }
                                          });

                                          Marker civMarker = Marker(
                                            markerId: MarkerId(_civCoordinates),
                                            position: LatLng(_civLatitude, _civLongitude),
                                          );

                                          Marker userMarker = Marker(
                                            markerId: MarkerId(_civCoordinates),
                                            position: LatLng(_userLatitude, _userLongitude),
                                            icon: userIcon,
                                          );

                                          Set<Marker> markers = Set<Marker>.from([
                                            civMarker,
                                            userMarker
                                          ]);

                                          // return Text("TESTR");
                                          return Container(
                                            child: Column(
                                              children: [
                                                Padding(
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
                                                              fontSize: 18.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              snap[_markerSelected]['Type'],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
                                                                fontWeight: FontWeight.normal,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Coordinates:\t\t\t',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              snap[_markerSelected]['Coordinates'],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
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
                                                              fontSize: 18.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              snap[_markerSelected]['Address'],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
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
                                                            'Civilian Details:',
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
                                                            'Civilian:\t\t\t',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              snap[_markerSelected]['Civilian'],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
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
                                                            'Contact Number:\t\t\t',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              snap[_markerSelected]['Civilian Contact Number'],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
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
                                                            'Email Address:\t\t\t',
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              snap[_markerSelected]['Email Address'],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
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
                                                SizedBox(height: 20.h),
                                                // GO HERE BE
                                                ClipRRect(
                                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                                                  child: Container(
                                                    height: 400.h,
                                                    child: GoogleMap(
                                                      mapType: MapType.normal,
                                                      mapToolbarEnabled: false,
                                                      zoomControlsEnabled: false,
                                                      onMapCreated: _onMapCreated,
                                                      initialCameraPosition: CameraPosition(
                                                        target: LatLng(_averageLatitude, _averageLongitude),
                                                        zoom: calculateZoomLevel(distance),
                                                      ),
                                                      markers: markers,
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
    createMarker(context);
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showLegend(context);
          },
          backgroundColor: Colors.white,
          label: Text(
            'Legend',
            style: TextStyle(color: Colors.black),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(
              color: Color.fromRGBO(82, 82, 82, 1),
              width: 1,
            ),
          ),
          icon: Icon(
            Icons.menu,
            color: Colors.black,
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
                                            if (_userLatitude == 0.0 || _userLongitude == 0.0) {
                                              return Center(
                                                child: Container(
                                                  height: 100.h,
                                                  child: Text(
                                                    "Fetching ongoing emergencies",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 17.sp,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            if (snap.length == 0) {
                                              return Center(
                                                child: Container(
                                                  height: 100.h,
                                                  child: Text(
                                                    "No active emergency reports at the moment",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 17.sp,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            List<LatLng> coordinatesList = [];
                                            Set<Marker> _markers = {};

                                            for (var i = 0; i < snap.length; i++) {
                                              _civEmergencyType = snap[i]['Type'];
                                              _civCoordinates = snap[i]['Coordinates'];
                                              _civLatitude = double.parse(_civCoordinates.split('Latitude: ')[1].split(',')[0]);
                                              _civLongitude = double.parse(_civCoordinates.split('Longitude: ')[1]);
                                              LatLng _civCoordinate = LatLng(_civLatitude, _civLongitude);
                                              LatLng _userCoordinate = LatLng(_userLatitude, _userLongitude);
                                              coordinatesList.add(_civCoordinate);
                                              coordinatesList.add(_userCoordinate);

                                              Marker userMarker = Marker(
                                                markerId: MarkerId(_userCoordinate.toString()),
                                                position: _userCoordinate,
                                                icon: userIcon,
                                              );

                                              Marker civMarker = Marker(
                                                markerId: MarkerId(_civCoordinate.toString()),
                                                position: _civCoordinate,
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
                                                                  height: 400.h,
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
                                                                                  color: Color.fromRGBO(70, 18, 32, 1),
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
                                                                                                        fontSize: 18.sp,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        color: Colors.black,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      snap[_markerSelected]['Civilian'],
                                                                                                      textAlign: TextAlign.left,
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 18.sp,
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
                                                                                                        fontSize: 18.sp,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        color: Colors.black,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        snap[_markerSelected]['Type'],
                                                                                                        textAlign: TextAlign.left,
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18.sp,
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
                                                                                                        fontSize: 18.sp,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        color: Colors.black,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        snap[_markerSelected]['Address'],
                                                                                                        textAlign: TextAlign.left,
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18.sp,
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
                                                                          backgroundColor: Color.fromRGBO(70, 18, 32, 1),
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
                                              _markers.add(civMarker);
                                              _markers.add(userMarker);
                                            }

                                            for (LatLng coordinates in coordinatesList) {
                                              _totalLatitude += coordinates.latitude;
                                              _totalLongitude += coordinates.longitude;
                                            }

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
                                                          target: LatLng(_userLatitude, _userLongitude),
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
