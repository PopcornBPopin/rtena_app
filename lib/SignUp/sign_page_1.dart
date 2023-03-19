import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/Civilian/civilian_selected_page.dart';
import 'package:rtena_app/start_page.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/SignUp/sign_page_2.dart';

class Sign1Page extends StatefulWidget {
  const Sign1Page({Key? key}) : super(key: key);
  @override
  State<Sign1Page> createState() => _Sign1PageState();
}

class _Sign1PageState extends State<Sign1Page> {
  var _fPass;
  var _sPass;

  var _sexSelected;
  var _bloodtypeSelected;

  bool _civIsPressed = false;
  bool _resIsPressed = false;
  bool _roleNotSelected = false;
  bool _passwordHidden = true;
  bool _confPasswordHidden = true;
  bool _birthdateSelected = false;
  bool _expandScreen = false;

  final _formKey = GlobalKey<FormState>();
  final RegExp _validPass = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  final RegExp _validEmail = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

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
  final _permanentAddressController = TextEditingController();
  final _homeAddressController = TextEditingController();

  @override
  //FUNCTIONS

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(192, 39, 45, 1),
      body: SafeArea(
        //Scrollview starts here
        child: ListView(
          itemExtent: _expandScreen ? 1450.h : 1220.h,
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

                          SizedBox(height: 20.h),

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
                                                    1) {
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
                                            1) {
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
                                        prefixIcon: _sexSelected == 'Male'
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
                                          _sexSelected = newValue!;
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
                                          _bloodtypeSelected = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          //Occupation Text Field
                          Padding(
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
                          SizedBox(height: 10.w),
                          //Submit button
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (!_civIsPressed && !_resIsPressed) {
                                  _roleNotSelected = true;
                                }
                                final isValid =
                                    _formKey.currentState!.validate();
                                setState(
                                  () {
                                    _expandScreen = true;
                                  },
                                );
                                if (isValid && !_roleNotSelected) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const Sign2Page(),
                                    ),
                                  );
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
                  left: (MediaQuery.of(context).size.width) / 4,
                  bottom: 30.h,
                  child: Row(
                    children: [
                      const Text(
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
