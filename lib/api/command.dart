import 'package:flutter/material.dart';
import 'package:love_code/api/commands/alert_command.dart';
import 'package:love_code/api/commands/draw_command.dart';
import 'package:love_code/api/commands/test_command.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';

abstract class Command {
  final String id;
  final String name;
  final String desc;
  final String commandType;
  Command(
      {required this.id,
      required this.name,
      required this.desc,
      required this.commandType});

  Future<String?> onDeploy(
      BuildContext context, TextEditingController txtController);

  List<dynamic> getArguments();

  bool overrideMessageSend();

  static List<Command> commands = [
    AlertCommand(id: 'alert', name: 'Alert'),
    DrawCommand(
        id: 'draw',
        name: 'Draw',
        desc:
            'Would you like to send a personal drawing? click send to start! ',
        commandType: 'text/draw'),
    TestCommand(id: 'test_3', name: 'Test 3'),
    TestCommand(id: 'test_4', name: 'Test 4'),
  ];

  String getTrimmedString(String fullText) {
    return fullText.split('/$id').first;
  }

  void pushNotif(String fullText, String? messageId) {
    String remainingString = getTrimmedString(fullText);
    ChatController.instance().pushNotification(
        message: remainingString,
        timeStamp: DateTime.now(),
        messageId: messageId ?? '');
  }
}
