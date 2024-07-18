import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class HomeLoadingScreen extends StatefulWidget {
  const HomeLoadingScreen({super.key});

  @override
  State<HomeLoadingScreen> createState() => _HomeLoadingScreenState();
}

class _HomeLoadingScreenState extends State<HomeLoadingScreen> {
  late final ChatController _chatController;
  @override
  void initState() {
    super.initState();
    Get.delete<ChatController>().whenComplete(() {
      _chatController = Get.put<ChatController>(ChatController());
      _chatController.findingChatRoom.listen((d) {
        if (!d) {
          if (_chatController.chatRoom.value != null) {
            Get.toNamed(RouteConstants.chats);
          } else {
            Get.toNamed(RouteConstants.makeRoom);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LcScaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
