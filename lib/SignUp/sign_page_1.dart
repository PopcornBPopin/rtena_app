import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/start_page.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/SignUp/sign_page_2.dart';

class Sign1Page extends StatefulWidget {
  const Sign1Page({Key? key}) : super(key: key);
  @override
  State<Sign1Page> createState() => _Sign1PageState();
}

class _Sign1PageState extends State<Sign1Page> {
  bool _civIsPressed = false;
  bool _resIsPressed = false;

  bool _passMismatch = false;
  bool _fieldIsEmpty = false;
  bool _roleNotSelected = false;

  String? _selectedSex;
  String? _selectedBloodtype;

  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confPasswordController = TextEditingController();
  final _surnameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _midInitController = TextEditingController();
  final _occupationController = TextEditingController();
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _bloodtypeController = TextEditingController();

  //Password not at least 6 characters
  final passMinSnackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 25,
          color: Colors.white,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Password must be at least by 6 characters.',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 5),
    shape: StadiumBorder(),
    behavior: SnackBarBehavior.floating,
    elevation: 1,
  );

  //Error snackbar missing email and password textfields
  final emptyFieldSnackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 25,
          color: Colors.white,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Please fill up the form before submitting.',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 5),
    shape: StadiumBorder(),
    behavior: SnackBarBehavior.floating,
    elevation: 1,
  );

  //Error snackbar missing email and password textfields
  final passMismatchSnackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.error_outline,
            size: 25,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Password mismatch! Password and Confirm password do not match.',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 5),
    shape: StadiumBorder(),
    behavior: SnackBarBehavior.floating,
    elevation: 1,
  );

  Future SignUp() async {
    setState(() {
      _passMismatch = false;
      _fieldIsEmpty = false;
      _roleNotSelected = false;
    });
    if (passwordConfirmed() && !formIncomplete()) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Get.to(
        () => const Sign2Page(),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 300),
      );
    }
    if (!passwordConfirmed()) {
      //Mismatch in pass changes the border of the textfield to red
      setState(() {
        _passMismatch = true;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(passMismatchSnackBar);
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(passMinSnackBar);
      }
    }
    if (formIncomplete()) {
      setState(() {
        _fieldIsEmpty = true;
      });
      ScaffoldMessenger.of(context)..showSnackBar(emptyFieldSnackBar);
    }
    if (_civIsPressed == false && _resIsPressed == false) {
      setState(() {
        _roleNotSelected = true;
      });
    }
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  bool formIncomplete() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _midInitController.text.isEmpty ||
        _occupationController.text.isEmpty ||
        _selectedSex == "" ||
        _selectedBloodtype == "") {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confPasswordController.dispose();
    _surnameController.dispose();
    _firstNameController.dispose();
    _midInitController.dispose();
    _occupationController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(192, 39, 45, 1),
      body: SafeArea(
        child: Container(
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
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Logo - Textfields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 35.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Logo
                          SizedBox(
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
                        ],
                      ),
                    ),

                    SizedBox(height: 25.h),

                    //Register
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Text(
                        'Ready to become a member?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    //FORM STARTS HERE
                    Container(
                      height: 625.h,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 30.h),
                              //Button for Civilian
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                      width: 2.w,
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
                                  });
                                },
                                child: SizedBox(
                                  height: 85.h,
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
                                      width: 1.5.w,
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
                                  });
                                },
                                child: SizedBox(
                                  height: 85.h,
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
                          SizedBox(height: 15.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Username Text FIeld
                                SizedBox(height: 10.h),
                                Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2.w,
                                      color: _fieldIsEmpty
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      controller: _emailController,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        prefixIcon: Image.asset(
                                          'assets/user_icon.png',
                                          scale: 4,
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Email Address',
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                //Password text field
                                Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2.w,
                                      color: _passMismatch || _fieldIsEmpty
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        prefixIcon: Image.asset(
                                          'assets/password_icon.png',
                                          scale: 4,
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Password',
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                //Confirm Password text field
                                Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2.w,
                                      color: _passMismatch || _fieldIsEmpty
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      controller: _confPasswordController,
                                      obscureText: true,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        prefixIcon: Image.asset(
                                          'assets/password_icon.png',
                                          scale: 4,
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Confirm Password',
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                //Phone number Text FIeld
                                Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2.w,
                                      color: _fieldIsEmpty
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        prefixIcon: Image.asset(
                                          'assets/phone_icon.png',
                                          scale: 4,
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Contact Number',
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 15.h),

                                //Fullname Text field
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //Surname
                                    Container(
                                      height: 50.h,
                                      width: 145.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: _fieldIsEmpty
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 7.h,
                                        ),
                                        //Insert icon here
                                        child: TextField(
                                          controller: _surnameController,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: 'Surname',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //First Name
                                    Container(
                                      height: 50.h,
                                      width: 145.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: _fieldIsEmpty
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 7.h,
                                        ),
                                        //Insert icon here
                                        child: TextField(
                                          controller: _firstNameController,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: 'First Name',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 50.h,
                                      width: 50.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: _fieldIsEmpty
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 7.h,
                                        ),
                                        //Insert icon here
                                        child: TextField(
                                          controller: _midInitController,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: 'M.I',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                //Occupation
                                SizedBox(height: 10.h),
                                Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2.w,
                                      color: _fieldIsEmpty
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      controller: _occupationController,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        prefixIcon: Image.asset(
                                          'assets/occupation_icon.png',
                                          scale: 4,
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Occupation',
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                //Age - Sex - Bloodtype textfields
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //Age
                                    Container(
                                      height: 50.h,
                                      width: 100.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: _fieldIsEmpty
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 7.h,
                                        ),
                                        //Insert icon here
                                        child: TextField(
                                          controller: _ageController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: 'Age',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //Sex
                                    Container(
                                      height: 50.h,
                                      width: 120.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: _fieldIsEmpty
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 7.h,
                                        ),
                                        //Insert icon here
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedSex,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: 'Sex',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedSex = value;
                                            });
                                          },
                                          items: [
                                            DropdownMenuItem(
                                              value: 'Male',
                                              child: Text(
                                                'Male',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Female',
                                              child: Text(
                                                'Female',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    //Bloodtype
                                    Container(
                                      height: 50.h,
                                      width: 120.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: _fieldIsEmpty
                                              ? Colors.red
                                              : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 7.h,
                                        ),
                                        //Insert icon here
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedBloodtype,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: 'Bloodtype',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedBloodtype = value;
                                            });
                                          },
                                          items: [
                                            DropdownMenuItem(
                                              value: 'O-',
                                              child: Text(
                                                'O-',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'O+',
                                              child: Text(
                                                'O+',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'A-',
                                              child: Text(
                                                'A-',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'A+',
                                              child: Text(
                                                'A+',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'B-',
                                              child: Text(
                                                'B-',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'B+',
                                              child: Text(
                                                'B+',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'AB-',
                                              child: Text(
                                                'AB-',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'AB+',
                                              child: Text(
                                                'AB+',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.h),

                                Center(
                                  child: GestureDetector(
                                    onTap: SignUp,
                                    child: Container(
                                      height: 45.h,
                                      width: 700.w,
                                      decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color.fromRGBO(252, 58, 72, 1),
                                              Color.fromARGB(255, 121, 58, 75),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15)),
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
                              ],
                            ),
                          ),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    ),

                    //LOGIN HERE CRP
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ), //Login Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
