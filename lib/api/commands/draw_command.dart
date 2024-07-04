import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:get/get.dart';
import 'package:love_code/api/command.dart';
import 'package:love_code/constants.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/portable_api/drawing/drawing_board.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_dialog.dart';

class DrawCommand extends Command {
  DrawCommand(
      {required super.id,
      required super.name,
      required super.desc,
      required super.commandType});

  @override
  List getArguments() {
    return [];
  }

  @override
  Future<String?> onDeploy(
      BuildContext context, TextEditingController txtController) async {
    final DrawingController controller = DrawingController();
    dynamic val = await Get.toNamed(
        RouteConstants.chats + RouteConstants.drawingScreen,
        arguments: {'controller': controller});

    if (val != null && val) {
      ByteData? data = await controller.getImageData();
      if (data != null) {
        Uint8List dataList = data.buffer.asUint8List();
        Message message = Message(
          message: txtController.text,
          senderId: Auth.instance().user.value!.uid,
          timeStamp: DateTime.now(),
          messageType: 'text/draw',
        );
        return await FirestoreHandler.instance().sendDrawMessage(
            dataList, ChatController.instance().chatRoom.value!, message);
      }
    }
  }

  @override
  bool overrideMessageSend() {
    return true;
  }

  @override
  void pushNotif(String fullText, String? messageId) {
    String remainingString = getTrimmedString(fullText);
    ChatController.instance().pushDrawNotification(
        message: remainingString,
        timeStamp: DateTime.now(),
        messageId: messageId ?? '');
  }
}
