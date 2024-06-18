import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:love_code/ui/chat/widgets/chats.dart';
import 'package:love_code/ui/entrance/auth_init.dart';
import 'package:love_code/ui/entrance/sign_in.dart';
import 'package:love_code/ui/entrance/sign_up.dart';
import 'package:love_code/ui/entrance/splash_screen.dart';

class AppRoutes {
  static List<GetPage> pages = [
    GetPage(name: RouteConstants.splash, page: () => const SplashScreen()),
    GetPage(
        name: RouteConstants.authInit,
        page: () => const AuthInitScreen(),
        children: [
          GetPage(
              name: RouteConstants.signIn,
              page: () => const SignInScreen(),
              children: [
                GetPage(
                    name: RouteConstants.signUpEmail,
                    page: () => const SignUpScreen())
              ]),
        ]),
    GetPage(name: RouteConstants.home, page: () => const ChatScreen())
  ];
}

class RouteConstants {
  static const splash = '/';
  static const home = '/home';
  static const authInit = '/auth_init';
  static const signIn = '/sign_in';
  static const signUpEmail = '/sign_up_email';
}
