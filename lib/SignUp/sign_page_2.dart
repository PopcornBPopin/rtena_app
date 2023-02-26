import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/SignUp/sign_page_3.dart';
import 'package:rtena_app/start_page.dart';

class Sign2Page extends StatelessWidget {
  const Sign2Page({Key? key}) : super(key: key);
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
                          SizedBox(height: 40.h),
                          //Vector Image
                          Center(
                            child: Image.asset(
                              'assets/account_verify.png',
                              scale: 3,
                            ),
                          ),

                          SizedBox(height: 30.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Text(
                              'Account Verification',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 17.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Open CAMERA
                                Container(
                                  height: 100.h,
                                  width: 350.w,
                                  decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(252, 58, 72, 1),
                                          Color.fromARGB(255, 121, 58, 75),
                                        ],
                                      ),
                                      border: Border.all(
                                        width: 1.5.w,
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10.h),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/camera_icon.png',
                                            scale: 1.2,
                                          ),
                                          const Text(
                                            'Upload a VALID ID',
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
                              ],
                            ),
                          ),
                          SizedBox(height: 30.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter your Contact number below. A 6-digit pin will be sent to your number. It will also be used for future verification',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(height: 15.h),

                                //Phone number Text FIeld
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
                                SizedBox(height: 14.h),

                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => const Sign3Page(),
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
                                          'Proceed',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          )
                        ],
                      ),
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
