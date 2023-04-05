import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rtena_app/Civilian/civilian_start_page.dart';

class CivSettingsPage extends StatefulWidget {
  const CivSettingsPage({Key? key}) : super(key: key);
  @override
  State<CivSettingsPage> createState() => _CivSettingsPageState();
}

class _CivSettingsPageState extends State<CivSettingsPage> {
  @override
  void initState() {
    getUserData();
    getConnectivity();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  bool _hasInternet = false;
  late StreamSubscription subscription;
  late String _emailAddress = "";

  final _feedbackformKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  //Text Controllers
  final _feedbackController = TextEditingController();

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

  // FUNCTIONS
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
          setState(() {
            _hasInternet = false;
          });
        } else {
          setState(() {
            _hasInternet = true;
          });
        }
      },
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void getUserData() async {
    print(_emailAddress);
    User? user = FirebaseAuth.instance.currentUser;
    _emailAddress = user!.email!;
  }

  //Writing new contact to Firestone DB
  Future addFeedback(
    String feedback,
  ) async {
    await FirebaseFirestore.instance.collection('feedbacks').doc(_emailAddress).set({
      'Feedback': feedback,
    });
  }

  Future SendFeedback() async {
    addFeedback(
      _feedbackController.text.trim(),
    );
    print("Feedback Sent");

    _feedbackformKey.currentState!.reset();
    Navigator.of(context).pop();
    quickAlert(QuickAlertType.success, "Feedback Sent!", "Thank you for providing your feedback!", Colors.green);
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

  Future forgotUseEmailPassword() async {
    quickAlert(QuickAlertType.loading, "Standby!", "Searching for your email address", Colors.blue);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailAddress);
    } catch (e) {
      Navigator.of(context).pop();
      quickAlert(QuickAlertType.error, "Authentication Failed!", "A problem occured while sending a reset link", Colors.red);
    }
    Navigator.of(context).pop();
    quickForgotAlert(QuickAlertType.success, "Reset Successful!", "Password reset link sent, please check your email", Colors.green);
  }

  //Change password popup
  void changePassword(BuildContext context) {
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
                    height: 400.h,
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
                                    Icons.password,
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
                              "Want to change your password?",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
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
                                              "We will send a password reset link to your email address.",
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                            ),
                                            SizedBox(height: 30.h),
                                          ],
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
                            if (_hasInternet) {
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

  //Terms of Service popup
  void termsOfService(BuildContext context) {
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
                    height: 580.h,
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
                                    Icons.assignment,
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
                              "Terms of Service",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: Container(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  children: [
                                    RawScrollbar(
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
                                                    const Text(
                                                      "I. Introduction",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                                    ),
                                                    const Text(
                                                      "   This is a seniors' project of the developers and a partial compliance to their course's final requirement. The mobile application's, and its other components', intention is to create an accessible and convenient means of communicating with responders of your current situation. That being sais, the mobile application requires your permission with your mobile device's: \n\nFinal State (Location, Mobile Date, WiFi, Phone) \n\nInitiation State (Camera, Library or Files Manager)\n\n",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                                    ),
                                                    const Text(
                                                      "II. Permissions Terms",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                                    ),
                                                    const Text(
                                                      "   Location - It is to determine your mobile device's accurate location, should an incident happen to you and you accessed our mobile app. WiFi/Mobile Data - It is to override your internet connection if you (a) are not connected to the internet, or (b) have a slow internet connection through WiFi. Your internet connection is needed to update our database with your current location, if it would be done online. Phone - It is to update our database with your current location, if it would be done offline. We are using GSM technologies to cater offline means of communicating. Camera - It is to take a picture of your valid ID.Library/Files Manager - It is if, instead, you want to find your valid ID in your files\n\n",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                                    ),
                                                    const Text(
                                                      "III. Privacy Terms",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                                    ),
                                                    const Text(
                                                      "   We collect your personal information for the sole purpose of relaying that information to a responder, should you encounter an incident that requires it. Your personal information will only be read-and-write accessible (editable) by the servers and developers of the mobile application and its components. Your personal information is also to ensure liability and accountability of your actions.\n\n",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                                    ),
                                                    const Text(
                                                      "IV. Agreement",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                                    ),
                                                    const Text(
                                                      "   By ticking the two boxes below, you agree with allowing access permissions on your mobile phone and collecting your data\n",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                                    ),
                                                    SizedBox(height: 20.h),
                                                  ],
                                                ),
                                              ),
                                            ),
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
                        SizedBox(height: 50.h),
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

  //about popup
  void about(BuildContext context) {
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
                    height: 580.h,
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
                              "About",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: Container(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  children: [
                                    RawScrollbar(
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
                                                    const Text(
                                                      "RTENA Real Time Emergency Notifier App\n",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                                    ),
                                                    const Text(
                                                      "The Emergency Notifier App is a software application that runs on mobile devices such as smartphones and tablets. Its primary purpose is to provide a quick and efficient way for users to send an emergency alert to designated responders in case of danger or any urgent assistance required. The app's user interface is designed with simplicity in mind to ensure that anyone can use it with ease, even in a stressful and high-pressure situation.",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                                    ),
                                                    SizedBox(height: 20.h),
                                                  ],
                                                ),
                                              ),
                                            ),
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
                        SizedBox(height: 50.h),
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

  //Help popup
  void help(BuildContext context) {
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
                    height: 300.h,
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
                                    Icons.warning,
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
                              "Help",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 50.h),
                        Expanded(
                          child: Container(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  children: [
                                    RawScrollbar(
                                      thickness: 7.5,
                                      thumbColor: Colors.redAccent,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 30),
                                              child: Container(
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Text(
                                                        "Nothing to see here\n",
                                                        textAlign: TextAlign.justify,
                                                        style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                                      ),
                                                      const Text(
                                                        "You're on your own :>",
                                                        textAlign: TextAlign.justify,
                                                        style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                                      ),
                                                      SizedBox(height: 20.h),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
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
                        SizedBox(height: 50.h),
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

  //Feedback popup
  void feedback(BuildContext context) {
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
                    height: 530.h,
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
                                    Icons.speaker_notes,
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
                              "Feedback",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  children: [
                                    RawScrollbar(
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
                                                      "Tell us about your experience below.",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
                                                    ),
                                                    SizedBox(height: 20.h),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Form(
                                              key: _feedbackformKey,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
                                                child: Container(
                                                  child: TextFormField(
                                                    validator: (String? val) {
                                                      if (val == null || val.isEmpty) {
                                                        return 'Fill the textfield';
                                                      }
                                                      return null;
                                                    },
                                                    keyboardType: TextInputType.multiline,
                                                    textCapitalization: TextCapitalization.sentences,
                                                    maxLines: 8,
                                                    textInputAction: TextInputAction.next,
                                                    autofocus: true,
                                                    controller: _feedbackController,
                                                    cursorColor: Colors.grey.shade600,
                                                    decoration: const InputDecoration(
                                                      contentPadding: EdgeInsets.all(10),
                                                      hintText: "Enter your feedback message here",
                                                      labelText: "",
                                                      labelStyle: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
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
                            bool _isValid = _feedbackformKey.currentState!.validate();
                            if (_isValid && _hasInternet) {
                              SendFeedback();
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
                                        "Send Feedback",
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
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              top: 30,
                              right: -10,
                              child: Opacity(
                                opacity: 0.15,
                                child: Container(
                                  child: Image.asset(
                                    'assets/RLOGO.png',
                                    scale: 2.5,
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
                                    SizedBox(height: 75.h),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(CivStartPage());
                                      },
                                      child: Text(
                                        'Settings',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 37.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    //Substring
                                    Text(
                                      '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(height: 30.h),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  children: [
                                    SizedBox(height: 40.h),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "General Settings",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),

                                    //Change password
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () {
                                        changePassword(context);
                                      },
                                      child: SizedBox(
                                        height: 60.h,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 15,
                                              left: 20,
                                              child: Icon(
                                                Icons.password,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                            Positioned(
                                              top: 15,
                                              right: 20,
                                              child: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Colors.black,
                                                size: 22,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 55),
                                                  child: Text(
                                                    ("Change Password"),
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30.h),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Support",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),

                                    //Terms and Data Policy
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () {
                                        termsOfService(context);
                                      },
                                      child: SizedBox(
                                        height: 60.h,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 15,
                                              left: 20,
                                              child: Icon(
                                                Icons.assignment,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                            Positioned(
                                              top: 15,
                                              right: 20,
                                              child: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Colors.black,
                                                size: 22,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 55),
                                                  child: Text(
                                                    ("Terms of Service"),
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),

                                    //About
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () {
                                        about(context);
                                      },
                                      child: SizedBox(
                                        height: 60.h,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 15,
                                              left: 20,
                                              child: Icon(
                                                Icons.question_mark,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                            Positioned(
                                              top: 15,
                                              right: 20,
                                              child: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Colors.black,
                                                size: 22,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 55),
                                                  child: Text(
                                                    ("About"),
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),

                                    //Help
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () {
                                        help(context);
                                      },
                                      child: SizedBox(
                                        height: 60.h,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 15,
                                              left: 20,
                                              child: Icon(
                                                Icons.warning,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                            Positioned(
                                              top: 15,
                                              right: 20,
                                              child: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Colors.black,
                                                size: 22,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 55),
                                                  child: Text(
                                                    ("Help"),
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15.h),

                                    //Feedback
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () {
                                        feedback(context);
                                      },
                                      child: SizedBox(
                                        height: 60.h,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 15,
                                              left: 20,
                                              child: Icon(
                                                Icons.speaker_notes,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                            Positioned(
                                              top: 15,
                                              right: 20,
                                              child: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Colors.black,
                                                size: 22,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 55),
                                                  child: Text(
                                                    ("Feedback"),
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30.h),

                                    //Sign Out
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Color.fromRGBO(82, 82, 82, 1),
                                            width: 1,
                                          ),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () {
                                        signUserOut();
                                      },
                                      child: SizedBox(
                                        height: 60.h,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 15,
                                              right: 20,
                                              child: Icon(Icons.logout, color: Colors.black, size: 20),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    ("Sign Out"),
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 100.h)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
