import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/start_page.dart';
import 'Civilian/civilian_home_page.dart';

class CheckerPage extends StatelessWidget {
  const CheckerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('Singned In');
            return CivHomePage();
          } else {
            print('NOT');
            return StartPage();
          }
        },
      ),
    );
  }
}
