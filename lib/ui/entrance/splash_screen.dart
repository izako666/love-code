import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/local_data/local_data.dart';
import 'package:love_code/resources.dart';
import 'package:love_code/state_management/onboarding_controller.dart';
import 'package:love_code/state_management/splash_controller.dart';
import 'package:love_code/ui/helper/ui_helper.dart';
import 'package:love_code/ui/theme.dart';

/// This class acts as both an entry way splash screen and a loading screen,
/// this page will continue to preview till the app is initialized.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    //loading stuff
    setupApp();
  }

  Future<void> setupApp() async {
    //loading stuff
    await LocalDataHandler.initDataHandler();
    OnboardingController onboardingController =
        Get.put<OnboardingController>(OnboardingController());
    Future.delayed(const Duration(seconds: 2), () {
      loading = false;

      setState(() {});
      if (!onboardingController.seenOnboarding.value) {
        Get.toNamed(RouteConstants.onBoarding);
      } else {
        Get.toNamed(RouteConstants.authInit);
      }
      Get.find<SplashController>().loading.value = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            backgroundColor,
            primaryColor.darken(0.4),
            backgroundColor
          ],
              stops: const [
            0.20,
            0.5,
            0.80
          ])),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Resources.heartLogo,
              width: 120,
              height: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(Localization.appTitle,
                style: Theme.of(context).textTheme.headlineLarge)
          ],
        ),
      ),
    ));
  }
}
