import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/Civilian/civilian_selected_page.dart';
import 'package:rtena_app/start_page.dart';

class CivHomePage extends StatelessWidget {
  const CivHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(192, 39, 45, 1),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Logo - Textfields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 35.h),
                  //LOGO
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

                  //Welcome Back
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Text(
                      'Welcome Back!',
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
                      'What kind of emergency are you involved in?',
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
                    height: 624.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 25.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(
                            'Select the button of emergency you want to report.',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        //Grid of Selection
                        Column(
                          children: [
                            //Fire and Health
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 30.h),
                                //Button for Fire
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(102, 0, 0, 90),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/fire_icon.png',
                                                  scale: 22,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Fire',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Health
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(153, 0, 51, 40),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/health_icon.png',
                                                  scale: 1.5,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Health',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            //Murder and Assault
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30.h,
                                ),
                                //Button for Murder
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(95, 2, 31, 40),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/murder_icon.png',
                                                  scale: 1.5,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Murder',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Assault
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(140, 0, 26, 40),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/assault_icon.png',
                                                  scale: 1.5,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Assault',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            //Flood and Earthquake
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30.h,
                                ),
                                //Button for Flood
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(255, 144, 0, 1),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10).h,
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/flood_icon.png',
                                                  scale: 23,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Flood',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Earthquake
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(55, 6, 23, 40),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/earthquake_icon.png',
                                                  scale: 25,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Earthquake',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            //Kidnapping and Robbery
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 30.h),
                                //Button for Kidnapping
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(157, 2, 8, 40),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/kidnap_icon.png',
                                                  scale: 16,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Kidnapping',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Robbery
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 85.h,
                                        width: 180.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(220, 47, 2, 40),
                                            border: Border.all(
                                              width: 1.5.w,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10.h),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/robbery_icon.png',
                                                  scale: 1.5,
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Robbery',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        //Button for Alert
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Text(
                                "Don't know the emergency? Just press the 'Alert' button",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        //Button for Alert - Proceed to selected page
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 85.h,
                                width: 180.w,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(232, 93, 4, 40),
                                    border: Border.all(
                                      width: 1.5.w,
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(20)),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => const CivSelectedPage(),
                                      transition: Transition.fadeIn,
                                      duration: Duration(milliseconds: 300),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10.h),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/responder_icon.png',
                                            scale: 1.5,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'Alert',
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
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
