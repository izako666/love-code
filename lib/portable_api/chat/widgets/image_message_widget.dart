import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/ui/helper/helper.dart';
import 'package:love_code/ui/helper/ui_helper.dart';
import 'package:love_code/ui/theme.dart';
import 'package:popover/popover.dart';

class ImageMessageWidget extends StatelessWidget {
  final Message msg;
  final bool isReply;
  final Function()? onReplyTap;
  final Function()? onDeleteTap;

  const ImageMessageWidget({super.key, required this.msg, this.isReply = false, this.onReplyTap, this.onDeleteTap});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onLongPress: isReply
          ? null
          : () {
              showPopover(
                  context: context,
                  width: 150,
                  height: msg.senderId == Auth.instance().user.value!.uid ? 240 : 128,
                  arrowHeight: 0,
                  arrowWidth: 0,
                  radius: 16,
                  backgroundColor: primaryColor.darken(0.4),
                  bodyBuilder: (ctx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(Localization.reply),
                            trailing: const Icon(Icons.reply),
                            onTap: () {
                              if (onReplyTap != null) onReplyTap!();
                              Navigator.pop(ctx);
                            },
                          ),
                          if (msg.senderId == Auth.instance().user.value!.uid) ...[
                            ListTile(
                              title: const Text(Localization.delete),
                              trailing: const Icon(Icons.delete),
                              onTap: () {
                                Navigator.pop(ctx);
                                if (onDeleteTap != null) onDeleteTap!();
                              },
                            )
                          ],
                        ],
                      ),
                    );
                  });
            },
      child: Container(
        width: isReply ? screenWidth : screenWidth * 0.4,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          SizedBox(
            width: isReply ? screenWidth - 100 : screenWidth * 0.3,
            child: GestureDetector(
              onTap: () async {
                Get.dialog(Dialog(
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.7,
                        height: screenWidth * 0.7,
                        child: Image.network(
                          msg.downloadUrl!,
                          width: screenWidth * 0.5,
                          height: screenWidth * 0.5,
                          errorBuilder: (a, b, c) =>
                              SizedBox(width: screenWidth * 0.3, height: screenWidth * 0.3, child: const CircularProgressIndicator()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                          width: screenWidth * 0.7,
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, backgroundColor, backgroundColor, backgroundColor, primaryColor],
                              stops: [0.1, 0.2, 0.5, 0.8, 0.9],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(child: Text(msg.message)))
                    ],
                  ),
                ));
              },
              child: Image.network(
                msg.downloadUrl!,
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                errorBuilder: (a, b, c) =>
                    SizedBox(width: screenWidth * 0.3, height: screenWidth * 0.3, child: const CircularProgressIndicator()),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(Helper.formatTime(msg.timeStamp)),
        ]),
      ),
    );
  }
}
