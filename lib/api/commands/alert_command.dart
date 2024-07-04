import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/api/command.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';

class AlertCommand extends Command {
  AlertCommand(
      {required super.id,
      required super.name,
      super.desc =
          'Would you like to make sure this message is seen immediately, then alert!',
      super.commandType = 'text/alert'});

  @override
  List getArguments() {
    return [];
  }

  @override
  Future<String?> onDeploy(
      BuildContext context, TextEditingController txtController) async {
    Get.log('command deployed');
    return '';
  }

  @override
  void pushNotif(String fullText, String? messageId) {
    String remainingString = getTrimmedString(fullText);
    ChatController.instance().pushAlertNotification(
        message: remainingString,
        timeStamp: DateTime.now(),
        messageId: messageId ?? '');
  }

  @override
  bool overrideMessageSend() {
    return false;
  }
}
