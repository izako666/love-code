import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/firebase_options.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';
import 'package:love_code/state_management/splash_controller.dart';
import 'package:love_code/ui/entrance/splash_screen.dart';
import 'package:love_code/ui/theme.dart';
import 'package:photo_manager/photo_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  PhotoManager.clearFileCache();
  //Get Controller Init
  Get.put<Auth>(Auth());
  Get.put<FirestoreHandler>(FirestoreHandler());
  Get.put<SplashController>(SplashController());
  await initializeNotifications();
  await createNotificationChannels();
  await setupBackgroundMessageHandler();
  runApp(const MyApp());
}

Future<void> setupBackgroundMessageHandler() async {
  FirebaseMessaging.onBackgroundMessage((msg) async {
    if (msg.data['lasagna']) {}
  });
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> createNotificationChannels() async {
  Int64List vibrations = Int64List(6);
  vibrations[0] = 0;
  vibrations[1] = 200;
  vibrations[2] = 100;
  vibrations[3] = 50;
  vibrations[4] = 25;
  vibrations[5] = 10;
  AndroidNotificationChannel alertChannel = AndroidNotificationChannel(
      'alert_channel', // channel ID
      'Alert Notifications', // channel name
      description: 'Incoming alert notifications',
      vibrationPattern: vibrations,
      importance: Importance.high,
      audioAttributesUsage: AudioAttributesUsage.notificationEvent);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(alertChannel);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? prevUser;
  @override
  void initState() {
    super.initState();
    prevUser = Auth.instance().user.value;
    if (prevUser != null) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Get.toNamed(RouteConstants.home);
      // });
      Get.find<SplashController>().loading.listen((val) {
        if (!val) {
          Get.toNamed(RouteConstants.home);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      child: GetMaterialApp(
        title: 'Love Code',
        theme: AppTheme.theme,
        builder: (context, child) {
          return StreamBuilder<User?>(
              initialData: prevUser,
              stream: Auth.instance().user.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData && prevUser == null) {
                  prevUser = snapshot.data;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.toNamed(RouteConstants.home);
                  });
                } else if (!snapshot.hasData && prevUser != null) {
                  prevUser = null;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.toNamed(RouteConstants.authInit);
                  });
                }
                return child!;
              });
        },
        home: const MyHomePage(title: 'Love Code'),
        initialRoute: '/',
        getPages: AppRoutes.pages,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
