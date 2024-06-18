import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();

  String? emailError;
  String? passwordError;

  bool hidePassword = true;
  bool hideRePassword = true;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: const LcAppBar(
          title: Text(Localization.signUp),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              Text(Localization.signIn,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(
                height: 32,
              ),
              Container(
                width: 300.w,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: accentColor),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextFormField(
                  key: _emailKey,
                  controller: _emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: Localization.email,
                      errorStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.redAccent),
                      errorMaxLines: 2,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 300.w,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: accentColor),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextFormField(
                  key: _passwordKey,
                  validator: _validatePassword,
                  controller: _passwordController,
                  obscureText: hidePassword,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                      labelText: Localization.password,
                      errorStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.redAccent),
                      errorMaxLines: 2,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          hidePassword = !hidePassword;
                          setState(() {});
                        },
                      )),
                ),
              ),
              const SizedBox(height: 32),
              LcButton(
                text: Localization.signIn,
                onPressed: () async {
                  bool emailErr = _emailKey.currentState!.validate();
                  bool passErr = _passwordKey.currentState!.validate();

                  if (emailErr && passErr) {
                    await Auth.instance().signInWithEmail(
                        _emailController.text, _passwordController.text);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Get.toNamed(RouteConstants.authInit +
                      RouteConstants.signIn +
                      RouteConstants.signUpEmail);
                },
                child: Text(
                  Localization.noAccount,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: hintColor),
                ),
              )
            ],
          ),
        ));
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Localization.passwordCantBeEmpty;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Localization.emailCantBeEmpty;
    }

    // Regular expression for validating an email
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return Localization.validateEmail;
    }
    return null;
  }
}
