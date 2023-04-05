import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rtena_app/Civilian/civilian_home_page.dart';
import 'package:rtena_app/Civilian/civilian_start_page.dart';
import 'package:rtena_app/start_page.dart';
import 'package:rtena_app/SignUp/sign_page_1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void initState() {
    getConnectivity();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitDown,
    // ]);
  }

  bool _passwordHidden = true;
  bool _hasInternet = false;

  late StreamSubscription subscription;

  // final RegExp _validPass = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  final RegExp _validEmail = RegExp(r"^[a-zA-Z0-9.]+@[a-z0-9]+\.[a-z]+");

  //Text Controllers
  final _formKey = GlobalKey<FormState>();
  final _forgotformKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _forgotemailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Snackbar
  final notConnectedSnackbar = SnackBar(
    content: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 25,
            color: Colors.white,
          ),
          Expanded(
            child: Center(
              child: Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: Colors.black,
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.fixed,
    elevation: 1,
  );

  final connectedSnackbar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_outlined,
          size: 25,
          color: Colors.green,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Connection Restored',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.black,
    duration: Duration(seconds: 21),
    behavior: SnackBarBehavior.fixed,
    elevation: 1,
  );

  // FUNCTIONS
  // Sign in Method
  Future signIn() async {
    quickAlert(QuickAlertType.loading, "Standby!", "Verifying your account", Colors.blue);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      Navigator.of(context).pop();
      quickAlert(QuickAlertType.error, "Authentication Failed!", "Invalid email or password", Colors.red);
      print("Invalid email or password");
      return;
    }
    Navigator.of(context).pop();
    Get.to(
      () => const CivStartPage(),
      transition: Transition.fadeIn,
      duration: Duration(milliseconds: 300),
    );
  }

  Future forgotUseEmailPassword() async {
    quickAlert(QuickAlertType.loading, "Standby!", "Checking if your account exists", Colors.blue);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _forgotemailController.text.trim());
    } catch (e) {
      Navigator.of(context).pop();
      quickAlert(QuickAlertType.error, "Authentication Failed!", "Account does not exist", Colors.red);
    }
    Navigator.of(context).pop();
    quickForgotAlert(QuickAlertType.success, "Reset Successful!", "Password reset link sent, please check your email", Colors.green);
  }

  ConnectivityResult result = ConnectivityResult.none;
  void getConnectivity() async {
    _hasInternet = await InternetConnectionChecker().hasConnection;
    if (result != ConnectivityResult.none) {
      setState(() {
        _hasInternet = true;
      });
    }
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        result = await Connectivity().checkConnectivity();
        _hasInternet = await InternetConnectionChecker().hasConnection;
        if (!_hasInternet) {
          print("No internet");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(notConnectedSnackbar);
        } else {
          print("Connected");
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(connectedSnackbar);
        }
      },
    );
  }

  void forgotPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Center(
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.3),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                          spreadRadius: 7,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    height: 600.h,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Positioned(
                                right: 20,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Container(
                                  child: Icon(
                                    Icons.question_mark,
                                    size: 60,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            child: const Text(
                              "Forgot your password?",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: Container(
                            child: RawScrollbar(
                              thickness: 7.5,
                              thumbColor: Colors.redAccent,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 30.h),
                                            const Text(
                                              "Don't worry enter your registered email address to receive password reset.",
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                            ),
                                            SizedBox(height: 30.h),
                                          ],
                                        ),
                                      ),
                                    ),

                                    //Email Address
                                    Form(
                                      key: _forgotformKey,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                        child: Container(
                                          child: TextFormField(
                                            validator: (String? val) {
                                              if (val == null || val.isEmpty || !_validEmail.hasMatch(val)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                            keyboardType: TextInputType.emailAddress,
                                            textInputAction: TextInputAction.next,
                                            autofocus: false,
                                            controller: _forgotemailController,
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
                                    ),
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(252, 58, 72, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                            ),
                            padding: EdgeInsets.all(12),
                          ),
                          onPressed: () async {
                            if (!_hasInternet) {
                              ScaffoldMessenger.of(context).showSnackBar(notConnectedSnackbar);
                            }
                            bool _isValid = _forgotformKey.currentState!.validate();
                            if (_isValid && _hasInternet) {
                              forgotUseEmailPassword();
                              Navigator.of(context).pop();
                            }
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
                                        "Proceed",
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
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  //Popup
  void quickAlert(QuickAlertType animtype, String title, String text, Color color) {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade200,
      context: context,
      type: animtype,
      title: title,
      text: text,
      confirmBtnColor: Colors.white,
      confirmBtnTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      onConfirmBtnTap: () {
        if (animtype == QuickAlertType.success)
          Get.to(
            () => const CivStartPage(),
            transition: Transition.fadeIn,
            duration: Duration(milliseconds: 300),
          );
        else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  void quickForgotAlert(QuickAlertType animtype, String title, String text, Color color) {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade200,
      context: context,
      type: animtype,
      title: title,
      text: text,
      confirmBtnColor: Colors.white,
      confirmBtnTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _forgotemailController.dispose();
    _passwordController.dispose();
    subscription.cancel();
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
          child: SingleChildScrollView(
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
                            SizedBox(height: 150.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                //Form Starts HERE
                Form(
                  key: _formKey,
                  child: Container(
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
                                  // } else if (!_validPass.hasMatch(val)) {
                                  //   return 'Must have an uppercase and lowercase letters,\na number, and a special character';
                                } else if (val.length <= 6) {
                                  return 'Must be at least 6 characters';
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

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              forgotPassword(context);
                            });
                          },
                          child: Padding(
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
                            bool _isValid = _formKey.currentState!.validate();
                            if (_isValid) {
                              signIn();
                            }
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
                ),
                SizedBox(height: 40.h),

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
                SizedBox(height: 30.h)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
