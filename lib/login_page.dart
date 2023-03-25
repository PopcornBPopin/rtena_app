import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

  bool _passwordHidden = true;
  bool _emailExists = false;

  final RegExp _validPass = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  final RegExp _validEmail = RegExp(r"^[a-zA-Z0-9.]+@[a-z0-9]+\.[a-z]+");

  // Sign in Method
  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(252, 58, 72, 1),
            Color.fromRGBO(70, 18, 32, 1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 30,
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => const StartPage(),
                          transition: Transition.fadeIn,
                          duration: Duration(milliseconds: 300),
                        );
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: -60,
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        child: Image.asset(
                          'assets/RLOGO.png',
                          scale: 2,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 160.h),
                          //Register Title String
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 37.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          //Substring
                          Text(
                            'Login to your existing account of RTena',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 180.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //Form Starts HERE
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                        spreadRadius: 7,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      )
                    ]),
                child: Column(
                  children: [
                    SizedBox(height: 50.h),
                    //
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                      child: Container(
                        child: TextFormField(
                          validator: (String? val) {
                            if (val == null || val.isEmpty || !_validEmail.hasMatch(val)) {
                              return 'Please enter a valid email';
                            } else if (_emailExists) {
                              return 'Email Address is already taken';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofocus: false,
                          controller: _emailController,
                          cursorColor: Colors.grey.shade600,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Color.fromRGBO(252, 58, 72, 32),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),

                    //Password Text Field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                      child: Container(
                        child: TextFormField(
                          validator: (String? val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter a valid password';
                            } else if (!_validPass.hasMatch(val)) {
                              return 'Must have an uppercase and lowercase letters,\na number, and a special character';
                            } else if (val.length < 8) {
                              return 'Must be at least 8 characters';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          autofocus: false,
                          obscureText: _passwordHidden,
                          controller: _passwordController,
                          cursorColor: Colors.grey.shade600,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color.fromRGBO(252, 58, 72, 32),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _passwordHidden = !_passwordHidden;
                                });
                              },
                              child: _passwordHidden
                                  ? const Icon(
                                      Icons.visibility_off,
                                      color: Color.fromRGBO(82, 82, 82, 1),
                                    )
                                  : const Icon(
                                      Icons.visibility,
                                      color: Color.fromRGBO(252, 58, 72, 32),
                                    ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 60.h),

                    //Login button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(252, 58, 72, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
                        ),
                        padding: EdgeInsets.all(12),
                      ),
                      onPressed: () {
                        signIn();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40.h,
                        child: Stack(
                          children: [
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 0,
                              bottom: 0,
                              child: Icon(
                                Icons.next_plan,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.h),

              //Not a member prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => const Sign1Page(),
                        transition: Transition.fadeIn,
                        duration: Duration(microseconds: 300),
                      );
                    },
                    child: const Text(
                      'Register Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h)
            ],
          ),
        ),
      ),
    );
  }
}
