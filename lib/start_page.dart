import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rtena_app/Welcome/page1.dart';
import 'package:rtena_app/login_page.dart';
import 'package:rtena_app/SignUp/sign_page_1.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'Welcome/page2.dart';
import 'Welcome/page3.dart';

// import 'package:rtena_app/old_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => animateSlider());
  }

  void animateSlider() {
    Future.delayed(Duration(seconds: 2)).then((_) {
      int nextPage = _pageController.page!.round() + 1;
      if (nextPage == 3) {
        nextPage = 0;
      }
      _pageController.animateToPage(nextPage, duration: Duration(milliseconds: 1500), curve: Curves.ease).then((_) => animateSlider());
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Container(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.h),

                    //Logo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Image.asset(
                              'assets/RLOGO.png',
                              scale: 20,
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            child: Image.asset(
                              'assets/RTena.png',
                              scale: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Column(
                      children: [
                        Container(
                          height: 530.h,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false).copyWith(scrollbars: false),
                            child: PageView(
                              controller: _pageController,
                              children: [
                                Page1(),
                                Page2(),
                                Page3()
                              ],
                            ),
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: 3,
                          effect: ExpandingDotsEffect(activeDotColor: Colors.white, dotColor: Colors.white, dotHeight: 5, dotWidth: 20),
                        )
                      ],
                    ),
                    SizedBox(height: 50.h),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                Get.to(
                                  () => const LoginPage(),
                                  transition: await Transition.fadeIn,
                                  duration: const Duration(milliseconds: 200),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: SizedBox(
                                height: 60.h,
                                child: Center(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            //Sign Up Button
                            ElevatedButton(
                              onPressed: () async {
                                Get.to(
                                  () => const Sign1Page(),
                                  transition: await Transition.fadeIn,
                                  duration: const Duration(milliseconds: 200),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: SizedBox(
                                height: 60.h,
                                child: Center(
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
