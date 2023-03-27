import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rtena_app/Civilian/civilian_home_page.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/start_page.dart';

class Sign1Page extends StatefulWidget {
  const Sign1Page({Key? key}) : super(key: key);
  @override
  State<Sign1Page> createState() => _Sign1PageState();
}

class _Sign1PageState extends State<Sign1Page> {
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
    ]);
  }

  ConnectivityResult result = ConnectivityResult.none;

  File? _validID;

  var _sexSelected;
  var _bloodtypeSelected;

  bool acceptedTermsCondition = false;

  late String imageURL;
  late StreamSubscription subscription;

  bool _civIsPressed = false;
  bool _resIsPressed = false;
  bool _roleNotSelected = false;
  bool _passwordHidden = true;
  bool _confPasswordHidden = true;
  bool _birthdateSelected = false;
  bool _emailExists = false;
  bool _validIDSelected = false;
  bool _validIDNotSelected = false;
  bool _hasInternet = false;
  bool _agreeTerms = false;
  bool _agreePriv = false;

  final _formKey = GlobalKey<FormState>();
  final RegExp _validPass = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  final RegExp _validEmail = RegExp(r"^[a-zA-Z0-9.]+@[a-z0-9]+\.[a-z]+");
  final _bloodtypeChoice = [
    "A+",
    "B+",
    "AB+",
    "A-",
    "B-",
    "AB-",
    "O+",
    "O-"
  ];
  final _sexChoice = [
    "Male",
    "Female"
  ];

  DateTime _currentDate = DateTime.now();
  final _monthName = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  // Text Controllers
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confPasswordController = TextEditingController();
  final _surnameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _midInitController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _sexController = TextEditingController();
  final _bloodtypeController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _stationAddressController = TextEditingController();
  final _employerController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _homeAddressController = TextEditingController();

  //Snackbar
  final notConnectedSnackbar = SnackBar(
    content: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 25,
            color: Colors.white,
          ),
          Expanded(
            child: Center(
              child: Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: Colors.black,
    duration: Duration(seconds: 5),
    behavior: SnackBarBehavior.fixed,
    elevation: 1,
  );

  final connectedSnackbar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_outlined,
          size: 25,
          color: Colors.green,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Connection Restored',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.black,
    duration: Duration(seconds: 5),
    behavior: SnackBarBehavior.fixed,
    elevation: 1,
  );

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

  //FUNCTIONS

  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        _hasInternet = await InternetConnectionChecker().hasConnection;
        if (!_hasInternet) {
          print("No internet");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(notConnectedSnackbar);
        } else {
          print("Connected");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(connectedSnackbar);
        }
      },
    );
  }

  //Calendar Theme
  final ThemeData theme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color.fromRGBO(252, 58, 72, 1),
      surface: Color.fromRGBO(70, 18, 32, 1),
    ),
    dialogBackgroundColor: Color.fromRGBO(70, 18, 32, 1),
    textTheme: TextTheme(
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    ),
  );

  //Show calendar
  Future<void> _showBirthdatePicker() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );
    setState(() {
      _birthdateSelected = true;
      _currentDate = newDate!;
      _birthdateController.text = "${_monthName[_currentDate.month - 1]} ${_currentDate.day} ${_currentDate.year}";
      _ageController.text = _currentDate.month <= DateTime.now().month
          ? _currentDate.day <= DateTime.now().day
              ? "${(DateTime.now()).year - _currentDate.year}"
              : "${(DateTime.now()).year - _currentDate.year - 1}"
          : "${(DateTime.now()).year - _currentDate.year - 1}";
    });
    if (newDate == null) return;
  }

  //Show success prompt
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
        if (animtype == QuickAlertType.success)
          Get.to(
            () => const CivHomePage(),
            transition: Transition.fadeIn,
            duration: Duration(milliseconds: 300),
          );
        else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  void showTermsCond(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.3),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    SizedBox(height: 15.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        child: Icon(
                          Icons.check,
                          size: 100,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        child: const Text(
                          "Terms & conditions",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black, fontSize: 45, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "I. Introduction",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        "   This is a seniors' project of the developers Eniceo, Mora, Pacis. It is a partial compliance to their course's final requirement. The mobile application's, and its other components', intention is to create an accessible and convenient means of communicating with responders of your current situation. That being sais, the mobile application requires your permission with your mobile device's: \n\nFinal State (Location, Mobile Date, WiFi, Phone) \n\nInitiation State (Camera, Library or Files Manager)\n\n",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                      ),
                                      const Text(
                                        "II. Permissions Terms",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        "   Location - It is to determine your mobile device's accurate location, should an incident happen to you and you accessed our mobile app. WiFi/Mobile Data - It is to override your internet connection if you (a) are not connected to the internet, or (b) have a slow internet connection through WiFi. Your internet connection is needed to update our database with your current location, if it would be done online. Phone - It is to update our database with your current location, if it would be done offline. We are using GSM technologies to cater offline means of communicating. Camera - It is to take a picture of your valid ID.Library/Files Manager - It is if, instead, you want to find your valid ID in your files\n\n",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                      ),
                                      const Text(
                                        "III. Privacy Terms",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        "   We collect your personal information for the sole purpose of relaying that information to a responder, should you encounter an incident that requires it. Your personal information will only be read-and-write accessible (editable) by the servers and developers of the mobile application and its components. Your personal information is also to ensure liability and accountability of your actions.\n\n",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                      ),
                                      const Text(
                                        "IV. Agreement",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        "   By checking the boxes below, you agree with allowing access permissions on your mobile phone and collecting your data\n",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _agreeTerms = !_agreeTerms;
                                          });
                                        },
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
                    SizedBox(height: 20.h)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Select picture to upload
  void choosePicture(BuildContext context) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.grey.shade300,
      context: context,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width,
        height: 150.h,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.white,
              ),
              child: Container(
                alignment: Alignment.center,
                height: 60.h,
                width: 130.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              onPressed: () async {
                grabPhoto(ImageSource.camera);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.white,
              ),
              child: Container(
                alignment: Alignment.center,
                height: 60.h,
                width: 130.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.landscape,
                      color: Colors.black,
                    ),
                    const Text(
                      "Gallery",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              onPressed: () async {
                grabPhoto(ImageSource.gallery);
              },
            )
          ],
        ),
      ),
    );
  }

  //Grab the picture
  Future grabPhoto(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final selectedImage = File(image.path);

      setState(
        () {
          this._validID = selectedImage;
          _validIDSelected = true;
        },
      );
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  //Writing user details to Firestone DB
  Future addUserDetails(
    String emailAddress,
    String roleOfUser,
    String surname,
    String firstName,
    String mInit,
    String contactNumber,
    String bDate,
    int age,
    String sex,
    String bloodtype,
    String occupation,
    String stationAddress,
    String employer,
    String permanentAddress,
    String homeAddress,
    String validIDURL,
  ) async {
    await FirebaseFirestore.instance.collection('users').add({
      'Email Address': emailAddress,
      'Role': roleOfUser,
      'Surname': surname,
      'First Name': firstName,
      'M.I': mInit,
      'Contact Number': contactNumber,
      'Birthdate': bDate,
      'Age': age,
      'Sex': sex,
      'Bloodtype': bloodtype,
      'Occupation': occupation,
      'Station Address': stationAddress,
      'Employer': employer,
      'Permanent Address': permanentAddress,
      'Home Address': homeAddress,
      'Valid ID': validIDURL,
    });
  }

  //Sign up
  Future SignUp() async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirValidIDs = referenceRoot.child("${_firstNameController.text.trim()} ${_surnameController.text.trim()} ValidID");

    quickAlert(QuickAlertType.loading, "Standby!", "Uploading your data to our database", Colors.blue);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      Navigator.of(context).pop();
      quickAlert(QuickAlertType.error, "Authentication Failed!", "Email you have entered already exists", Colors.red);
      print("Email you have entered already exists");
      return;
    }
    print("Added user to auth");

    await referenceDirValidIDs.putFile(_validID!);
    imageURL = await referenceDirValidIDs.getDownloadURL();
    print("Stored image to storage");

    //Add user details
    addUserDetails(
      _emailController.text.trim(),
      _roleController.text.trim(),
      _surnameController.text.trim(),
      _firstNameController.text.trim(),
      _midInitController.text.trim(),
      _contactNumberController.text.trim(),
      _birthdateController.text.trim(),
      int.parse(_ageController.text.trim()),
      _sexController.text.trim(),
      _bloodtypeController.text.trim(),
      _occupationController.text.trim(),
      _stationAddressController.text.trim(),
      _employerController.text.trim(),
      _permanentAddressController.text.trim(),
      _homeAddressController.text.trim(),
      imageURL,
    );
    print("Added user deets to firestone");

    Navigator.of(context).pop();
    quickAlert(QuickAlertType.success, "Registration Successful!", "You are successfully registered", Colors.green);
  }

  //Disposes controller when not in used
  @override
  void dispose() {
    subscription.cancel();
    _roleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confPasswordController.dispose();
    _surnameController.dispose();
    _firstNameController.dispose();
    _midInitController.dispose();
    _occupationController.dispose();
    _stationAddressController.dispose();
    _employerController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _bloodtypeController.dispose();
    _contactNumberController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Color.fromRGBO(252, 58, 72, 1),
            Color.fromRGBO(70, 18, 32, 1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          //Scrollview starts here
          child: Column(
            // itemExtent: screenSize,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            top: 40,
                            left: 30,
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                  () => const StartPage(),
                                  transition: Transition.fadeIn,
                                  duration: Duration(milliseconds: 300),
                                );
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          // RTENA LOGO
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
                                  SizedBox(height: 100.h),
                                  //Register Title String
                                  Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 37.sp,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  //Substring
                                  Text(
                                    'Ready to become a member?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      //Form starts here
                      Form(
                        key: _formKey,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                                spreadRadius: 7,
                                blurRadius: 10,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 30.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Button for Civilian
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // side: BorderSide(width: 1.5, color: _roleNotSelected ? Colors.red : Color.fromRGBO(255, 255, 255, 0)),
                                      backgroundColor: _civIsPressed ? Color.fromRGBO(252, 58, 72, 32) : Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: _roleNotSelected
                                              ? Color.fromRGBO(252, 58, 72, 32)
                                              : _civIsPressed
                                                  ? Color.fromRGBO(252, 58, 72, 32)
                                                  : Color.fromRGBO(82, 82, 82, 1),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _civIsPressed = true;
                                        _resIsPressed = false;
                                        _roleNotSelected = false;
                                        _roleController.text = 'Civilian';
                                        showTermsCond(context);
                                      });
                                    },
                                    child: SizedBox(
                                      height: 100.h,
                                      width: 165.w,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people,
                                              color: _civIsPressed ? Colors.white : Colors.red,
                                              size: 40,
                                            ),
                                            Text(
                                              "Civilian",
                                              style: TextStyle(color: _civIsPressed ? Colors.white : Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10.w),

                                  //Button for Respondents
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // side: BorderSide(width: 1.5, color: _roleNotSelected ? Colors.red : Color.fromRGBO(255, 255, 255, 0)),
                                      backgroundColor: _resIsPressed ? Color.fromRGBO(252, 58, 72, 32) : Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: _roleNotSelected
                                              ? Color.fromRGBO(252, 58, 72, 32)
                                              : _resIsPressed
                                                  ? Color.fromRGBO(252, 58, 72, 32)
                                                  : Color.fromRGBO(82, 82, 82, 1),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _resIsPressed = true;
                                        _civIsPressed = false;
                                        _roleNotSelected = false;
                                        _roleController.text = 'Responder';
                                      });
                                    },
                                    child: SizedBox(
                                      height: 100.h,
                                      width: 165.w,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 15.h),
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.emergency,
                                                color: _resIsPressed ? Colors.white : Colors.red,
                                                size: 40,
                                              ),
                                              Text(
                                                "Responder",
                                                style: TextStyle(color: _resIsPressed ? Colors.white : Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),

                              Visibility(
                                visible: _roleNotSelected,
                                child: Text(
                                  'Please select a role',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(height: 10.h),

                              //Email address Text field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Container(
                                  child: TextFormField(
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty || !_validEmail.hasMatch(val)) {
                                        return 'Please enter a valid email';
                                      } else if (_emailExists) {
                                        return 'Email Address is already taken';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    controller: _emailController,
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Password Text Field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Container(
                                  child: TextFormField(
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter a valid password';
                                      } else if (!_validPass.hasMatch(val)) {
                                        return 'Must have an uppercase and lowercase letters,\na number, and a special character';
                                      } else if (val.length < 8) {
                                        return 'Must be at least 8 characters';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    obscureText: _passwordHidden,
                                    controller: _passwordController,
                                    cursorColor: Colors.grey.shade600,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Color.fromRGBO(252, 58, 72, 32),
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _passwordHidden = !_passwordHidden;
                                          });
                                        },
                                        child: _passwordHidden
                                            ? const Icon(
                                                Icons.visibility_off,
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                              )
                                            : const Icon(
                                                Icons.visibility,
                                                color: Color.fromRGBO(252, 58, 72, 32),
                                              ),
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Confirm Password Text Field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Container(
                                  child: TextFormField(
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter a valid password';
                                      } else if (val != _passwordController.text) {
                                        return 'Password does not match';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    obscureText: _confPasswordHidden,
                                    controller: _confPasswordController,
                                    cursorColor: Colors.grey.shade600,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      labelText: 'Confirm Password',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Color.fromRGBO(252, 58, 72, 32),
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _confPasswordHidden = !_confPasswordHidden;
                                          });
                                        },
                                        child: _confPasswordHidden
                                            ? const Icon(
                                                Icons.visibility_off,
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                              )
                                            : const Icon(
                                                Icons.visibility,
                                                color: Color.fromRGBO(252, 58, 72, 32),
                                              ),
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 30.w),
                                  child: Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),

                              //Full Name Text Field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Row(
                                  children: [
                                    //Surname Text Field
                                    Flexible(
                                      flex: 5,
                                      child: Container(
                                        child: TextFormField(
                                          validator: (String? val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Empty surname';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          autofocus: false,
                                          textCapitalization: TextCapitalization.words,
                                          controller: _surnameController,
                                          cursorColor: Colors.grey.shade600,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(10),
                                            labelText: 'Surname',
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
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),

                                    //First Name Text Field
                                    Flexible(
                                      flex: 5,
                                      child: Container(
                                        child: TextFormField(
                                          validator: (String? val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Empty first name';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          autofocus: false,
                                          textCapitalization: TextCapitalization.words,
                                          controller: _firstNameController,
                                          cursorColor: Colors.grey.shade600,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(10),
                                            labelText: 'First Name',
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
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),

                                    //Middle Initial Text Field
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        child: TextFormField(
                                          validator: (String? val) {
                                            if (val == null || val.isEmpty) {
                                              return 'M.I';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          autofocus: false,
                                          textCapitalization: TextCapitalization.words,
                                          controller: _midInitController,
                                          cursorColor: Colors.grey.shade600,
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(10),
                                            labelText: 'M.I',
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
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //Contact Number Text Field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Container(
                                  child: TextFormField(
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter a valid contact number';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    controller: _contactNumberController,
                                    cursorColor: Colors.grey.shade600,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      labelText: 'Contact Number',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      prefixIcon: const Icon(
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Birthdate and Age Selector
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Birthdate Selector
                                    Flexible(
                                      flex: 4,
                                      child: Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            _showBirthdatePicker();
                                          },
                                          child: Container(
                                            child: TextFormField(
                                              validator: (String? val) {
                                                if (_birthdateController.text.isEmpty || int.parse(_ageController.text) <= 4) {
                                                  return 'Please enter your birthdate';
                                                }
                                                return null;
                                              },
                                              enabled: false,
                                              autofocus: false,
                                              controller: _birthdateController,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.all(10),
                                                labelText: "Birthdate",
                                                labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                                prefixIcon: const Icon(
                                                  Icons.cake_outlined,
                                                  color: Color.fromRGBO(252, 58, 72, 32),
                                                ),
                                                disabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                  borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                  borderSide: BorderSide(color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),

                                    //Age Text field
                                    Flexible(
                                      flex: 3,
                                      child: Container(
                                        child: TextFormField(
                                          validator: (String? val) {
                                            if (!_birthdateSelected) {
                                              return 'Enter your Birthdate';
                                            } else if (int.parse(_ageController.text) <= 4) {
                                              return 'Invalid Age';
                                            }
                                            return null;
                                          },
                                          readOnly: true,
                                          enabled: true,
                                          autofocus: false,
                                          controller: _ageController,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(10),
                                            labelText: "Age",
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
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //Sex and Bloodtype Field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Row(
                                  children: [
                                    //Sex Dropdown
                                    Flexible(
                                      flex: 3,
                                      child: Container(
                                        child: DropdownButtonFormField<String>(
                                          validator: (String? val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Select your sex';
                                            }
                                            return null;
                                          },
                                          value: _sexSelected,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(10),
                                            labelText: "Sex",
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                            prefixIcon: _sexController.text == 'Male'
                                                ? const Icon(
                                                    Icons.male_outlined,
                                                    color: Color.fromRGBO(252, 58, 72, 32),
                                                  )
                                                : const Icon(
                                                    Icons.female_outlined,
                                                    color: Color.fromRGBO(252, 58, 72, 32),
                                                  ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                          items: _sexChoice.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _sexController.text = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),

                                    //Bloodtype Dropdown
                                    Flexible(
                                      flex: 3,
                                      child: Container(
                                        child: DropdownButtonFormField<String>(
                                          validator: (String? val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Select your bloodtype';
                                            }
                                            return null;
                                          },
                                          value: _bloodtypeSelected,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(10),
                                            labelText: "Bloodtype",
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.bloodtype_outlined,
                                              color: Color.fromRGBO(252, 58, 72, 32),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(
                                                color: Color.fromRGBO(82, 82, 82, 1),
                                                width: 1,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                          items: _bloodtypeChoice.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _bloodtypeController.text = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //Occupation Text Field
                              Visibility(
                                visible: _resIsPressed,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                  child: Container(
                                    child: TextFormField(
                                      validator: (String? val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please enter your occupation';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      autofocus: false,
                                      textCapitalization: TextCapitalization.words,
                                      controller: _occupationController,
                                      cursorColor: Colors.grey.shade600,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        labelText: 'Occupation',
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.work_outline,
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
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Station Address Text Field
                              Visibility(
                                visible: _resIsPressed,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                  child: Container(
                                    child: TextFormField(
                                      validator: (String? val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please enter your station address';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      autofocus: false,
                                      textCapitalization: TextCapitalization.words,
                                      controller: _stationAddressController,
                                      cursorColor: Colors.grey.shade600,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        labelText: 'Station Address',
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.work_outline,
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
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Employer Text Field
                              Visibility(
                                visible: _resIsPressed,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                  child: Container(
                                    child: TextFormField(
                                      validator: (String? val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please enter your employer';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      autofocus: false,
                                      textCapitalization: TextCapitalization.words,
                                      controller: _employerController,
                                      cursorColor: Colors.grey.shade600,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        labelText: 'Employer',
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.work_outline,
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
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Permanent Address Text field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Container(
                                  child: TextFormField(
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter your permanent address';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    textCapitalization: TextCapitalization.words,
                                    controller: _permanentAddressController,
                                    cursorColor: Colors.grey.shade600,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      labelText: 'Permanent Address',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      prefixIcon: const Icon(
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Home Address Text field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                child: Container(
                                  child: TextFormField(
                                    validator: (String? val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter your home address';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    autofocus: false,
                                    textCapitalization: TextCapitalization.words,
                                    controller: _homeAddressController,
                                    cursorColor: Colors.grey.shade600,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      labelText: 'Home Address',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      prefixIcon: const Icon(
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),

                              //Upload a picture
                              Visibility(
                                visible: !_validIDSelected,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: _validIDNotSelected ? Color.fromRGBO(252, 58, 72, 32) : Color.fromRGBO(82, 82, 82, 1),
                                          width: 1,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(12),
                                    ),
                                    onPressed: () {
                                      choosePicture(context);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 80.h,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.photo_library_outlined,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Upload a picture of your valid ID",
                                            style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              //Uploaded Picture
                              Visibility(
                                visible: _validIDSelected,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      border: Border.all(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Column(
                                              children: [
                                                _validID != null
                                                    ? Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                        child: Image.file(_validID!, width: MediaQuery.of(context).size.width, height: 250.h, fit: BoxFit.contain),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                            Positioned(
                                              height: 50.h,
                                              width: MediaQuery.of(context).size.width - 52,
                                              bottom: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(0, 0, 0, 0.700),
                                                  borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(8.0),
                                                    bottomRight: Radius.circular(8.0),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.close),
                                                        color: Colors.white,
                                                        onPressed: () {
                                                          setState(() {
                                                            _validID = null;
                                                            _validIDSelected = false;
                                                          });
                                                          choosePicture(context);
                                                        },
                                                      ),
                                                      Expanded(
                                                        child: const Align(
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            "Choose another photo?",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),

                              Visibility(
                                visible: _validIDNotSelected,
                                child: Text(
                                  'Please upload a picture of your valid ID',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(height: 20.h),

                              //Submit button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(252, 58, 72, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
                                  ),
                                  padding: EdgeInsets.all(12),
                                ),
                                onPressed: () async {
                                  if (!_civIsPressed && !_resIsPressed) {
                                    setState(() {
                                      _roleNotSelected = true;
                                    });
                                  }

                                  if (_validID == null) {
                                    setState(() {
                                      _validIDNotSelected = true;
                                    });
                                  }

                                  if (_validID != null) {
                                    setState(() {
                                      _validIDNotSelected = false;
                                    });
                                  }

                                  if (!_hasInternet) {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(notConnectedSnackbar);
                                  }
                                  bool _isValid = _formKey.currentState!.validate();

                                  if (!_isValid) {
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(incompleteFieldSnackbar);
                                  }

                                  if (_hasInternet && _isValid && !_roleNotSelected && !_validIDNotSelected) {
                                    SignUp();
                                  }
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
                                              "Submit",
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
                      SizedBox(height: 40.h),

                      //Already a member prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already a member? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                () => const LoginPage(),
                                transition: Transition.fadeIn,
                                duration: Duration(milliseconds: 300),
                              );
                            },
                            child: const Text(
                              'Login Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h)
                    ],
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
