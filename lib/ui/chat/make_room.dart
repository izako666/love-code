import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/ui/chat/widgets/menu_drawer.dart';
import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_dialog.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class MakeRoomScreen extends StatefulWidget {
  const MakeRoomScreen({super.key});

  @override
  State<MakeRoomScreen> createState() => _MakeRoomScreenState();
}

class _MakeRoomScreenState extends State<MakeRoomScreen> {
  late final TextEditingController _controller1;
  late final TextEditingController _controller2;
  late final TextEditingController _controller3;
  late final TextEditingController _controller4;
  late final TextEditingController _controller5;
  late final TextEditingController _controller6;
  late final FocusNode _node1;
  late final FocusNode _node2;
  late final FocusNode _node3;
  late final FocusNode _node4;
  late final FocusNode _node5;
  late final FocusNode _node6;
  List<String> myKeys = List.filled(6, '');
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String? roomCode;
  @override
  void initState() {
    super.initState();
    if (Auth.instance().queueVerify.value) {
      Auth.instance().queueVerify.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showLcDialog(title: Localization.plsVerifyEmail, desc: Localization.needToConfirmYou, actions: [
          LcButton(
            width: 75.w,
            height: 35.w,
            text: Localization.verify,
            onPressed: () async {
              Auth.instance().sendEmailVerification().whenComplete(() {
                Get.snackbar(Localization.success, Localization.emailVerifySent, snackPosition: SnackPosition.BOTTOM);
              });
              Navigator.pop(context);
            },
          ),
          LcButton(
            width: 75.w,
            height: 35.w,
            text: Localization.later,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ]);
      });
    }
    ChatController.instance().hookInChatroomCheck();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
    _controller3 = TextEditingController();
    _controller4 = TextEditingController();
    _controller5 = TextEditingController();
    _controller6 = TextEditingController();
    _node1 = FocusNode();
    _node2 = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
        _node1.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    });
    _node3 = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
        _node2.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    });
    _node4 = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
        _node3.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    });
    _node5 = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
        _node4.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    });
    _node6 = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
        _node5.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    });

    _controller1.addListener(() {
      if (_controller1.value.text.isNotEmpty && myKeys[0] != _controller1.text) {
        myKeys[0] = _controller1.text;

        _node2.requestFocus();
      }
    });
    _controller2.addListener(() {
      if (_controller2.value.text.isNotEmpty && myKeys[1] != _controller2.text) {
        myKeys[1] = _controller2.text;
        _node3.requestFocus();
      }
    });
    _controller3.addListener(() {
      if (_controller3.value.text.isNotEmpty && myKeys[2] != _controller3.text) {
        myKeys[2] = _controller3.text;

        _node4.requestFocus();
      }
    });
    _controller4.addListener(() {
      if (_controller4.value.text.isNotEmpty && myKeys[3] != _controller4.text) {
        myKeys[3] = _controller4.text;

        _node5.requestFocus();
      }
    });
    _controller5.addListener(() {
      if (_controller5.value.text.isNotEmpty && myKeys[4] != _controller5.text) {
        myKeys[4] = _controller5.text;
        _node6.requestFocus();
      }
    });
    _controller6.addListener(() {
      if (_controller2.value.text.isNotEmpty && checkControllerFull() && myKeys[5] != _controller6.text) {
        myKeys[5] = _controller6.text;
        ChatController.instance().confirmRoomCode(combineControllerTexts());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
    _node1.dispose();
    _node2.dispose();
    _node3.dispose();
    _node4.dispose();
    _node5.dispose();
    _node6.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      scaffoldKey: _key,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      drawer: const LcMenuDrawer(),
      appBar: LcAppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _key.currentState!.openDrawer();
          },
        ),
        title: Text(Localization.makeRoom, style: Theme.of(context).textTheme.headlineLarge!),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: kToolbarHeight * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OTPTextField(
                    controller: _controller1,
                    node: _node1,
                    onPaste: onPaste,
                  ),
                  OTPTextField(
                    controller: _controller2,
                    node: _node2,
                    onPaste: onPaste,
                  ),
                  OTPTextField(
                    controller: _controller3,
                    node: _node3,
                    onPaste: onPaste,
                  ),
                  OTPTextField(
                    controller: _controller4,
                    node: _node4,
                    onPaste: onPaste,
                  ),
                  OTPTextField(
                    controller: _controller5,
                    node: _node5,
                    onPaste: onPaste,
                  ),
                  OTPTextField(
                    controller: _controller6,
                    node: _node6,
                    onPaste: onPaste,
                  ),
                ],
              ),
              SizedBox(height: 0.2.sh),
              LcButton(
                text: Localization.confirmRoomCode,
                onPressed: () {
                  if (checkControllerFull()) {
                    ChatController.instance().confirmRoomCode(combineControllerTexts());
                  } else {
                    Get.snackbar(Localization.oops, Localization.fillAllFields);
                  }
                },
              ),
              TextButton(
                onPressed: () async {
                  try {
                    roomCode = await ChatController.instance().createRoomCode();
                    setState(() {});
                  } catch (e) {
                    Get.snackbar(Localization.oops, Localization.smthnBad);
                  }
                },
                child: Text(
                  Localization.createRoomCode,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: hintColor),
                ),
              ),
              if (roomCode != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(roomCode!, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20)),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: roomCode!));
                        Get.snackbar(Localization.success, Localization.copiedToClipboard, snackPosition: SnackPosition.BOTTOM);
                      },
                    )
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  bool checkControllerFull() {
    return _controller1.text.isNotEmpty &&
        _controller2.text.isNotEmpty &&
        _controller3.text.isNotEmpty &&
        _controller4.text.isNotEmpty &&
        _controller5.text.isNotEmpty &&
        _controller6.text.isNotEmpty;
  }

  String combineControllerTexts() {
    return '${_controller1.text}${_controller2.text}${_controller3.text}${_controller4.text}${_controller5.text}${_controller6.text}';
  }

  void onPaste(String data) {
    _controller1.text = data[0];
    _controller2.text = data[1];
    _controller3.text = data[2];
    _controller4.text = data[3];
    _controller5.text = data[4];
    _controller6.text = data[5];
  }
}

