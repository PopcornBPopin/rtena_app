import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/start_page.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/SignUp/sign_page_2.dart';

class Sign1Page extends StatelessWidget {
  const Sign1Page({Key? key}) : super(key: key);
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
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90.h,
                                      width: 180.w,
                                      decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              252, 58, 72, 32),
                                          border: Border.all(
                                            width: 1.5.w,
                                            color: Colors.white,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 15.h),
                                        child: Center(
                                          child: Column(children: [
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
                                          ]),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              //Button for Respondents
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90.h,
                                      width: 180.w,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              220, 70, 18, 32),
                                          border: Border.all(
                                            width: 1.5.w,
                                            color: Colors.white,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 15.h),
                                        child: Center(
                                          child: Column(children: [
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
                                          ]),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Kindly fill this crp
                                Text(
                                  'Kindly fill up the from:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),

                                //Username Text FIeld
                                SizedBox(height: 10.h),
                                Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2.w,
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Image.asset(
                                          'assets/user_icon.png',
                                          scale: 4,
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Username',
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
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      obscureText: true,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
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
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      obscureText: true,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
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
                                SizedBox(height: 20.h),

                                //Basic Information
                                Text(
                                  'Fill in your basic information:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(height: 10.h),

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
                                          color: Colors.grey.shade400,
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
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
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
                                          color: Colors.grey.shade400,
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
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
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
                                          color: Colors.grey.shade400,
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
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
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
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 7.h,
                                    ),
                                    child: TextField(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
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
                                      width: 113.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: Colors.grey.shade400,
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
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
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
                                      width: 113.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: Colors.grey.shade400,
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
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Sex',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //Bloodtype
                                    Container(
                                      height: 50.h,
                                      width: 115.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2.w,
                                          color: Colors.grey.shade400,
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
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.sp,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Bloodtype',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.h),

                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => const Sign2Page(),
                                        transition: Transition.fadeIn,
                                        duration: Duration(milliseconds: 300),
                                      );
                                    },
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
