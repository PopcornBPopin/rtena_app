import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Page3 extends StatelessWidget {
  const Page3({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 250.h),
              Container(
                width: 300.w,
                child: Text(
                  'Real-Time Emergency Notifier',
                  textAlign: TextAlign.left,
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
                width: 300.w,
                child: Text(
                  "Stay safe, always connected: be prepared with our emergency notifier app.",
                  textAlign: TextAlign.left,
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
