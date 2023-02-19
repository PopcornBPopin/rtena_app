import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/Civilian/civilian_acknowledge_page.dart';

class CivSelectedPage extends StatelessWidget {
  const CivSelectedPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(192, 39, 45, 1),
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
                                  Get.to(
                                    () => const CivAckPage(),
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

                        SizedBox(height: 45.h),
                        //Emergency Selected
                        Text(
                          'Emergency Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30.sp,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        //Description
                        Text(
                          'Waiting for confimration of the responders near you. Please hang tight.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 18.sp,
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
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 135.h),
                          Image.asset(
                            'assets/emergency_selected.png',
                            scale: 2,
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
    );
  }
}
