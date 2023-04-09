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

class ResProfilePage extends StatefulWidget {
  const ResProfilePage({Key? key}) : super(key: key);

  @override
  State<ResProfilePage> createState() => _ResProfilePageState();
}

class _ResProfilePageState extends State<ResProfilePage> {
  @override
  void initState() {
    getConnectivity();
    getUserData();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitDown,
    // ]);
  }

  //Disposes controllers when not in used
  @override
  void dispose() {
    _surnameController.dispose();
    _firstNameController.dispose();
    _midInitController.dispose();
    _contactNumberController.dispose();
    _birthdateController.dispose();
    _sexController.dispose();
    _bloodtypeController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _employerController.dispose();
    _stationAddressController.dispose();
    _permanentAddressController.dispose();
    _homeAddressController.dispose();
    subscription.cancel();
    super.dispose();
  }

  bool _hasInternet = false;
  bool _editButtonPressed = false;
  bool _fullNameFieldSelected = false;
  bool _contactNumberFieldSelected = false;
  bool _birthdateFieldSelected = false;
  bool _sexFieldSelected = false;
  bool _bloodtypeFieldSelected = false;
  bool _occupationFieldSelected = false;
  bool _employerFieldSelected = false;
  bool _stationAddressFieldSelected = false;
  bool _permanentAddressFieldSelected = false;
  bool _homeAddressFieldSelected = false;

  late StreamSubscription subscription;
  late String _emailAddress = "";
  late String _firstName = "";
  late String _midInit = "";
  late String _surname = "";
  late String _contactNumber = "";
  late String _birthdate = "";
  late int _age = 0;
  late String _sex = "";
  late String _bloodtype = "";
  late String _occupation = "";
  late String _employer = "";
  late String _stationAddress = "";
  late String _permanentAddress = "";
  late String _homeAddress = "";
  late String _role = "";

  final _formKey = GlobalKey<FormState>();

  var _sexSelected;
  var _bloodtypeSelected;

  late String imageURL;

  bool _birthdateSelected = false;

  final _bloodtypeChoice = [
    "A+",
    "B+",
    "AB+",
    "A-",
    "B-",
    "AB-",
    "O+",
    "O-"
  ];
  final _sexChoice = [
    "Male",
    "Female"
  ];

  DateTime _currentDate = DateTime.now();
  final _monthName = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  // Text Controllers

  final _surnameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _midInitController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _sexController = TextEditingController();
  final _bloodtypeController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _employerController = TextEditingController();
  final _stationAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _homeAddressController = TextEditingController();

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

