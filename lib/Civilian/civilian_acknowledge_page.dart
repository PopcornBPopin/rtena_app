import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtena_app/start_page.dart';

class CivAckPage extends StatelessWidget {
  const CivAckPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(192, 39, 45, 1),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(252, 58, 72, 1),
                Color.fromRGBO(70, 18, 32, 1),
              ],
            ),
          ),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              //Logo - Textfields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 35.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Logo
                            SizedBox(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            StartPage()),
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

                        SizedBox(height: 45.h),
                        //Emergency Selected
                        Text(
                          'Alert Acknowledged!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        //Description
                        Text(
                          'Responders are now going your way. Godspeed!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 45.h),
                      ],
                    ),
                  ),

                  //STARTS HERE
                  Container(
                    height: 575.h,
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
                        SizedBox(height: 40.h),
                        //Vector Image
                        Center(
                          child: Image.asset(
                            'assets/dark_map.png',
                            scale: 3,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Emergency
                                Row(
                                  children: [
                                    Text(
                                      'Emergency: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      'Alert',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                //Location
                                Row(
                                  children: [
                                    Text(
                                      'Location: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      'Dayandang, Naga City',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                //Responder
                                Row(
                                  children: [
                                    Text(
                                      'Responder: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      'John Doe',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                //Contact Number
                                Row(
                                  children: [
                                    Text(
                                      'Contact Number: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      '09224828853',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                //Occupation
                                Row(
                                  children: [
                                    Text(
                                      'Occupation: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      'Firefighter',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                //Age
                                Row(
                                  children: [
                                    Text(
                                      'Age: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      '40',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),

                                //Sex
                                Row(
                                  children: [
                                    Text(
                                      'Sex: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                    Text(
                                      'Male',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                              ],
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
        ),
      ),
    );
  }
}
