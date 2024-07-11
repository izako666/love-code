import 'package:flutter/material.dart';
import 'package:love_code/api/commands/alert_command.dart';
import 'package:love_code/api/commands/broken_hearts_command.dart';
import 'package:love_code/api/commands/draw_command.dart';
import 'package:love_code/api/commands/hearts_command.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';

abstract class Command {
  final String id;
  final String name;
  final String desc;
  final String commandType;
  Command({required this.id, required this.name, required this.desc, required this.commandType});

  Future<String?> onDeploy(BuildContext context, TextEditingController txtController);
  Future<void> deployEffect(BuildContext context) async {}
  List<dynamic> getArguments();

  bool overrideMessageSend();

  static List<Command> commands = [
    AlertCommand(id: 'alert', name: 'Alert'),
    DrawCommand(
        id: 'draw', name: 'Draw', desc: 'Would you like to send a personal drawing? click send to start! ', commandType: 'text/draw'),
    HeartsCommand(id: 'hearts', name: 'Hearts'),
    BrokenHeartsCommand(id: 'broken_hearts', name: 'Broken Hearts'),
  ];

  String getTrimmedString(String fullText) {
    return fullText.split('/$id').first;
  }

  void pushNotif(String fullText, String? messageId) {
    String remainingString = getTrimmedString(fullText);
    ChatController.instance().pushNotification(message: remainingString, timeStamp: DateTime.now(), messageId: messageId ?? '');
  }
}