  //Calendar Theme
  final ThemeData theme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color.fromRGBO(252, 58, 72, 1),
      surface: Color.fromRGBO(70, 18, 32, 1),
    ),
    dialogBackgroundColor: Color.fromRGBO(70, 18, 32, 1),
    textTheme: TextTheme(
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    ),
  );

  //Show calendar
  Future<void> _showBirthdatePicker() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );
    setState(() {
      _birthdateSelected = true;
      _currentDate = newDate!;
      _birthdateController.text = "${_monthName[_currentDate.month - 1]} ${_currentDate.day} ${_currentDate.year}";
      _ageController.text = _currentDate.month <= DateTime.now().month
          ? _currentDate.day <= DateTime.now().day
              ? "${(DateTime.now()).year - _currentDate.year}"
              : "${(DateTime.now()).year - _currentDate.year - 1}"
          : "${(DateTime.now()).year - _currentDate.year - 1}";
    });
    if (newDate == null) return;
  }

  //Show success prompt
  void quickAlert(QuickAlertType animtype, String title, String text, Color color) {
    QuickAlert.show(
      backgroundColor: Colors.grey.shade200,
      context: context,
      barrierDismissible: false,
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

  //Grab user document from Firebase Firestone
  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    _emailAddress = user!.email!;
  }

  //Writing user details to Firestone DB
  Future updateUserDetails(
    String surname,
    String firstName,
    String mInit,
    String contactNumber,
    String bDate,
    int age,
    String sex,
    String bloodtype,
    String occupation,
    String employer,
    String stationAddress,
    String permanentAddress,
    String homeAddress,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(_emailAddress.toLowerCase()).update({
      'Surname': surname.isEmpty ? _surname : surname,
      'First Name': firstName.isEmpty ? _firstName : firstName,
      'M.I': mInit.isEmpty ? _midInit : mInit,
      'Contact Number': contactNumber.isEmpty ? _contactNumber : contactNumber,
      'Birthdate': bDate.isEmpty ? _birthdate : bDate,
      'Age': age,
      'Sex': sex.isEmpty ? _sex : sex,
      'Bloodtype': bloodtype.isEmpty ? _bloodtype : bloodtype,
      'Occupation': occupation.isEmpty ? _occupation : occupation,
      'Employer': employer.isEmpty ? _employer : employer,
      'Station Address': stationAddress.isEmpty ? _stationAddress : stationAddress,
      'Permanent Address': permanentAddress.isEmpty ? _permanentAddress : permanentAddress,
      'Home Address': homeAddress.isEmpty ? _homeAddress : homeAddress,
    });
  }

  Future UpdateFields() async {
    if (!_ageController.text.isEmpty) {
      _age = int.parse(_ageController.text.trim());
    }

    //Add user details
    updateUserDetails(
      _surnameController.text.trim(),
      _firstNameController.text.trim(),
      _midInitController.text.trim(),
      _contactNumberController.text.trim(),
      _birthdateController.text.trim(),
      _age,
      _sexController.text.trim(),
      _bloodtypeController.text.trim(),
      _occupationController.text.trim(),
      _employerController.text.trim(),
      _stationAddressController.text.trim(),
      _permanentAddressController.text.trim(),
      _homeAddressController.text.trim(),
    );
    print("Updated user deets to firestone");

    Navigator.of(context).pop();
    quickAlert(QuickAlertType.success, "Update Successful!", "Your profile has been updated", Colors.green);
  }

  void editProfile(BuildContext context) {
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
                                      Icons.edit_note,
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
                                "Edit Details?",
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
                                        //Email Address
                                        Form(
                                          key: _formKey,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Column(
                                              children: [
                                                //Full Name Text Field
                                                Visibility(
                                                  visible: _fullNameFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Row(
                                                      children: [
                                                        //Surname Text Field
                                                        Flexible(
                                                          flex: 5,
                                                          child: Container(
                                                            child: TextFormField(
                                                              validator: (String? val) {
                                                                if (val == null || val.isEmpty) {
                                                                  return 'Empty surname';
                                                                }
                                                                return null;
                                                              },
                                                              keyboardType: TextInputType.text,
                                                              textInputAction: TextInputAction.next,
                                                              autofocus: false,
                                                              textCapitalization: TextCapitalization.words,
                                                              controller: _surnameController,
                                                              cursorColor: Colors.grey.shade600,
                                                              decoration: const InputDecoration(
                                                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                                labelText: 'Surname',
                                                                labelStyle: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 15,
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
                                                        SizedBox(width: 8.w),

                                                        //First Name Text Field
                                                        Flexible(
                                                          flex: 5,
                                                          child: Container(
                                                            child: TextFormField(
                                                              validator: (String? val) {
                                                                if (val == null || val.isEmpty) {
                                                                  return 'Empty first name';
                                                                }
                                                                return null;
                                                              },
                                                              keyboardType: TextInputType.text,
                                                              textInputAction: TextInputAction.next,
                                                              autofocus: false,
                                                              textCapitalization: TextCapitalization.words,
                                                              controller: _firstNameController,
                                                              cursorColor: Colors.grey.shade600,
                                                              decoration: const InputDecoration(
                                                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                                labelText: 'First Name',
                                                                labelStyle: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 15,
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
                                                        SizedBox(width: 8.w),

                                                        //Middle Initial Text Field
                                                        Flexible(
                                                          flex: 2,
                                                          child: Container(
                                                            child: TextFormField(
                                                              validator: (String? val) {
                                                                if (val == null || val.isEmpty) {
                                                                  return 'M.I';
                                                                }
                                                                return null;
                                                              },
                                                              keyboardType: TextInputType.text,
                                                              textInputAction: TextInputAction.next,
                                                              autofocus: false,
                                                              textCapitalization: TextCapitalization.words,
                                                              controller: _midInitController,
                                                              cursorColor: Colors.grey.shade600,
                                                              decoration: const InputDecoration(
                                                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                                labelText: 'M.I',
                                                                labelStyle: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 15,
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
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                //Contact Number Text Field
                                                Visibility(
                                                  visible: _contactNumberFieldSelected,
                                                  child: Padding(
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
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                                                ),

                                                //Birthdate and Age Selector
                                                Visibility(
                                                  visible: _birthdateFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        //Birthdate Selector
                                                        Flexible(
                                                          flex: 4,
                                                          child: Container(
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                _showBirthdatePicker();
                                                              },
                                                              child: Container(
                                                                child: TextFormField(
                                                                  validator: (String? val) {
                                                                    if (_birthdateController.text.isEmpty || int.parse(_ageController.text) <= 4) {
                                                                      return 'Please enter your birthdate';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  enabled: false,
                                                                  autofocus: false,
                                                                  controller: _birthdateController,
                                                                  decoration: InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                                    labelText: "Birthdate",
                                                                    labelStyle: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 15,
                                                                    ),
                                                                    prefixIcon: const Icon(
                                                                      Icons.cake_outlined,
                                                                      color: Color.fromRGBO(252, 58, 72, 32),
                                                                    ),
                                                                    disabledBorder: OutlineInputBorder(
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
                                                        ),
                                                        SizedBox(width: 8.w),

                                                        //Age Text field
                                                        Flexible(
                                                          flex: 3,
                                                          child: Container(
                                                            child: TextFormField(
                                                              validator: (String? val) {
                                                                if (!_birthdateSelected) {
                                                                  return 'Enter your Birthdate';
                                                                } else if (int.parse(_ageController.text) <= 4) {
                                                                  return 'Invalid Age';
                                                                }
                                                                return null;
                                                              },
                                                              readOnly: true,
                                                              enabled: true,
                                                              autofocus: false,
                                                              controller: _ageController,
                                                              decoration: InputDecoration(
                                                                contentPadding: EdgeInsets.all(10),
                                                                labelText: "Age",
                                                                labelStyle: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                                enabledBorder: OutlineInputBorder(
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
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                Visibility(
                                                  visible: _sexFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Container(
                                                      child: DropdownButtonFormField<String>(
                                                        validator: (String? val) {
                                                          if (val == null || val.isEmpty) {
                                                            return 'Select your sex';
                                                          }
                                                          return null;
                                                        },
                                                        value: _sexSelected,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: "Sex",
                                                          labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: _sexController.text == 'Male'
                                                              ? const Icon(
                                                                  Icons.male_outlined,
                                                                  color: Color.fromRGBO(252, 58, 72, 32),
                                                                )
                                                              : const Icon(
                                                                  Icons.female_outlined,
                                                                  color: Color.fromRGBO(252, 58, 72, 32),
                                                                ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(
                                                              color: Color.fromRGBO(82, 82, 82, 1),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(
                                                              color: Color.fromRGBO(82, 82, 82, 1),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          errorBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: Colors.red),
                                                          ),
                                                        ),
                                                        items: _sexChoice.map<DropdownMenuItem<String>>((String value) {
                                                          return DropdownMenuItem<String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            _sexController.text = newValue!;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Visibility(
                                                  visible: _bloodtypeFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Container(
                                                      child: DropdownButtonFormField<String>(
                                                        validator: (String? val) {
                                                          if (val == null || val.isEmpty) {
                                                            return 'Select your bloodtype';
                                                          }
                                                          return null;
                                                        },
                                                        value: _bloodtypeSelected,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: "Bloodtype",
                                                          labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: const Icon(
                                                            Icons.bloodtype_outlined,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(
                                                              color: Color.fromRGBO(82, 82, 82, 1),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(
                                                              color: Color.fromRGBO(82, 82, 82, 1),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          errorBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: Colors.red),
                                                          ),
                                                        ),
                                                        items: _bloodtypeChoice.map<DropdownMenuItem<String>>((String value) {
                                                          return DropdownMenuItem<String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            _bloodtypeController.text = newValue!;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                //Occupation Text field
                                                Visibility(
                                                  visible: _occupationFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        validator: (String? val) {
                                                          if (val == null || val.isEmpty) {
                                                            return 'Please enter your occupation';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType: TextInputType.text,
                                                        textInputAction: TextInputAction.next,
                                                        autofocus: false,
                                                        textCapitalization: TextCapitalization.words,
                                                        controller: _occupationController,
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Occupation',
                                                          labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: const Icon(
                                                            Icons.work_outlined,
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

                                                //Employer Text field
                                                Visibility(
                                                  visible: _employerFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        validator: (String? val) {
                                                          if (val == null || val.isEmpty) {
                                                            return 'Please enter your employer';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType: TextInputType.text,
                                                        textInputAction: TextInputAction.next,
                                                        autofocus: false,
                                                        textCapitalization: TextCapitalization.words,
                                                        controller: _employerController,
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Employer',
                                                          labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: const Icon(
                                                            Icons.work_outlined,
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

                                                //Station Address Text field
                                                Visibility(
                                                  visible: _stationAddressFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        validator: (String? val) {
                                                          if (val == null || val.isEmpty) {
                                                            return 'Please enter your station address';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType: TextInputType.text,
                                                        textInputAction: TextInputAction.next,
                                                        autofocus: false,
                                                        textCapitalization: TextCapitalization.words,
                                                        controller: _stationAddressController,
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Station Address',
                                                          labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: const Icon(
                                                            Icons.work_outlined,
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

                                                //Permanent Address Text field
                                                Visibility(
                                                  visible: _permanentAddressFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        validator: (String? val) {
                                                          if (val == null || val.isEmpty) {
                                                            return 'Please enter your permanent address';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType: TextInputType.text,
                                                        textInputAction: TextInputAction.next,
                                                        autofocus: false,
                                                        textCapitalization: TextCapitalization.words,
                                                        controller: _permanentAddressController,
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Permanent Address',
                                                          labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: const Icon(
                                                            Icons.location_on_outlined,
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

                                                //Home Address Text field
                                                Visibility(
                                                  visible: _homeAddressFieldSelected,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 7.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        validator: (String? val) {
                                                          if (val == null || val.isEmpty) {
                                                            return 'Please enter your home address';
                                                          }
                                                          return null;
                                                        },
                                                        keyboardType: TextInputType.text,
                                                        textInputAction: TextInputAction.next,
                                                        autofocus: false,
                                                        textCapitalization: TextCapitalization.words,
                                                        controller: _homeAddressController,
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Home Address',
                                                          labelStyle: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: const Icon(
                                                            Icons.location_on_outlined,
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
                                                SizedBox(height: 10.h),
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
                          //Submit button
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
                                UpdateFields();
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
                                          "Update Profile",
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
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
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
                                      child: StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance.collection('users').doc(_emailAddress).snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Text(
                                              'Hi!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 37.sp,
                                              ),
                                            );
                                          }
                                          return Text(
                                            'Hi! $_firstName',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 37.sp,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    //Substring
                                    Text(
                                      'Want to edit your personal details?',
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
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    SizedBox(height: 30.h),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance.collection('users').doc(_emailAddress).snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Container(
                                                color: Colors.white,
                                                height: 1000.h,
                                              );
                                            }
                                            final userData = snapshot.data!.data() as Map<String, dynamic>;
                                            _firstName = userData['First Name'];
                                            _midInit = userData['M.I'];
                                            _surname = userData['Surname'];
                                            _contactNumber = userData['Contact Number'];
                                            _birthdate = userData['Birthdate'];
                                            _age = userData['Age'];
                                            _sex = userData['Sex'];
                                            _bloodtype = userData['Bloodtype'];
                                            _occupation = userData['Occupation'];
                                            _employer = userData['Employer'];
                                            _stationAddress = userData['Station Address'];
                                            _permanentAddress = userData['Permanent Address'];
                                            _homeAddress = userData['Home Address'];
                                            _role = userData['Role'];
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Text(
                                                          '$_role Account',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 19.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _editButtonPressed = true;
                                                        });
                                                        if ((_fullNameFieldSelected || _contactNumberFieldSelected || _birthdateFieldSelected || _sexFieldSelected || _bloodtypeFieldSelected || _occupationFieldSelected || _employerFieldSelected || _stationAddressFieldSelected || _permanentAddressFieldSelected || _homeAddressFieldSelected) && _editButtonPressed) {
                                                          editProfile(context);
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.edit_note,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Visibility(
                                                  visible: _editButtonPressed,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      children: [
                                                        SizedBox(height: 20.h),
                                                        Text(
                                                          "Long press on the fields you want to edit and tap to deselect.\n\n Everything is editable besides your Email Address",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 17.sp,
                                                          ),
                                                        ),
                                                        SizedBox(height: 20.h),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _fullNameFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_fullNameFieldSelected) {
                                                        _fullNameFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        autofocus: false,
                                                        readOnly: true,
                                                        enabled: false,
                                                        initialValue: '$_firstName $_midInit. $_surname',
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Full Name',
                                                          labelStyle: TextStyle(
                                                            color: _fullNameFieldSelected ? Colors.red : Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.person,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.close,
                                                            color: _fullNameFieldSelected ? Colors.red : Colors.white,
                                                          ),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: _fullNameFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Container(
                                                    child: TextFormField(
                                                      autofocus: false,
                                                      readOnly: true,
                                                      enabled: false,
                                                      initialValue: _emailAddress,
                                                      cursorColor: Colors.grey.shade600,
                                                      decoration: const InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                        labelText: 'Email Address',
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.email_outlined,
                                                          color: Color.fromRGBO(252, 58, 72, 32),
                                                        ),
                                                        disabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(10.0),
                                                          ),
                                                          borderSide: BorderSide(color: Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _contactNumberFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_contactNumberFieldSelected) {
                                                        _contactNumberFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        autofocus: false,
                                                        readOnly: true,
                                                        enabled: false,
                                                        initialValue: _contactNumber,
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Contact Number',
                                                          labelStyle: TextStyle(
                                                            color: _contactNumberFieldSelected ? Colors.red : Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.phone_android_outlined,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.close,
                                                            color: _contactNumberFieldSelected ? Colors.red : Colors.white,
                                                          ),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: _contactNumberFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _birthdateFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_birthdateFieldSelected) {
                                                        _birthdateFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            child: TextFormField(
                                                              autofocus: false,
                                                              readOnly: true,
                                                              enabled: false,
                                                              initialValue: _birthdate,
                                                              cursorColor: Colors.grey.shade600,
                                                              decoration: InputDecoration(
                                                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                                labelText: 'Birthdate',
                                                                labelStyle: TextStyle(
                                                                  color: _birthdateFieldSelected ? Colors.red : Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                                prefixIcon: Icon(
                                                                  Icons.cake,
                                                                  color: Color.fromRGBO(252, 58, 72, 32),
                                                                ),
                                                                disabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(10.0),
                                                                  ),
                                                                  borderSide: BorderSide(color: _birthdateFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Expanded(
                                                          child: Container(
                                                            child: TextFormField(
                                                              autofocus: false,
                                                              readOnly: true,
                                                              enabled: false,
                                                              initialValue: _age.toString(),
                                                              cursorColor: Colors.grey.shade600,
                                                              decoration: InputDecoration(
                                                                contentPadding: EdgeInsets.all(10),
                                                                labelText: 'Age',
                                                                labelStyle: TextStyle(
                                                                  color: _birthdateFieldSelected ? Colors.red : Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                                suffixIcon: Icon(
                                                                  Icons.close,
                                                                  color: _birthdateFieldSelected ? Colors.red : Colors.white,
                                                                ),
                                                                disabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(10.0),
                                                                  ),
                                                                  borderSide: BorderSide(color: _birthdateFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: GestureDetector(
                                                          onLongPress: () {
                                                            setState(() {
                                                              _sexFieldSelected = true;
                                                            });
                                                          },
                                                          onTap: () {
                                                            setState(() {
                                                              if (_sexFieldSelected) {
                                                                _sexFieldSelected = false;
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            child: TextFormField(
                                                              autofocus: false,
                                                              readOnly: true,
                                                              enabled: false,
                                                              initialValue: _sex,
                                                              cursorColor: Colors.grey.shade600,
                                                              decoration: InputDecoration(
                                                                contentPadding: EdgeInsets.all(5),
                                                                labelText: 'Sex',
                                                                labelStyle: TextStyle(
                                                                  color: _sexFieldSelected ? Colors.red : Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                                prefixIcon: Icon(
                                                                  Icons.male,
                                                                  color: Color.fromRGBO(252, 58, 72, 32),
                                                                ),
                                                                suffixIcon: Icon(
                                                                  Icons.close,
                                                                  color: _sexFieldSelected ? Colors.red : Colors.white,
                                                                ),
                                                                disabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(10.0),
                                                                  ),
                                                                  borderSide: BorderSide(color: _sexFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Expanded(
                                                        flex: 4,
                                                        child: GestureDetector(
                                                          onLongPress: () {
                                                            setState(() {
                                                              _bloodtypeFieldSelected = true;
                                                            });
                                                          },
                                                          onTap: () {
                                                            setState(() {
                                                              if (_bloodtypeFieldSelected) {
                                                                _bloodtypeFieldSelected = false;
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            child: TextFormField(
                                                              autofocus: false,
                                                              readOnly: true,
                                                              enabled: false,
                                                              initialValue: _bloodtype,
                                                              cursorColor: Colors.grey.shade600,
                                                              decoration: InputDecoration(
                                                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                                labelText: 'Bloodtype',
                                                                labelStyle: TextStyle(
                                                                  color: _bloodtypeFieldSelected ? Colors.red : Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                                prefixIcon: Icon(
                                                                  Icons.bloodtype,
                                                                  color: Color.fromRGBO(252, 58, 72, 32),
                                                                ),
                                                                suffixIcon: Icon(
                                                                  Icons.close,
                                                                  color: _bloodtypeFieldSelected ? Colors.red : Colors.white,
                                                                ),
                                                                disabledBorder: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(10.0),
                                                                  ),
                                                                  borderSide: BorderSide(color: _bloodtypeFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _occupationFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_occupationFieldSelected) {
                                                        _occupationFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        autofocus: false,
                                                        readOnly: true,
                                                        enabled: false,
                                                        initialValue: _occupation,
                                                        cursorColor: Colors.grey.shade600,
                                                        style: TextStyle(
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Occupation',
                                                          labelStyle: TextStyle(
                                                            color: _occupationFieldSelected ? Colors.red : Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.work_outlined,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.close,
                                                            color: _occupationFieldSelected ? Colors.red : Colors.white,
                                                          ),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: _occupationFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _employerFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_employerFieldSelected) {
                                                        _employerFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        autofocus: false,
                                                        readOnly: true,
                                                        enabled: false,
                                                        initialValue: _employer,
                                                        cursorColor: Colors.grey.shade600,
                                                        style: TextStyle(
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Employer',
                                                          labelStyle: TextStyle(
                                                            color: _employerFieldSelected ? Colors.red : Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.work_outlined,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.close,
                                                            color: _employerFieldSelected ? Colors.red : Colors.white,
                                                          ),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: _employerFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _stationAddressFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_stationAddressFieldSelected) {
                                                        _stationAddressFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        autofocus: false,
                                                        readOnly: true,
                                                        enabled: false,
                                                        initialValue: _stationAddress,
                                                        cursorColor: Colors.grey.shade600,
                                                        style: TextStyle(
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Station Address',
                                                          labelStyle: TextStyle(
                                                            color: _stationAddressFieldSelected ? Colors.red : Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.work_outlined,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.close,
                                                            color: _stationAddressFieldSelected ? Colors.red : Colors.white,
                                                          ),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: _stationAddressFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _permanentAddressFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_permanentAddressFieldSelected) {
                                                        _permanentAddressFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        autofocus: false,
                                                        readOnly: true,
                                                        enabled: false,
                                                        initialValue: _permanentAddress,
                                                        cursorColor: Colors.grey.shade600,
                                                        style: TextStyle(
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Permanent Address',
                                                          labelStyle: TextStyle(
                                                            color: _permanentAddressFieldSelected ? Colors.red : Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.location_on_outlined,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.close,
                                                            color: _permanentAddressFieldSelected ? Colors.red : Colors.white,
                                                          ),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: _permanentAddressFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _homeAddressFieldSelected = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      if (_homeAddressFieldSelected) {
                                                        _homeAddressFieldSelected = false;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                                    child: Container(
                                                      child: TextFormField(
                                                        autofocus: false,
                                                        readOnly: true,
                                                        enabled: false,
                                                        initialValue: _homeAddress,
                                                        cursorColor: Colors.grey.shade600,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                          labelText: 'Home Address',
                                                          labelStyle: TextStyle(
                                                            color: _homeAddressFieldSelected ? Colors.red : Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.location_on_outlined,
                                                            color: Color.fromRGBO(252, 58, 72, 32),
                                                          ),
                                                          suffixIcon: Icon(
                                                            Icons.close,
                                                            color: _homeAddressFieldSelected ? Colors.red : Colors.white,
                                                          ),
                                                          disabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0),
                                                            ),
                                                            borderSide: BorderSide(color: _homeAddressFieldSelected ? Colors.red : Color.fromRGBO(82, 82, 82, 1), width: 1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 50.h),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
