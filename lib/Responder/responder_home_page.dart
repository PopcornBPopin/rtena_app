import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';

import '../notification_service.dart';

class ResHomePage extends StatefulWidget {
  const ResHomePage({Key? key}) : super(key: key);

  @override
  State<ResHomePage> createState() => _ResHomePageState();
}

class _ResHomePageState extends State<ResHomePage> {
  @override
  void initState() {
    Timer? liveDelay;
    liveDelay = Timer.periodic(Duration(seconds: 8), (timer) async {
      print("Update location");
      await updateUserLocation();
      setState(() {});
    });
    initConnectivity();
    getUserData();
    getCurrentLocation();
    checkCivID();

    initNotifications();

    userIcon = BitmapDescriptor.defaultMarker;
    super.initState();
    DefaultAssetBundle.of(context).loadString('assets/maptheme/night_theme.json').then((value) => {
          mapTheme = value
        });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  //Notification systems
  void initNotifications() async {
    print("INIT NOTIF");
    WidgetsFlutterBinding.ensureInitialized();
    final NotificationService notificationService = NotificationService();
    await notificationService.init();

    final CollectionReference collectionReference = FirebaseFirestore.instance.collection('emergencies');

    collectionReference.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          final String civName = change.doc.get('Civilian');
          final String civAddress = change.doc.get('Address');
          final String emergencyType = change.doc.get('Type');
          if (_role == "Responder") {
            notificationService.showNotification('$civName needs your help!', 'Type: $emergencyType\n$civName is somewhere near $civAddress');
          }
        }
      });
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

  //Determines the coordinates
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

  //Uses GECODING API
  Future<void> convertCoordsToAddress(Position position) async {
    List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemark[0];
    setState(() {
      _address = '${place.name} ${place.administrativeArea} ${place.subAdministrativeArea} ${place.locality} ${place.subLocality} ${place.subThoroughfare}';
    });
  }

  //Checks whether a responded is currently responding to someone
  Future<void> checkCivID() async {
    Stream<DocumentSnapshot> stream = FirebaseFirestore.instance.collection('users').doc(_emailAddress).snapshots();
    stream.listen((documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
        var resCivID = data?['Responded Civilian ID'];
        if (resCivID != null) {
          print("THIS WORKS LA");
          setState(() {
            _markerSelected = resCivID;
            _userResponded = true;
          });
        } else if (resCivID == null) {
          print("THIS NOT WORKS LA");
          setState(() {
            _userResponded = false;
            _civResponded = 0;
            _markerSelected = 0;
          });
        }
      }
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
        final emergency = FirebaseFirestore.instance.collection('emergencies').doc(_civEmailAddress);
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

  bool _fireEmergencyFiltered = true;
  bool _healthEmergencyFiltered = true;
  bool _deathEmergencyFiltered = true;
  bool _assaultEmergencyFiltered = true;
  bool _floodEmergencyFiltered = true;
  bool _earthquakeEmergencyFiltered = true;
  bool _vehicularEmergencyFiltered = true;
  bool _shootingEmergencyFiltered = true;
  bool _alertEmergencyFiltered = true;

  bool _userResponded = false;

  late String _emailAddress = "";
  late String _civEmailAddress = "";
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
  late String _role = "";

  late int _markerSelected = 0;
  late int _civResponded = 0;

  //MAP STUFF
  late GoogleMapController mapController;
  late BitmapDescriptor userIcon;
  static const String googleApiKey = "AIzaSyAy5qAZpPfEk8QFs8BGXUvq8Gd1MFHKo0o";

  double calculateZoomLevel(double distance) {
    if (distance <= 0.01) {
      return 18;
    } else if (distance <= 0.05) {
      return 15;
    } else if (distance <= 0.1) {
      return 13;
    } else if (distance <= 0.5) {
      return 10;
    } else if (distance <= 1.0) {
      return 8;
    } else {
      return 6;
    }
  }

  //Filter emergency types
  List<String> filteredEmergencies = [
    'Fire Emergency',
    'Health Emergency',
    'Death Emergency',
    'Assault Emergency',
    'Flood Emergency',
    'Earthquake Emergency',
    'Vehicular Emergency',
    'Shooting Emergency',
    'Alert Emergency'
  ];

  void filterChecker(String type) {
    if (filteredEmergencies.contains(type)) {
      filteredEmergencies.remove(type);
    } else {
      filteredEmergencies.add(type);
    }
    setState(() {});
  }

  //Getting polyline from source and dest markers
  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    print("USER:" + _userLatitude.toString() + " " + _userLongitude.toString());
    print("CIV:" + _civLatitude.toString() + " " + _civLongitude.toString());
    print("POINTS: " + polylineCoordinates.toList().toString());
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(_userLatitude, _userLongitude),
      PointLatLng(_civLatitude, _civLongitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    } else {
      print("Error getting route: ${result.errorMessage}");
    }
  }

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

  BitmapDescriptor fireIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor healthIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor deathIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor assaultIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor floodIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor earthquakeIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor vehicularIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor shootingIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor alertIcon = BitmapDescriptor.defaultMarker;

  BitmapDescriptor _getMarkerIcon(String emergencyType) {
    switch (emergencyType) {
      case 'Fire Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/fire_icon.png').then((Icon) => {
              fireIcon = Icon
            });
        return fireIcon;
      case 'Health Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/health_icon.png').then((Icon) => {
              healthIcon = Icon
            });
        return healthIcon;
      case 'Death Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/death_icon.png').then((Icon) => {
              deathIcon = Icon
            });
        return deathIcon;
      case 'Assault Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/assault_icon.png').then((Icon) => {
              assaultIcon = Icon
            });
        return assaultIcon;
      case 'Flood Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/flood_icon.png').then((Icon) => {
              floodIcon = Icon
            });
        return floodIcon;
      case 'Earthquake Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/earthquake_icon.png').then((Icon) => {
              earthquakeIcon = Icon
            });
        return earthquakeIcon;
      case 'Vehicular Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/vehicular_icon.png').then((Icon) => {
              vehicularIcon = Icon
            });
        return vehicularIcon;
      case 'Shooting Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/shooting_icon.png').then((Icon) => {
              shootingIcon = Icon
            });
        return shootingIcon;
      case 'Alert Emergency':
        ImageConfiguration configuration = createLocalImageConfiguration(context);
        BitmapDescriptor.fromAssetImage(configuration, 'assets/alert_icon.png').then((Icon) => {
              alertIcon = Icon
            });
        return alertIcon;
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

  Future updateUserLocation() async {
    await getCurrentLocation();
  }

  void showEmergencyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
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
                                    color: Color.fromRGBO(70, 18, 32, 1),
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   right: 20,
                              //   child: IconButton(
                              //     onPressed: () {
                              //       Navigator.of(context).pop();
                              //     },
                              //     icon: Icon(Icons.close),
                              //   ),
                              // ),
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

                                          var collection = FirebaseFirestore.instance.collection('emergencies');
                                          var docReference = collection.doc(snap[_markerSelected]['Email Address']);

                                          var users = FirebaseFirestore.instance.collection('users');
                                          var usersDocReference = users.doc(_emailAddress);

                                          Marker civMarker = Marker(
                                            markerId: MarkerId(_civCoordinates),
                                            position: LatLng(_civLatitude, _civLongitude),
                                            icon: _getMarkerIcon(snap[_markerSelected]['Type']),
                                          );

                                          Marker userMarker = Marker(
                                            markerId: MarkerId(_userCoordinates),
                                            position: LatLng(_userLatitude, _userLongitude),
                                            icon: userIcon,
                                          );

                                          Set<Marker> markers = Set<Marker>.from([
                                            civMarker,
                                            userMarker
                                          ]);

                                          docReference.snapshots().listen((docSnapshot) async {
                                            if (!docSnapshot.exists) {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                _markerSelected = 0;
                                                _civResponded = 0;
                                              });
                                              await usersDocReference.update({
                                                'Responded Civilian ID': FieldValue.delete()
                                              });
                                            }
                                          });

                                          _civEmailAddress = snap[_markerSelected]['Email Address'];

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
                                                      SizedBox(height: 10.h),
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
                                                              "Somewhere near " + snap[_markerSelected]['Address'],
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
                                                      polylines: {
                                                        Polyline(
                                                          polylineId: PolylineId("route"),
                                                          points: polylineCoordinates,
                                                        ),
                                                      },
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(70, 18, 32, 1),
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
                  height: 400.h,
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
                            print(filteredEmergencies);
                            setState(() {
                              _fireEmergencyFiltered = !_fireEmergencyFiltered;
                              filterChecker('Fire Emergency');
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
                                          Icons.radio_button_off,
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
                              filterChecker('Health Emergency');
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
                                          Icons.radio_button_off,
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
                              _deathEmergencyFiltered = !_deathEmergencyFiltered;
                              filterChecker('Death Emergency');
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _deathEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.cyan,
                                        )
                                      : Icon(
                                          Icons.radio_button_off,
                                          color: Colors.cyan,
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Death Emergency",
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
                              filterChecker('Assault Emergency');
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
                                          Icons.radio_button_off,
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
                              filterChecker('Flood Emergency');
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
                                          Icons.radio_button_off,
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
                              filterChecker('Earthquake Emergency');
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
                                          Icons.radio_button_off,
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
                              _vehicularEmergencyFiltered = !_vehicularEmergencyFiltered;
                              filterChecker('Vehicular Emergency');
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _vehicularEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Color.fromRGBO(255, 0, 85, 1),
                                        )
                                      : Icon(
                                          Icons.radio_button_off,
                                          color: Color.fromRGBO(255, 0, 85, 1),
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Vehicular Emergency",
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
                              _shootingEmergencyFiltered = !_shootingEmergencyFiltered;
                              filterChecker('Shooting Emergency');
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _shootingEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Color.fromRGBO(138, 43, 226, 1),
                                        )
                                      : Icon(
                                          Icons.radio_button_off,
                                          color: Color.fromRGBO(138, 43, 226, 1),
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Shooting Emergency",
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
                              _alertEmergencyFiltered = !_alertEmergencyFiltered;
                              filterChecker('Alert Emergency');
                            });
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  _alertEmergencyFiltered
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.yellow,
                                        )
                                      : Icon(
                                          Icons.radio_button_off,
                                          color: Colors.yellow,
                                        ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    "Alert Emergency",
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
    FloatingActionButton legendFAB = FloatingActionButton.extended(
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
        Icons.legend_toggle,
        color: Colors.black,
      ),
    );

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
        floatingActionButton: Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  legendFAB,
                  SizedBox(height: 10.h)
                ],
              ),
            ],
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
                                    _role = userData['Role'];
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

                                            Set<Marker> _markers = {};
                                            List<LatLng> coordinatesList = [];

                                            for (var i = 0; i < snap.length; i++) {
                                              _civEmergencyType = snap[i]['Type'];
                                              _civCoordinates = snap[i]['Coordinates'];
                                              _civLatitude = double.parse(_civCoordinates.split('Latitude: ')[1].split(',')[0]);
                                              _civLongitude = double.parse(_civCoordinates.split('Longitude: ')[1]);
                                              LatLng _civCoordinate = LatLng(_civLatitude, _civLongitude);
                                              LatLng _userCoordinate = LatLng(_userLatitude, _userLongitude);

                                              Marker userMarker = Marker(
                                                markerId: MarkerId(_userCoordinate.toString()),
                                                position: _userCoordinate,
                                                icon: userIcon,
                                              );

                                              Marker civMarker = Marker(
                                                markerId: MarkerId(_civEmergencyType.toString() + '' + i.toString()),
                                                position: _civCoordinate,
                                                icon: _getMarkerIcon(
                                                  _civEmergencyType,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    _markerSelected = i;
                                                  });

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
                                                                                        'Death Emergency': FontAwesomeIcons.solidFaceDizzy,
                                                                                        'Assault Emergency': FontAwesomeIcons.handFist,
                                                                                        'Flood Emergency': FontAwesomeIcons.water,
                                                                                        'Earthquake Emergency': FontAwesomeIcons.houseChimneyCrack,
                                                                                        'Vehicular Emergency': FontAwesomeIcons.carBurst,
                                                                                        'Shooting Emergency': FontAwesomeIcons.userNinja,
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
                                                                                                        "Somewhere near " + snap[_markerSelected]['Address'],
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
                                                                          disabledBackgroundColor: Colors.orange,
                                                                          backgroundColor: Color.fromRGBO(70, 18, 32, 1),
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                                                                          ),
                                                                          padding: EdgeInsets.all(12),
                                                                        ),
                                                                        onPressed: snap[_markerSelected]["Status"] == "Confirmed"
                                                                            ? null
                                                                            : () async {
                                                                                // getPolyPoints();

                                                                                _civResponded = _markerSelected;

                                                                                var emergencies = FirebaseFirestore.instance.collection('emergencies');
                                                                                var docReference = emergencies.doc(snap[_civResponded]['Email Address']);

                                                                                var users = FirebaseFirestore.instance.collection('users');
                                                                                var usersDocReference = users.doc(_emailAddress);

                                                                                await docReference.update({
                                                                                  'Status': 'Confirmed',
                                                                                  'Responder': _fullName,
                                                                                  'Responder Contact Number': _contactNumber,
                                                                                  'Responder Occupation': _occupation,
                                                                                  'Responder Employer': _employer,
                                                                                });

                                                                                await usersDocReference.update({
                                                                                  'Responded Civilian ID': _civResponded
                                                                                });

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
                                                                                      snap[_markerSelected]["Status"] == "Confirmed" ? "Ongoing" : "Respond",
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
                                              coordinatesList.add(_civCoordinate);
                                              coordinatesList.add(_userCoordinate);
                                              // _markers.add(civMarker);
                                              _markers.add(civMarker);
                                              if (!filteredEmergencies.contains(civMarker.markerId.value.replaceAll(RegExp(r'[0-9]+'), ''))) {
                                                _markers.removeWhere((notFilteredMarker) => notFilteredMarker.markerId.value == civMarker.markerId.value);
                                                print("REMOVE IT BUI");
                                              }
                                              _markers.add(userMarker);
                                            }
                                            for (LatLng coordinates in coordinatesList) {
                                              _totalLatitude += coordinates.latitude;
                                              _totalLongitude += coordinates.longitude;
                                            }

                                            //WHOLE MAP HERE
                                            return Container(
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
                                                    child: Container(
                                                      child: Stack(
                                                        children: [
                                                          GoogleMap(
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
                                                          Visibility(
                                                            visible: _userResponded,
                                                            child: Align(
                                                              alignment: Alignment.topCenter,
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    showEmergencyDetails(context);
                                                                  },
                                                                  child: Container(
                                                                    width: MediaQuery.of(context).size.width,
                                                                    height: 60.h,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(100),
                                                                      border: Border.all(
                                                                        color: Color.fromRGBO(82, 82, 82, 1),
                                                                        width: 1,
                                                                      ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors.black.withOpacity(0.2),
                                                                          offset: Offset(0, 2),
                                                                          blurRadius: 4,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        SizedBox(width: 10.w),
                                                                        Text(
                                                                          'Responding to:   ${snap[_markerSelected]["Civilian"].toString()}',
                                                                          style: TextStyle(
                                                                            fontSize: snap[_markerSelected]["Civilian"].toString().length >= 15 ? 12.sp : 16.sp,
                                                                            fontWeight: FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 20.w),
                                                                        Icon(
                                                                          Icons.more_horiz,
                                                                          color: Colors.black,
                                                                          size: 15,
                                                                        ),
                                                                        SizedBox(width: 10.w),
                                                                      ],
                                                                    ),
                                                                  ),
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
