import 'package:flutter/material.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/SignUp/sign_page_1.dart';
// import 'package:rtena_app/old_page.dart';

// class StartPage extends StatefulWidget {
//   @override
//   State<StartPage> createState() => _StartPageState();
// }

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 35),

            //Logo
            SizedBox(
              child: Image.asset(
                'assets/RTena.png',
                scale: 1.2,
              ),
            ),
            const SizedBox(height: 110),

            //R Logo

            Center(
              child: Image.asset(
                'assets/RLOGO.png',
                scale: 2.5,
              ),
            ),
            const SizedBox(height: 110),

            //Title
            const Text(
              'Real-Time Emergency Notifier',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 10),

            //Description
            const Text(
              'Stay safe, always connected: be prepared with our emergency notifier app',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 35),

            //Login Button
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LoginPage()),
                  );
                },
                child: Container(
                  width: 700,
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: const Center(
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
            const SizedBox(height: 10),

            //Sign Up Button
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Sign1Page()),
                  );
                },
                child: Container(
                  width: 700,
                  height: 45,
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  child: const Center(
                      child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
