import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class AuthInitScreen extends StatelessWidget {
  const AuthInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      extendBodyBehindAppBar: true,
      appBar: const LcAppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LcButton(
              text: 'Sign In',
              onPressed: () {
                Get.toNamed(RouteConstants.authInit + RouteConstants.signIn);
              }),
          const SizedBox(height: 16),
          LcButton(
            text: 'Sign In with Google',
            onPressed: () {
              Auth.instance().signInWithGoogle();
            },
          )
        ],
      ),
    );
  }
}
