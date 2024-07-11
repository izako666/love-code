import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/api/command.dart';
import 'package:love_code/portable_api/animations/overlays/broken_hearts_animation.dart';
import 'package:love_code/portable_api/animations/overlays/overlay_animation_manager.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';

class BrokenHeartsCommand extends Command {
  BrokenHeartsCommand(
      {required super.id,
      required super.name,
      super.desc = 'Send a special animation of sadness :( ',
      super.commandType = 'animation/broken_hearts'});

  @override
  List getArguments() {
    return [];
  }

  @override
  Future<String?> onDeploy(BuildContext context, TextEditingController txtController) async {
    deployEffect(context);
    ChatController.instance().pushHeartsEffect();
    return '';
  }

  @override
  Future<void> deployEffect(BuildContext context) async {
    late OverlayEntry entry;
    Get.log('command deployed');
    OverlayAnimationManager.startAnimation(
        context,
        entry = OverlayEntry(builder: (ctx) {
          return BrokenHeartsAnimation(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            onFinish: () {
              OverlayAnimationManager.endAnimation(entry);
            },
          );
        }));
  }

  @override
  void pushNotif(String fullText, String? messageId) {}

  @override
  bool overrideMessageSend() {
    return true;
  }
}
