import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rtena_app/Civilian/civilian_start_page.dart';
import 'package:rtena_app/Responder/responder_start_page.dart';
import 'package:rtena_app/start_page.dart';
import 'Civilian/civilian_home_page.dart';

class CheckerPage extends StatefulWidget {
  const CheckerPage({Key? key}) : super(key: key);

  @override
  State<CheckerPage> createState() => _CheckerPageState();
}

class _CheckerPageState extends State<CheckerPage> {
  late String _emailAddress = "";
  late String _role = "";

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  //Grab user document from Firebase Firestone
  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    _emailAddress = user!.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_emailAddress).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
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
                    child: Image.asset(
                      'assets/RLOGO.png',
                      scale: 4,
                    ),
                  );
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                _role = userData['Role'];
                if (_role == 'Civilian') {
                  print("Role is civilian");
                  Future.delayed(const Duration(seconds: 5));
                  return CivStartPage();
                } else if (_role == 'Responder') {
                  print("Role is responder");
                  Future.delayed(const Duration(seconds: 5));
                  return ResStartPage();
                }
                return StartPage();
              },
            );
            // return CivStartPage();
          } else {
            return StartPage();
          }
        },
      ),
    );
  }
}
