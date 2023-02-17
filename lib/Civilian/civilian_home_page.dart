import 'package:flutter/material.dart';
import 'package:rtena_app/Civilian/civilian_selected_page.dart';
import 'package:rtena_app/start_page.dart';

class CivHomePage extends StatelessWidget {
  const CivHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(192, 39, 45, 1),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color.fromRGBO(252, 58, 72, 1),
                Color.fromRGBO(70, 18, 32, 1),
              ],
            ),
          ),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Logo - Textfields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),
                  //LOGO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
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
                  ),

                  const SizedBox(height: 25),

                  //Welcome Back
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'What kind of emergency are you involved in?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  //FORM STARTS HERE
                  Container(
                    width: double.infinity,
                    height: 610,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            'Select the button of emergency you want to report.',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        //Grid of Selection
                        Column(
                          children: [
                            //Fire and Health
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                //Button for Fire
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                102, 0, 0, 90),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/fire_icon.png',
                                                  scale: 22,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Fire',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Health
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                153, 0, 51, 40),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/health_icon.png',
                                                  scale: 1.5,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Health',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            //Murder and Assault
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                //Button for Murder
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                95, 2, 31, 40),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/murder_icon.png',
                                                  scale: 1.5,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Murder',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Assault
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                140, 0, 26, 40),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/assault_icon.png',
                                                  scale: 1.5,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Assault',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            //Flood and Earthquake
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                //Button for Flood
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                255, 144, 0, 1),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/flood_icon.png',
                                                  scale: 23,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Flood',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Earthquake
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                55, 6, 23, 40),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/earthquake_icon.png',
                                                  scale: 25,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Earthquake',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            //Kidnapping and Robbery
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                //Button for Kidnapping
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                157, 2, 8, 40),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/kidnap_icon.png',
                                                  scale: 16,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Kidnapping',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                //Button for Robbery
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                220, 47, 2, 40),
                                            border: Border.all(
                                              width: 1.5,
                                              color: Colors.white,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'assets/robbery_icon.png',
                                                  scale: 1.5,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Robbery',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        //Button for Alert
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                "Don't know the emergency? Just press the 'Alert' button",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //Button for Alert - Proceed to selected page
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(232, 93, 4, 40),
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(20)),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const CivSelectedPage()),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/responder_icon.png',
                                            scale: 1.5,
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Alert',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
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
    );
  }
}