class OTPTextField extends StatelessWidget {
  const OTPTextField({
    super.key,
    required this.controller,
    required this.node,
    required this.onPaste,
  });
  final TextEditingController controller;
  final FocusNode node;
  final Function(String) onPaste;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 45.w,
        height: 45.w,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: secondaryColor, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(24))),
        child: Align(
          alignment: Alignment.center,
          child: TextField(
            contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
              return AdaptiveTextSelectionToolbar(
                  anchors: editableTextState.contextMenuAnchors,
                  // Build the default buttons, but make them look custom.
                  // In a real project you may want to build different
                  // buttons depending on the platform.
                  children: editableTextState.contextMenuButtonItems.map((ContextMenuButtonItem buttonItem) {
                    return CupertinoButton(
                      borderRadius: null,
                      onPressed: () async {
                        String label = CupertinoTextSelectionToolbarButton.getButtonLabel(context, buttonItem);
                        ClipboardData? data = await Clipboard.getData('text/plain');
                        if (label == 'Paste' && data != null && data.text!.length >= 6) {
                          onPaste(data.text!);
                        } else {
                          if (buttonItem.onPressed != null) {
                            buttonItem.onPressed!();
                          }
                        }
                      },
                      padding: const EdgeInsets.all(10.0),
                      pressedOpacity: 0.7,
                      child: SizedBox(
                        width: 50.0,
                        child: Text(
                          CupertinoTextSelectionToolbarButton.getButtonLabel(context, buttonItem),
                        ),
                      ),
                    );
                  }).toList());
            },
            maxLength: 1,
            controller: controller,
            focusNode: node,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
            decoration: const InputDecoration(
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                counterText: ''),
          ),
        ),
      ),
    );
  }
}
