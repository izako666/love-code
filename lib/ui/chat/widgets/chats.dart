import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/portable_api/chat/widgets/message_widget.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';
import 'package:love_code/resources.dart';
import 'package:love_code/ui/chat/widgets/menu_drawer.dart';

import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _controller;
  late final ChatController chatController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  void initState() {
    _controller = TextEditingController();
    chatController = Get.put<ChatController>(ChatController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
        scaffoldKey: _key,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        drawer: const LcMenuDrawer(),
        appBar: LcAppBar(
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Scaffold.of(context).openDrawer();
                _key.currentState!.openDrawer();
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  Resources.heartLogo,
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(Localization.appTitle,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        wordSpacing: 1.2,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(
                  width: 50,
                ),
              ],
            )),
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                    itemCount: chatController.messages.length,
                    reverse: true,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      Message msg = chatController.messages[
                          chatController.messages.length - (index + 1)];
                      return Align(
                          alignment: msg.senderId == '0ddw'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: msg.senderId == '0ddw'
                                      ? [
                                          Colors.transparent,
                                          Theme.of(context).colorScheme.primary
                                        ]
                                      : [
                                          Theme.of(context).colorScheme.primary,
                                          Colors.transparent
                                        ],
                                  stops: msg.senderId == '0ddw'
                                      ? const [0.95, 1]
                                      : const [0, 0.05]),
                              borderRadius: msg.senderId == '0ddw'
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16))
                                  : const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16.0,
                                  top: 8.0,
                                  right: 8.0,
                                  left: 8.0),
                              child: MessageWidget(msg: msg),
                            ),
                          ));
                    }),
              ),
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                icon: Icon(
                  Icons.send,
                  color: AppTheme.theme.colorScheme.primary,
                ),
                onPressed: () {
                  _handleMessageSend();
                },
              )),
            )
          ],
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleMessageSend() {
    Message(
            message: _controller.text,
            senderId: Auth.instance().user.value!.uid,
            timeStamp: DateTime.now())
        .sendMessage('U9YSnKNBEFpATnRM2Y9R');
    _controller.clear();
  }
}
