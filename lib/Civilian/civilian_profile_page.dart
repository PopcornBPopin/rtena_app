import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rtena_app/Civilian/civilian_start_page.dart';

class CivProfilePage extends StatefulWidget {
  const CivProfilePage({Key? key}) : super(key: key);

  @override
  State<CivProfilePage> createState() => _CivProfilePageState();
}

class _CivProfilePageState extends State<CivProfilePage> {
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

  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  bool _hasInternet = false;

  late StreamSubscription subscription;
  late String _emailAddress = "";
  late String _firstName = "";
  late String _midInit = "";
  late String _surname = "";
  late String _contactNumber = "";
  late String _birthdate = "";
  late int _age = 0;
  late String _sex = "";
  late String _bloodtype = "";
  late String _permanentAddress = "";
  late String _homeAddress = "";
  late String _role = "";

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

  //Grab user document from Firebase Firestone
  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    _emailAddress = user!.email!;

    print("Hello " + _emailAddress);
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_emailAddress).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      _firstName = userData['First Name'];
      _midInit = userData['M.I'];
      _surname = userData['Surname'];
      _contactNumber = userData['Contact Number'];
      _birthdate = userData['Birthdate'];
      _age = userData['Age'];
      _sex = userData['Sex'];
      _bloodtype = userData['Bloodtype'];
      _permanentAddress = userData['Permanent Address'];
      _homeAddress = userData['Home Address'];
    }
  }

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
        Navigator.of(context).pop();
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
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(CivStartPage());
                                      },
                                      child: Text(
                                        'Your Profile',
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
                                      'Want to edit your personal details?',
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
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance.collection('users').doc(_emailAddress).snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Container(
                                                color: Colors.transparent,
                                                height: 1000.h,
                                              );
                                            }
                                            final userData = snapshot.data!.data() as Map<String, dynamic>;
                                            _firstName = userData['First Name'];
                                            _midInit = userData['M.I'];
                                            _surname = userData['Surname'];
                                            _contactNumber = userData['Contact Number'];
                                            _birthdate = userData['Birthdate'];
                                            _age = userData['Age'];
                                            _sex = userData['Sex'];
                                            _bloodtype = userData['Bloodtype'];
                                            _permanentAddress = userData['Permanent Address'];
                                            _homeAddress = userData['Home Address'];
                                            _role = userData['Role'];
                                            return Column(
                                              children: [
                                                SizedBox(height: 20.h),
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Text(
                                                      '$_role Account',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 20.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 20.h),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      autofocus: false,
                                                      readOnly: true,
                                                      initialValue: _emailAddress,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Email Address',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.email_outlined,
                                                          color: Color.fromRGBO(252, 58, 72, 32),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      autofocus: false,
                                                      readOnly: true,
                                                      initialValue: '$_firstName $_midInit $_surname',
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Full Name',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.person,
                                                          color: Color.fromRGBO(252, 58, 72, 32),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      autofocus: false,
                                                      readOnly: true,
                                                      initialValue: _contactNumber,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Contact Number',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.phone_android_outlined,
                                                          color: Color.fromRGBO(252, 58, 72, 32),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          child: TextFormField(
                                                            autofocus: false,
                                                            readOnly: true,
                                                            initialValue: _birthdate,
                                                            cursorColor: Colors.grey.shade600,
                                                            decoration: const InputDecoration(
                                                              contentPadding: EdgeInsets.all(10),
                                                              labelText: 'Birthdate',
                                                              labelStyle: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                              prefixIcon: Icon(
                                                                Icons.cake,
                                                                color: Color.fromRGBO(252, 58, 72, 32),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Expanded(
                                                        child: Container(
                                                          child: TextFormField(
                                                            autofocus: false,
                                                            readOnly: true,
                                                            initialValue: _age.toString(),
                                                            cursorColor: Colors.grey.shade600,
                                                            decoration: const InputDecoration(
                                                              contentPadding: EdgeInsets.all(10),
                                                              labelText: 'Age',
                                                              labelStyle: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: TextFormField(
                                                            autofocus: false,
                                                            readOnly: true,
                                                            initialValue: _sex,
                                                            cursorColor: Colors.grey.shade600,
                                                            decoration: const InputDecoration(
                                                              contentPadding: EdgeInsets.all(10),
                                                              labelText: 'Sex',
                                                              labelStyle: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                              prefixIcon: Icon(
                                                                Icons.male,
                                                                color: Color.fromRGBO(252, 58, 72, 32),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Expanded(
                                                        child: Container(
                                                          child: TextFormField(
                                                            autofocus: false,
                                                            readOnly: true,
                                                            initialValue: _bloodtype,
                                                            cursorColor: Colors.grey.shade600,
                                                            decoration: const InputDecoration(
                                                              contentPadding: EdgeInsets.all(10),
                                                              labelText: 'Bloodtype',
                                                              labelStyle: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                              prefixIcon: Icon(
                                                                Icons.bloodtype,
                                                                color: Color.fromRGBO(252, 58, 72, 32),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0),
                                                                ),
                                                                borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      autofocus: false,
                                                      readOnly: true,
                                                      initialValue: _permanentAddress,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Permanent Address',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.location_on_outlined,
                                                          color: Color.fromRGBO(252, 58, 72, 32),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      autofocus: false,
                                                      readOnly: true,
                                                      initialValue: _homeAddress,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Home Address',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.location_on_outlined,
                                                          color: Color.fromRGBO(252, 58, 72, 32),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 70.h),
                                                // Text("First Name: $_firstName"),
                                                // Text("Middle Initial: $_midInit"),
                                                // Text("Surname: $_surname"),
                                                // Text("Contact Number: $_contactNumber"),
                                                // Text("Birthdate: $_birthdate"),
                                                // Text("Age: $_age"),
                                                // Text("Sex: $_sex"),
                                                // Text("Bloodtype: $_bloodtype"),
                                                // Text("Permanent Address: $_permanentAddress"),
                                                // Text("Home Address: $_homeAddress"),
                                              ],
                                            );
                                          },
                                        ),
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
