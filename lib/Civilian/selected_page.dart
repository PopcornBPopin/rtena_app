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

                        const SizedBox(height: 40),
                        //Emergency Selected
                        const Text(
                          'Emergency Selected!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),

                  //STARTS HERE
                  Container(
                    width: double.infinity,
                    height: 590,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              'Waiting for confirmation of the responders near you. Please hang tight.',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                          Image.asset(
                            'assets/emergency_selected.png',
                            scale: 2,
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
    );
  }
}
