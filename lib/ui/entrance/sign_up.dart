import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordReEntryController;
  late final TextEditingController _userNameController;

  final _emailKey = GlobalKey<FormFieldState>();
  final _usernameKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _rePasswordKey = GlobalKey<FormFieldState>();

  String? emailError;
  String? usernameError;
  String? passwordError;
  String? rePasswordError;

  bool hidePassword = true;
  bool hideRePassword = true;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordReEntryController = TextEditingController();
    _userNameController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordReEntryController.dispose();
    _userNameController.dispose();
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
              Text(Localization.fillInInfo,
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
                  key: _usernameKey,
                  controller: _userNameController,
                  validator: _validateUserName,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: Localization.username,
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
                  controller: _passwordController,
                  obscureText: hidePassword,
                  validator: _validatePassword,
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
              const SizedBox(height: 8),
              Container(
                width: 300.w,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: accentColor),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextFormField(
                  key: _rePasswordKey,
                  controller: _passwordReEntryController,
                  obscureText: hideRePassword,
                  enableSuggestions: false,
                  validator: _validateReEntryPassword,
                  decoration: InputDecoration(
                      labelText: Localization.reEnterPassword,
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
                        icon: Icon(hideRePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          hideRePassword = !hideRePassword;
                          setState(() {});
                        },
                      )),
                ),
              ),
              const SizedBox(height: 32),
              LcButton(
                text: Localization.signUp,
                onPressed: () async {
                  bool emailErr = _emailKey.currentState!.validate();
                  bool userErr = _usernameKey.currentState!.validate();
                  bool passErr = _passwordKey.currentState!.validate();
                  bool rePassErr = _rePasswordKey.currentState!.validate();
                  if (emailErr && userErr && passErr && rePassErr) {
                    var result = await Auth.instance().signUp(
                        _emailController.text,
                        _passwordController.text,
                        _userNameController.text);
                    result.fold((user) {
                      Get.snackbar('Success', 'yay');
                    }, (text) => Get.snackbar(Localization.oops, text));
                  }
                },
              )
            ],
          ),
        ));
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Localization.passwordCantBeEmpty;
    }
    return (value.length >= 8 &&
            value.replaceAll(RegExp(r'[^a-zA-Z]'), '').length >= 2)
        ? null
        : Localization.validatePassword;
  }

  String? _validateReEntryPassword(String? value) {
    if (value == null || value.isEmpty) {
      return Localization.rePasswordCantBeEmpty;
    }
    return (value.length >= 8 &&
            value.replaceAll(RegExp(r'[^a-zA-Z]'), '').length >= 2 &&
            value == _passwordController.text)
        ? null
        : Localization.validateRePassword;
  }

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return Localization.usernameCantBeEmpty;
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
