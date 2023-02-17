import 'package:flutter/material.dart';
import 'package:rtena_app/start_page.dart';

class SelectedPage extends StatelessWidget {
  const SelectedPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(192, 39, 45, 1),
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
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            children: [
              //Logo - Textfields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
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
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const StartPage()),
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

                        const SizedBox(height: 150),
                        //Emergency Selected
                        const Text(
                          'Emergency Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 20),

                        //Description
                        const Text(
                          'Waiting for confimration of the responders new you. Please hang tight...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 200),
                      ],
                    ),
                  ),

                  //STARTS HERE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
