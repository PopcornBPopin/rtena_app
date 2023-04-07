import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 210.h),
              Container(
                child: Text(
                  'Easily report emergencies to others in your community',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 45.sp,
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              //Description
              Container(
                child: Text(
                  "Report emergencies and alert others in your community with ease using our app.",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 25.sp,
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
