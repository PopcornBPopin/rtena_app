import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rtena_app/start_page.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/Civilian/civilian_home_page.dart';

class Sign1Page extends StatefulWidget {
  const Sign1Page({Key? key}) : super(key: key);
  @override
  State<Sign1Page> createState() => _Sign1PageState();
}

class _Sign1PageState extends State<Sign1Page> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  File? _validID;

  var _sexSelected;
  var _bloodtypeSelected;

  double screenSize = 1290.h;
  double screenSizeCiv = 1290.h;
  double screenSizeRes = 1485.h;
  double screenSizeCivExp = 1520.h;
  double screenSizeResExp = 1780.h;
  double screenSizeAddPic = 120.h;

  bool _civIsPressed = false;
  bool _resIsPressed = false;
  bool _roleNotSelected = false;
  bool _passwordHidden = true;
  bool _confPasswordHidden = true;
  bool _birthdateSelected = false;
  bool _emailExists = false;
  bool _validIDSelected = false;
  bool _validIDNotSelected = false;

  bool _hasSetScreenSizeExpandedForm = false;
  bool _hasSetScreenSizeExpandedFormCiv = false;
  bool _hasSetScreenSizeExpandedFormRes = false;
  bool _hasSetScreenSizeID = false;

  final _formKey = GlobalKey<FormState>();
  final RegExp _validPass = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  final RegExp _validEmail = RegExp(r"^[a-zA-Z0-9.]+@[a-z0-9]+\.[a-z]+");

  final _bloodtypeChoice = ["A+", "B+", "AB+", "A-", "B-", "AB-", "O+", "O-"];
  final _sexChoice = ["Male", "Female"];

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

  //FUNCTIONS

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
      _birthdateController.text =
          "${_monthName[_currentDate.month - 1]} ${_currentDate.day} ${_currentDate.year}";
      _ageController.text = "${(DateTime.now()).year - _currentDate.year}";
    });
    if (newDate == null) return;
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
                // backgroundColor: Color.fromRGBO(252, 58, 72, 32),
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
                // backgroundColor: Color.fromRGBO(252, 58, 72, 32),
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
                      Icons.landscape,
                      color: Colors.black,
                    ),
                    Text(
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
          if (!_hasSetScreenSizeID) {
            setState(() {
              screenSize = screenSize + 140.h;
            });
            _hasSetScreenSizeID = true;
          }
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
      String permanentAddress,
      String homeAddress) async {
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
      'Permanent Address': permanentAddress,
      'Home Address': homeAddress,
    });
  }

  //Sign up
  Future<void> SignUp() async {
    String email = _emailController.text.trim();
    List<String> signInMethods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (signInMethods.isNotEmpty) {
      setState(() {
        _emailExists = true;
      });
      return; // Exit the function if email already exists
    }
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

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
        _permanentAddressController.text.trim(),
        _homeAddressController.text.trim());
    Get.to(
      () => const CivHomePage(),
      transition: Transition.fade,
    );
  }

  //Disposes controller when not in used
  void dispose() {
    _roleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confPasswordController.dispose();
    _surnameController.dispose();
    _firstNameController.dispose();
    _midInitController.dispose();
    _occupationController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _bloodtypeController.dispose();
    _contactNumberController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(192, 39, 45, 1),
      body: SafeArea(
        //Scrollview starts here
        child: ListView(
          itemExtent: screenSize,
          children: [
            Stack(
              children: [
                Container(
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
                ),

                // RTENA Logo
                Positioned(
                  top: 45.h,
                  left: 30.h,
                  child: Container(
                    child: SizedBox(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            () => const StartPage(),
                            transition: Transition.fadeIn,
                            duration: Duration(milliseconds: 300),
                          );
                        },
                        child: Image.asset(
                          'assets/RLOGO.png',
                          scale: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                //Register Title String
                Positioned(
                  top: 100.h,
                  left: 30.h,
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.sp,
                    ),
                  ),
                ),

                //Substring
                Positioned(
                  top: 140.h,
                  left: 30.h,
                  child: Text(
                    'Ready to become a member?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 18.sp,
                    ),
                  ),
                ),

                //Form starts here
                Positioned(
                  top: 195.h,
                  width: MediaQuery.of(context).size.width,
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        color: Colors.white,
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
                                  side: BorderSide(
                                      width: 1.5,
                                      color: _roleNotSelected
                                          ? Colors.red
                                          : Color.fromRGBO(255, 255, 255, 0)),
                                  backgroundColor: _civIsPressed
                                      ? Color.fromRGBO(252, 58, 72, 32)
                                      : Colors.grey[700],
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _civIsPressed = true;
                                    _resIsPressed = false;
                                    _roleNotSelected = false;
                                    if (!_hasSetScreenSizeExpandedFormCiv) {
                                      setState(() {
                                        screenSize = screenSizeCiv;
                                      });
                                    }
                                    if (_hasSetScreenSizeExpandedForm ||
                                        _hasSetScreenSizeExpandedFormCiv) {
                                      setState(() {
                                        screenSize = screenSizeCivExp;
                                      });
                                    }
                                    if (_validIDSelected) {
                                      setState(() {
                                        screenSize =
                                            screenSizeCiv + screenSizeAddPic;
                                      });
                                    }
                                    if (_validIDSelected &&
                                        (_hasSetScreenSizeExpandedFormCiv ||
                                            _hasSetScreenSizeExpandedForm)) {
                                      setState(() {
                                        screenSize =
                                            screenSizeCivExp + screenSizeAddPic;
                                      });
                                    }

                                    _roleController.text = 'Civilian';
                                  });
                                },
                                child: SizedBox(
                                  height: 100.h,
                                  width: 165.w,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.h),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/civilian_icon.png',
                                            scale: 1.5,
                                          ),
                                          SizedBox(height: 2.h),
                                          const Text(
                                            'Civilian',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 10.w),

                              //Button for Respondents
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                      width: 1.5,
                                      color: _roleNotSelected
                                          ? Colors.red
                                          : Color.fromRGBO(255, 255, 255, 0)),
                                  backgroundColor: _resIsPressed
                                      ? Color.fromRGBO(252, 58, 72, 32)
                                      : Colors.grey[700],
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _resIsPressed = true;
                                    _civIsPressed = false;
                                    _roleNotSelected = false;
                                    if (!_hasSetScreenSizeExpandedFormRes) {
                                      setState(() {
                                        screenSize = screenSizeRes;
                                      });
                                    }
                                    if (_hasSetScreenSizeExpandedForm ||
                                        _hasSetScreenSizeExpandedFormRes) {
                                      setState(() {
                                        screenSize = screenSizeResExp;
                                      });
                                    }
                                    if (_validIDSelected) {
                                      setState(() {
                                        screenSize =
                                            screenSizeRes + screenSizeAddPic;
                                      });
                                    }
                                    if (_validIDSelected &&
                                        (_hasSetScreenSizeExpandedFormRes ||
                                            _hasSetScreenSizeExpandedForm)) {
                                      setState(() {
                                        screenSize =
                                            screenSizeResExp + screenSizeAddPic;
                                      });
                                    }

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
                                        children: [
                                          Image.asset(
                                            'assets/responder_icon.png',
                                            scale: 1.5,
                                          ),
                                          SizedBox(height: 2.h),
                                          const Text(
                                            'Responder',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                          SizedBox(height: 5.h),

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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
                            child: Container(
                              child: TextFormField(
                                validator: (String? val) {
                                  if (val == null ||
                                      val.isEmpty ||
                                      !_validEmail.hasMatch(val)) {
                                    return 'Please enter a valid email';
                                  } else if (_emailExists) {
                                    return 'Email Address is already taken';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
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
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
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
                                keyboardType: TextInputType.emailAddress,
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
                                            color:
                                                Color.fromRGBO(82, 82, 82, 1),
                                          )
                                        : const Icon(
                                            Icons.visibility,
                                            color:
                                                Color.fromRGBO(252, 58, 72, 32),
                                          ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
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
                                keyboardType: TextInputType.emailAddress,
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
                                        _confPasswordHidden =
                                            !_confPasswordHidden;
                                      });
                                    },
                                    child: _confPasswordHidden
                                        ? const Icon(
                                            Icons.visibility_off,
                                            color:
                                                Color.fromRGBO(82, 82, 82, 1),
                                          )
                                        : const Icon(
                                            Icons.visibility,
                                            color:
                                                Color.fromRGBO(252, 58, 72, 32),
                                          ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
                            child: Row(
                              children: [
                                //Surename Text Field
                                Flexible(
                                  flex: 5,
                                  child: Container(
                                    child: TextFormField(
                                      validator: (String? val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Empty surename';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: _surnameController,
                                      cursorColor: Colors.grey.shade600,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        labelText: 'Surename',
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(82, 82, 82, 1),
                                              width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(82, 82, 82, 1),
                                              width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide:
                                              BorderSide(color: Colors.red),
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
                                      autofocus: false,
                                      textCapitalization:
                                          TextCapitalization.words,
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
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(82, 82, 82, 1),
                                              width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(82, 82, 82, 1),
                                              width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide:
                                              BorderSide(color: Colors.red),
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
                                      autofocus: false,
                                      textCapitalization:
                                          TextCapitalization.words,
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
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(82, 82, 82, 1),
                                              width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(82, 82, 82, 1),
                                              width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide:
                                              BorderSide(color: Colors.red),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
                            child: Container(
                              child: TextFormField(
                                validator: (String? val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter a valid contact number';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.phone,
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
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
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
                                            if (_birthdateController
                                                    .text.isEmpty ||
                                                int.parse(
                                                        _ageController.text) <=
                                                    4) {
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
                                              color: Color.fromRGBO(
                                                  252, 58, 72, 32),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                      82, 82, 82, 1),
                                                  width: 1),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide:
                                                  BorderSide(color: Colors.red),
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
                                        } else if (int.parse(
                                                _ageController.text) <=
                                            4) {
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
                                          borderSide: BorderSide(
                                              color:
                                                  Color.fromRGBO(82, 82, 82, 1),
                                              width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide:
                                              BorderSide(color: Colors.red),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
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
                                        prefixIcon:
                                            _sexController.text == 'Male'
                                                ? const Icon(
                                                    Icons.male_outlined,
                                                    color: Color.fromRGBO(
                                                        252, 58, 72, 32),
                                                  )
                                                : const Icon(
                                                    Icons.female_outlined,
                                                    color: Color.fromRGBO(
                                                        252, 58, 72, 32),
                                                  ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                        ),
                                      ),
                                      items: _sexChoice
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
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
                                          color:
                                              Color.fromRGBO(252, 58, 72, 32),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                        ),
                                      ),
                                      items: _bloodtypeChoice
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.w, vertical: 6.h),
                              child: Container(
                                child: TextFormField(
                                  validator: (String? val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter your occupation';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
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
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(82, 82, 82, 1),
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(82, 82, 82, 1),
                                          width: 1),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.w, vertical: 6.h),
                              child: Container(
                                child: TextFormField(
                                  validator: (String? val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter your station address';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
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
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(82, 82, 82, 1),
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(82, 82, 82, 1),
                                          width: 1),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.w, vertical: 6.h),
                              child: Container(
                                child: TextFormField(
                                  validator: (String? val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter your employer';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
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
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(82, 82, 82, 1),
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(82, 82, 82, 1),
                                          width: 1),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
                            child: Container(
                              child: TextFormField(
                                validator: (String? val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your permanent address';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
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
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 6.h),
                            child: Container(
                              child: TextFormField(
                                validator: (String? val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your home address';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
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
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(82, 82, 82, 1),
                                        width: 1),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.w, vertical: 6.h),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(252, 58, 72, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                                        Icons.photo_library,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      Text(
                                        "Upload a picture of your valid ID",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.sp),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  border: Border.all(
                                      color: Color.fromRGBO(82, 82, 82, 1),
                                      width: 1),
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Column(
                                          children: [
                                            _validID != null
                                                ? Image.file(_validID!,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 250.h,
                                                    fit: BoxFit.contain)
                                                : Container()
                                          ],
                                        ),
                                        Positioned(
                                          height: 50.h,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              52,
                                          bottom: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  0, 0, 0, 0.700),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(8.0),
                                                bottomRight:
                                                    Radius.circular(8.0),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.close),
                                                    color: Colors.white,
                                                    onPressed: () {
                                                      choosePicture(context);
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "Choose another photo?",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 17.sp),
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
                              'Upload a picture of your valid ID',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          //Submit button
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (!_civIsPressed && !_resIsPressed) {
                                  setState(() {
                                    screenSize = (screenSizeCivExp + 10.h);
                                  });

                                  _roleNotSelected = true;
                                  _hasSetScreenSizeExpandedForm = true;
                                }

                                if (!_civIsPressed &&
                                    !_resIsPressed &&
                                    _validIDSelected) {
                                  setState(() {
                                    screenSize = (screenSizeCivExp + 10.h) +
                                        screenSizeAddPic;
                                  });

                                  _roleNotSelected = true;
                                  _hasSetScreenSizeExpandedForm = true;
                                }

                                if (_civIsPressed &&
                                    !_hasSetScreenSizeExpandedFormCiv) {
                                  setState(() {
                                    screenSize = screenSizeCivExp;
                                  });
                                  _hasSetScreenSizeExpandedFormCiv = true;
                                  _hasSetScreenSizeExpandedFormRes = true;
                                }

                                if (_resIsPressed &&
                                    !_hasSetScreenSizeExpandedFormRes) {
                                  setState(() {
                                    screenSize = screenSizeResExp;
                                  });
                                  _hasSetScreenSizeExpandedFormRes = true;
                                  _hasSetScreenSizeExpandedFormCiv = false;
                                }
                                _hasSetScreenSizeExpandedForm = true;

                                if (!_validIDSelected) {
                                  _validIDNotSelected = true;
                                }
                                if (_validIDSelected) {
                                  _validIDNotSelected = false;
                                }

                                if (_civIsPressed && _validIDSelected) {
                                  setState(() {
                                    screenSize =
                                        screenSizeCivExp + screenSizeAddPic;
                                  });
                                }

                                if (_resIsPressed && _validIDSelected) {
                                  setState(() {
                                    screenSize =
                                        screenSizeResExp + screenSizeAddPic;
                                  });
                                }

                                print(_hasSetScreenSizeExpandedForm);
                                print(_hasSetScreenSizeExpandedFormCiv);
                                print(_hasSetScreenSizeExpandedFormRes);
                                print(_validIDSelected);

                                final isValid =
                                    _formKey.currentState!.validate();
                                if (isValid &&
                                    !_roleNotSelected &&
                                    !_validIDNotSelected) {
                                  SignUp;
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.w, vertical: 10.h),
                                child: Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(252, 58, 72, 1),
                                          Color.fromARGB(255, 121, 58, 75),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: const Center(
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 30.h,
                  child: Row(
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
                ),
                SizedBox(height: 30.h)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
