import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/checker_page.dart';
import 'package:rtena_app/start_page.dart';
import 'package:rtena_app/SignUp/sign_page_1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Sign in Method
  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    Get.to(
      () => const CheckerPage(),
      transition: Transition.circularReveal,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          child: SingleChildScrollView(
            reverse: false,
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

                          SizedBox(height: 150.h),
                          //Welcome Back!
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          SizedBox(height: 10.h),

                          //Welcome Back!
                          Text(
                            'Login to your existing account of RTena',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 200.h),
                        ],
                      ),
                    ),

                    //STARTS HERE
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        children: [
                          //Username Text FIeld
                          SizedBox(height: 10.h),
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.w,
                                color: Colors.white,
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: Image.asset(
                                    'assets/user_icon.png',
                                    scale: 4,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Username',
                                  hintStyle: TextStyle(color: Colors.white),
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
                                width: 1.w,
                                color: Colors.white,
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: Image.asset(
                                    'assets/password_icon.png',
                                    scale: 4,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          //Forgot Password?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //Forgot Password?
                              Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30.h),

                          //Submit Button
                          Center(
                            child: GestureDetector(
                              // onTap: () {
                              //   Get.to(
                              //     () => const CivHomePage(),
                              //     transition: Transition.circularReveal,
                              //     duration: Duration(milliseconds: 1000),
                              //   );
                              // },
                              onTap: signIn,
                              child: Container(
                                width: 700.w,
                                height: 45.h,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Color.fromRGBO(70, 18, 32, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          //Already have an account? Login Now
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Not a member? ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => const Sign1Page(),
                                    transition: Transition.circularReveal,
                                    duration: Duration(milliseconds: 1000),
                                  );
                                },
                                child: Text(
                                  'Register Now',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
