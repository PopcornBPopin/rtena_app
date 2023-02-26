import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/SignUp/sign_page_1.dart';

// import 'package:rtena_app/old_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
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
          padding: EdgeInsets.symmetric(horizontal: 30),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 35.h),

              //Logo
              SizedBox(
                child: Image.asset(
                  'assets/RTena.png',
                  scale: 1.2,
                ),
              ),
              SizedBox(height: 110.h),

              //R Logo

              Center(
                child: Image.asset(
                  'assets/RLOGO.png',
                  scale: 2.5,
                ),
              ),
              SizedBox(height: 110.h),

              //Title
              Text(
                'Real-Time Emergency Notifier',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 10.h),

              //Description
              Text(
                'Stay safe, always connected: be prepared with our emergency notifier app',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 35.h),

              //Login Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => const LoginPage(),
                      transition: Transition.fadeIn,
                      duration: Duration(milliseconds: 300),
                    );
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    width: 700.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                        child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 51, 10, 21),
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              //Sign Up Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => const Sign1Page(),
                      transition: Transition.circularReveal,
                      duration: Duration(milliseconds: 1000),
                    );
                  },
                  child: Container(
                    width: 700.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.w,
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Text(
                        'Sign Up',
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
      ),
    );
  }
}
