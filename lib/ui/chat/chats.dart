import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/api/command.dart';

import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/audio/audio_controller.dart';
import 'package:love_code/portable_api/audio/ui/recording_waveform.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/portable_api/chat/widgets/audio_message_widget.dart';
import 'package:love_code/portable_api/chat/widgets/message_widget.dart';
import 'package:love_code/portable_api/local_data/local_data.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';
import 'package:love_code/resources.dart';
import 'package:love_code/ui/chat/widgets/menu_drawer.dart';
import 'package:love_code/ui/helper/scrollable_text.dart';
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
  bool showCommandInfo = true;
  Command? mostLikelyCommand;
  List<Command> availableCommands = Command.commands;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  void initState() {
    _controller = TextEditingController();
    _controller.addListener(() {
      if (_controller.text.startsWith('/')) {
        mostLikelyCommand =
            findMostSimilarCommand(_controller.text.substring(1));
        availableCommands =
            filterCommands(Command.commands, _controller.text.substring(1));
      }
      setState(() {});
    });
    chatController = Get.find<ChatController>();
    showCommandInfo =
        LocalDataHandler.readData<bool>('show_command_info', true);

    Get.put<AudioController>(AudioController());
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
                    if ((replyMessage != null || editMessage != null) &&
                        !_controller.text.startsWith('/')) ...[
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
                    ],
                    if (_controller.text.startsWith('/')) ...[
                      Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                              constraints: BoxConstraints(
                                  maxHeight: 120,
                                  minHeight: 60,
                                  maxWidth: MediaQuery.sizeOf(context).width,
                                  minWidth: MediaQuery.sizeOf(context).width),
                              color: backgroundColor,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: availableCommands.length,
                                  itemBuilder: (ctx, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        _controller.text =
                                            '/${availableCommands[i].id}';
                                      },
                                      child: Container(
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          height: 60,
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: primaryColor,
                                                      width: 2))),
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 4),
                                              Text(availableCommands[i].name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium),
                                              const Spacer(),
                                              Text(availableCommands[i].id,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                              const SizedBox(width: 16)
                                            ],
                                          )),
                                    );
                                  })))
                    ],
                    if (_controller.text.startsWith('/')) ...[
                      Positioned(
                          top: 8,
                          left: 4,
                          child: IconButton(
                              onPressed: () {
                                showCommandInfo = !showCommandInfo;
                                LocalDataHandler.addData(
                                    'show_command_info', showCommandInfo);
                                setState(() {});
                              },
                              icon: Stack(children: [
                                const Icon(Icons.info),
                                !showCommandInfo
                                    ? const Icon(
                                        Icons.close,
                                        color: primaryColor,
                                      )
                                    : Container()
                              ]))),
                      if (showCommandInfo && mostLikelyCommand != null) ...[
                        Positioned(
                          top: 20,
                          left: 42,
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width - 150,
                            child: ScrollableText(
                              text:
                                  '${mostLikelyCommand!.name}:${mostLikelyCommand!.desc}',
                              style: Theme.of(context).textTheme.bodyMedium!,
                            ),
                          ),
                        )
                      ]
                    ],
                  ],
                ),
              ),
            ),
            InputArea(
              controller: _controller,
              editMessage: editMessage,
              handleEdit: _handleEdit,
              handleMessageSend: _handleMessageSend,
            )
          ],
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Command? findMostSimilarCommand(String query) {
    for (var command in Command.commands) {
      if (command.id.startsWith(query)) {
        return command;
      }
    }
    return null;
  }

  List<Command> filterCommands(List<Command> commands, String input) {
    if (input.isEmpty) {
      return commands;
    } else {
      return commands.where((command) => command.id.startsWith(input)).toList();
    }
  }

  void _handleEdit(Message editMsg) {
    FirestoreHandler.instance().editMessage(
        ChatController.instance().chatRoom.value!, editMsg, _controller.text);
    replyMessage = null;
    editMessage = null;
    _controller.clear();
    setState(() {});
  }

  void _handleMessageSend() async {
    if (_controller.text.startsWith('/')) {
      String possibleCommand = _controller.text.split('/')[0].split(' ')[0];
      Command? chosenCommand;
      for (int i = 0; i < Command.commands.length; i++) {
        if (possibleCommand == Command.commands[i].id) {
          chosenCommand = Command.commands[i];
          break;
        }
      }
      if (chosenCommand != null) {
        await chosenCommand.onDeploy(context);
      }
    }
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

class InputArea extends StatefulWidget {
  const InputArea(
      {super.key,
      required this.controller,
      required this.editMessage,
      required this.handleEdit,
      required this.handleMessageSend});
  final TextEditingController controller;
  final Message? editMessage;
  final Function(Message) handleEdit;
  final Function() handleMessageSend;

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  bool recording = false;
  File? recordingFile;
  bool recordingCanceled = false;
  late AudioController audioController;
  @override
  void initState() {
    super.initState();
    audioController = Get.find<AudioController>();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!recording) ...[
          Expanded(
            child: SizedBox(
              width: 400,
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: widget.controller,
              ),
            ),
          )
        ],
        if (recording) ...[
          const Icon(Icons.delete),
          RecordingWaveform(
              stream:
                  audioController.waveformData.stream.map((lDb) => lDb.last),
              width: MediaQuery.sizeOf(context).width * 0.6,
              height: 80,
              color: recordingCanceled ? Colors.red : Colors.white,
              thickness: 10)
        ],
        GestureDetector(
            onLongPress: () async {
              AudioController audioController = Get.find<AudioController>();
              recordingFile = await audioController.startRecording();
              recording = true;
              setState(() {});
            },
            onLongPressEnd: (details) async {
              if (recordingCanceled) {
                recordingCanceled = false;
                await audioController.endRecording();
                await recordingFile?.delete();
                recordingFile = null;
                recording = false;
                setState(() {});
              } else {
                String? filePath = await audioController.endRecording();
                if (filePath != null) {
                  String fileName = filePath.split('/').last.split('.').first;
                  Message message = Message(
                      message: '',
                      senderId: Auth.instance().user.value!.uid,
                      timeStamp: DateTime.now(),
                      messageType: MESSAGETYPES.audio.name,
                      downloadUrl: null,
                      durationTime: AudioController.instance.durationTime!,
                      file: null,
                      waves: AudioController.instance.waveformData.toList());
                  ChatController.instance()
                      .sendAudioFile(fileName, recordingFile!, message);
                  recording = false;
                  setState(() {});
                }
              }
            },
            onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
              Offset offset = details.localOffsetFromOrigin;
              if (offset.dy.abs() <= 30 &&
                  offset.dx <= -100 &&
                  !recordingCanceled) {
                recordingCanceled = true;
                setState(() {});
              } else if (recordingCanceled) {
                recordingCanceled = false;
                setState(() {});
              }
            },
            child: Icon(Icons.mic)),
        IconButton(
          icon: Icon(
            widget.editMessage != null ? Icons.check : Icons.send,
            color: AppTheme.theme.colorScheme.primary,
          ),
          onPressed: () {
            if (widget.editMessage != null &&
                !widget.controller.text.startsWith('/')) {
              widget.handleEdit(widget.editMessage!);
            } else {
              widget.handleMessageSend();
            }
          },
        ),
      ],
    );
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
            child: msg.messageType == MESSAGETYPES.audio.name
                ? AudioMessageWidget(
                    msg: msg,
                    isReply: isReply,
                    onReplyTap: onReplyTap,
                    onDeleteTap: onDeleteTap,
                  )
                : MessageWidget(
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
