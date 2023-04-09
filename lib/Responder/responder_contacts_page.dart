import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rtena_app/Civilian/civilian_start_page.dart';

class ResContactsPage extends StatefulWidget {
  const ResContactsPage({Key? key}) : super(key: key);

  @override
  State<ResContactsPage> createState() => _ResContactsPageState();
}

class _ResContactsPageState extends State<ResContactsPage> {
  @override
  void initState() {
    getConnectivity();
    getUserData();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  //Disposes controllers when not in used
  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    subscription.cancel();
    super.dispose();
  }

  bool _hasInternet = false;

  late StreamSubscription subscription;
  late String _emailAddress = "";

  final _formKey = GlobalKey<FormState>();
  final RegExp _validEmail = RegExp(r"^[a-zA-Z0-9.]+@[a-z0-9]+\.[a-z]+");

  //Text Controllers
  final _nameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationshipController = TextEditingController();

  //SNACKBAR
  final incompleteFieldSnackbar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: 25,
          color: Colors.white,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Invalid form. Check your inputs.',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.redAccent,
    duration: Duration(seconds: 5),
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

  void getUserData() async {
    print(_emailAddress);
    User? user = FirebaseAuth.instance.currentUser;
    _emailAddress = user!.email!;
  }

  void quickAlert(QuickAlertType animtype, String title, String text, String confirmText, Color color) {
    QuickAlert.show(
      context: context,
      barrierDismissible: false,
      backgroundColor: Colors.grey.shade200,
      type: animtype,
      title: title,
      text: text,
      confirmBtnText: confirmText,
      confirmBtnColor: Colors.white,
      confirmBtnTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      cancelBtnTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  //Writing new contact to Firestone DB
  Future registerNewContactDetails(
    String fullname,
    String relationship,
    String contactNumber,
    String emailAddress,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(_emailAddress.toLowerCase()).collection('contact numbers').doc(fullname).set({
      'Full Name': fullname,
      'Relationship': relationship,
      'Contact Number': contactNumber,
      'Email Address': emailAddress,
    });
  }

  Future RegisterContact() async {
    registerNewContactDetails(
      _nameController.text.trim(),
      _relationshipController.text.trim(),
      _contactNumberController.text.trim(),
      _emailController.text.trim(),
    );
    print("Added contact deets to firestone");

    Navigator.of(context).pop();
    _formKey.currentState!.reset();
    quickAlert(QuickAlertType.success, "Register Successful!", "New emergency contact added", "Okay", Colors.green);
  }

  void addContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
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
                                      Icons.contact_emergency,
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
                              child: Text(
                                "New contact",
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
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Form(
                                          key: _formKey,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(height: 20.h),
                                                //Full Name Text Field
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      validator: (String? val) {
                                                        if (val == null || val.isEmpty) {
                                                          return 'Please enter a valid name';
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType: TextInputType.text,
                                                      textCapitalization: TextCapitalization.words,
                                                      textInputAction: TextInputAction.next,
                                                      autofocus: false,
                                                      controller: _nameController,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Full Name',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: const Icon(
                                                          Icons.person,
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

                                                //Relationship Text Field
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      validator: (String? val) {
                                                        if (val == null || val.isEmpty) {
                                                          return 'Please enter a valid relationship';
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType: TextInputType.text,
                                                      textCapitalization: TextCapitalization.words,
                                                      textInputAction: TextInputAction.next,
                                                      autofocus: false,
                                                      controller: _relationshipController,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Relationship',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: const Icon(
                                                          Icons.person,
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

                                                //Contact Number Text Field
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      validator: (String? val) {
                                                        if (val == null || val.isEmpty) {
                                                          return 'Please enter a valid contact number';
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType: TextInputType.phone,
                                                      textInputAction: TextInputAction.next,
                                                      autofocus: false,
                                                      controller: _contactNumberController,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: InputDecoration(
                                                        contentPadding: EdgeInsets.all(10),
                                                        labelText: 'Contact Number',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: const Icon(
                                                          Icons.phone_android_outlined,
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

                                                //Email Address Text Field
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
                              bool _isValid = _formKey.currentState!.validate();

                              if (!_isValid) {
                                ScaffoldMessenger.of(context).showSnackBar(incompleteFieldSnackbar);
                              }

                              if (_isValid) {
                                RegisterContact();
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
                                          "Add Contact",
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
                                      Icons.add,
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
        },
      ),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addContact(context);
          },
          backgroundColor: Colors.white,
          child: Container(
            height: 100.h,
            width: 100.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Color.fromRGBO(82, 82, 82, 1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                                    'Emergency Contacts',
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
                                  'Who do you want to call?',
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
                    Expanded(
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
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
                              child: Column(
                                children: [
                                  SizedBox(height: 40.h),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      child: Text(
                                        "Tap the button that corresponds to the person you want to call",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30.h),
                                  Container(
                                    height: 420.h,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('users').doc(_emailAddress).collection('contact numbers').snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Text("Fetching your contacts"),
                                            ),
                                          );
                                        }
                                        final snap = snapshot.data!.docs;
                                        if (snap.length == 0) {
                                          return Center(
                                            child: Text(
                                              "Tap the + button to add new contacts",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 17.sp,
                                              ),
                                            ),
                                          );
                                        }
                                        return ScrollConfiguration(
                                          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                                          child: RawScrollbar(
                                            thickness: 7,
                                            thumbColor: Colors.redAccent,
                                            thumbVisibility: true,
                                            child: ListView.builder(
                                              itemCount: snap.length,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                                      child: Column(
                                                        children: [
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
                                                              //Call the number by index
                                                              FlutterPhoneDirectCaller.callNumber(snap[index]['Contact Number']);
                                                            },
                                                            child: SizedBox(
                                                              height: 120.h,
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Stack(
                                                                children: [
                                                                  Positioned(
                                                                    top: 10,
                                                                    right: 0,
                                                                    child: IconButton(
                                                                      icon: Icon(
                                                                        Icons.delete,
                                                                        color: Colors.red,
                                                                      ),
                                                                      onPressed: () {
                                                                        setState(
                                                                          () {
                                                                            QuickAlert.show(
                                                                              backgroundColor: Colors.grey.shade200,
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              type: QuickAlertType.confirm,
                                                                              title: "Delete Confirmation",
                                                                              text: "Are you sure you want to remove ${snap[index]['Full Name']} from your contacts?",
                                                                              confirmBtnText: "Yes",
                                                                              confirmBtnColor: Colors.white,
                                                                              confirmBtnTextStyle: TextStyle(
                                                                                fontSize: 18.sp,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.black,
                                                                              ),
                                                                              cancelBtnTextStyle: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.red,
                                                                              ),
                                                                              onConfirmBtnTap: () {
                                                                                var contactNumbers = FirebaseFirestore.instance.collection('users').doc(_emailAddress).collection('contact numbers');
                                                                                contactNumbers.doc(snap[index]['Full Name'].toString()).delete();
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              onCancelBtnTap: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(left: 20),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          snap[index]['Full Name'],
                                                                          style: TextStyle(
                                                                            fontSize: 20.sp,
                                                                            fontWeight: FontWeight.w400,
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 5.h),
                                                                        Text(
                                                                          'Relationship:\t\t\t\t\t\t\t\t\t' + snap[index]['Relationship'],
                                                                          style: TextStyle(
                                                                            fontSize: 16.sp,
                                                                            fontWeight: FontWeight.normal,
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Contact Number:\t ' + snap[index]['Contact Number'],
                                                                          style: TextStyle(
                                                                            fontSize: 16.sp,
                                                                            fontWeight: FontWeight.normal,
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Email Address:\t\t\t\t\t' + snap[index]['Email Address'],
                                                                          style: TextStyle(
                                                                            fontSize: 16.sp,
                                                                            fontWeight: FontWeight.normal,
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
                                                          SizedBox(height: 20.h),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 200.h),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
