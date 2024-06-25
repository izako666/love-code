import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/portable_api/chat/widgets/message_widget.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';
import 'package:love_code/resources.dart';
import 'package:love_code/ui/chat/widgets/menu_drawer.dart';
import 'package:love_code/ui/helper/ui_helper.dart';

import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_dialog.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _controller;
  late final ChatController chatController;
  Message? replyMessage;
  Message? editMessage;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  void initState() {
    _controller = TextEditingController();
    chatController = Get.find<ChatController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String currentId = Auth.instance().user.value!.uid;
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
                () => Stack(
                  children: [
                    ListView.builder(
                        itemCount: chatController.messages.length,
                        reverse: true,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Message msg = chatController.messages[
                              chatController.messages.length - (index + 1)];
                          return Align(
                              alignment: msg.senderId != currentId
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Dismissible(
                                key: GlobalKey(),
                                direction: msg.senderId != currentId
                                    ? DismissDirection.endToStart
                                    : DismissDirection.startToEnd,
                                dismissThresholds: const {
                                  DismissDirection.endToStart: 0.2,
                                  DismissDirection.startToEnd: 0.2
                                },
                                confirmDismiss: (d) async {
                                  replyMessage = msg;
                                  editMessage = null;
                                  setState(() {});
                                  return false;
                                },
                                child: MessageWidgetPretty(
                                  msg: msg,
                                  currentId: currentId,
                                  right: msg.senderId != currentId,
                                  onReplyTap: () {
                                    replyMessage = msg;
                                    editMessage = null;
                                    setState(() {});
                                  },
                                  onCopyTap: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: msg.message));
                                  },
                                  onEditTap: () {
                                    _controller.value =
                                        TextEditingValue(text: msg.message);
                                    editMessage = msg;
                                    replyMessage = null;
                                    setState(() {});
                                  },
                                  onDeleteTap: () {
                                    showLcDialog(
                                        title: Localization.deleteMessage,
                                        desc: Localization.confirmDecision,
                                        actions: [
                                          LcButton(
                                            width: 75.w,
                                            height: 35.w,
                                            text: Localization.delete,
                                            onPressed: () {
                                              FirestoreHandler.instance()
                                                  .deleteMessage(
                                                      ChatController.instance()
                                                          .chatRoom
                                                          .value!,
                                                      msg);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          const SizedBox(width: 16),
                                          LcButton(
                                            width: 75.w,
                                            height: 35.w,
                                            text: Localization.cancel,
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ]);
                                  },
                                ),
                              ));
                        }),
                    if (replyMessage != null || editMessage != null) ...[
                      Positioned(
                          bottom: 0,
                          left: 0,
                          child: Column(
                            children: [
                              MessageWidgetPretty(
                                msg: replyMessage ?? editMessage!,
                                currentId: currentId,
                                right: false,
                                isReply: true,
                              ),
                            ],
                          )),
                      Positioned(
                          bottom: 0,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              replyMessage = null;
                              editMessage = null;
                              setState(() {});
                            },
                          ))
                    ]
                  ],
                ),
              ),
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                icon: Icon(
                  editMessage != null ? Icons.check : Icons.send,
                  color: AppTheme.theme.colorScheme.primary,
                ),
                onPressed: () {
                  if (editMessage != null) {
                    _handleEdit(editMessage!);
                  } else {
                    _handleMessageSend();
                  }
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

  void _handleEdit(Message editMsg) {
    FirestoreHandler.instance().editMessage(
        ChatController.instance().chatRoom.value!, editMsg, _controller.text);
    replyMessage = null;
    editMessage = null;
    _controller.clear();
    setState(() {});
  }

  void _handleMessageSend() {
    Message(
      message: _controller.text,
      senderId: Auth.instance().user.value!.uid,
      replyToRef: replyMessage,
      timeStamp: DateTime.now(),
    ).sendMessage(ChatController.instance().chatRoom.value!);
    ChatController.instance()
        .pushNotification(message: _controller.text, timeStamp: DateTime.now());
    _controller.clear();
    replyMessage = null;
    editMessage = null;
    setState(() {});
  }
}

class MessageWidgetPretty extends StatelessWidget {
  const MessageWidgetPretty({
    super.key,
    required this.msg,
    required this.currentId,
    required this.right,
    this.isReply = false,
    this.onReplyTap,
    this.onCopyTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  final Message msg;
  final String currentId;
  final bool right;
  final bool isReply;
  final Function()? onReplyTap;
  final Function()? onCopyTap;
  final Function()? onEditTap;
  final Function()? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (msg.replyToRef != null && !isReply) ...[
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .darken(0.5)
                    .withAlpha(125),
                borderRadius: right
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16))
                    : const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16))),
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 16.0, top: 8.0, right: 8.0, left: 8.0),
              child: MessageWidget(
                msg: msg.replyToRef!,
                isReply: false,
              ),
            ),
          )
        ],
        Container(
          width: isReply ? MediaQuery.sizeOf(context).width : null,
          decoration: BoxDecoration(
            color: isReply
                ? Theme.of(context).colorScheme.primary.darken(0.5)
                : null,
            gradient: !isReply
                ? LinearGradient(
                    colors: right
                        ? [
                            Colors.transparent,
                            Theme.of(context).colorScheme.primary
                          ]
                        : [
                            Theme.of(context).colorScheme.primary,
                            Colors.transparent
                          ],
                    stops: right ? const [0.95, 1] : const [0, 0.05])
                : null,
            borderRadius: isReply
                ? null
                : right
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16))
                    : const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: 16.0, top: 8.0, right: 8.0, left: 8.0),
            child: MessageWidget(
              msg: msg,
              onReplyTap: onReplyTap,
              onCopyTap: onCopyTap,
              onEditTap: onEditTap,
              onDeleteTap: onDeleteTap,
              isReply: isReply,
            ),
          ),
        ),
      ],
    );
  }
}
