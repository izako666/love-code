import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:love_code/constants.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:dartz/dartz.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';

class Auth extends GetxController {
  final FirebaseAuth _instance = FirebaseAuth.instance;
  static Auth instance() => Get.find<Auth>();
  Rx<User?> user = Rx<User?>(null);
  RxBool queueVerify = false.obs;
  late final GoogleSignIn googleSignIn;
  @override
  void onInit() {
    super.onInit();
    googleSignIn = GoogleSignIn(scopes: Constants.googleScopes);
    _instance.authStateChanges().listen((u) {
      user.value = u;
    });
  }

  StreamSubscription<User?> setupAuthStateListener() {
    return _instance.authStateChanges().listen((u) {
      if (user.value == null && u != null) {
        Get.toNamed(RouteConstants.home);
      }
      if (user.value != null && u == null) {
        Get.toNamed(RouteConstants.authInit);
      }
    });
  }

  Future<void> reload() async {
    await user.value!.reload();
    user.value = _instance.currentUser;
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    return await _instance.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential?> signInWithGoogle() async {
    GoogleSignInAccount? acc = await googleSignIn.signIn();
    if (acc == null) {
      return Future.value(null);
    }
    GoogleSignInAuthentication authentication = await acc.authentication;
    OAuthCredential provider = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
      accessToken: authentication.accessToken,
    );
    UserCredential user = await _instance.signInWithCredential(provider);
    await FirestoreHandler.instance().createUserDoc(user.user!.uid);
    return user;
  }

  Future<void> signOut() async {
    if (googleSignIn.currentUser != null) {
      await googleSignIn.signOut();
    }
    await _instance.signOut();
  }

  Future<Either<UserCredential?, String>> signUp(
      String email, String password, String userName) async {
    //FirestoreHandler.instance().signUpUser(email, userName);
    try {
      var user = await _instance.createUserWithEmailAndPassword(
          email: email, password: password);
      await FirestoreHandler.instance().createUserDoc(user.user!.uid);
      return Left(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return const Right(Localization.emailAlreadyRegistered);
      } else if (e.code == 'invalid-email') {
        return const Right(Localization.invalidEmail);
      } else if (e.code == 'weak-password') {
        return const Right(Localization.validatePassword);
      } else {
        return const Right('oops');
      }
    }
  }

  Future<void> sendResetPassword(String email) async {
    await _instance.sendPasswordResetEmail(email: email);
  }

  void queueVerifyDialog() {
    queueVerify.value = true;
  }

  Future<void> sendEmailVerification() async {
    user.value!.sendEmailVerification();
  }
}
