import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:love_code/portable_api/drawing/drawing_screen.dart';
import 'package:love_code/ui/chat/chats.dart';
import 'package:love_code/ui/chat/home_loading.dart';
import 'package:love_code/ui/chat/make_room.dart';
import 'package:love_code/ui/entrance/auth_init.dart';
import 'package:love_code/ui/entrance/on_boarding.dart';
import 'package:love_code/ui/entrance/sign_in.dart';
import 'package:love_code/ui/entrance/sign_up.dart';
import 'package:love_code/ui/entrance/splash_screen.dart';

class AppRoutes {
  static List<GetPage> pages = [
    GetPage(name: RouteConstants.splash, page: () => const SplashScreen()),
    GetPage(
        name: RouteConstants.onBoarding, page: () => const OnboardingScreen()),
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
    GetPage(name: RouteConstants.home, page: () => const HomeLoadingScreen()),
    GetPage(
        name: RouteConstants.chats,
        page: () => const ChatScreen(),
        children: [
          GetPage<bool>(
              name: RouteConstants.drawingScreen,
              page: () => const DrawingScreen())
        ]),
    GetPage(name: RouteConstants.makeRoom, page: () => const MakeRoomScreen())
  ];
}

class RouteConstants {
  static const splash = '/';
  static const home = '/home';
  static const chats = '/chats';
  static const makeRoom = '/make_room';
  static const authInit = '/auth_init';
  static const signIn = '/sign_in';
  static const signUpEmail = '/sign_up_email';
  static const onBoarding = '/on_boarding';
  static const drawingScreen = '/drawing_screen';
}
