import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/constants.dart';
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
  final bool large;

  const ImageMessageWidget({super.key, required this.msg, this.isReply = false, this.onReplyTap, this.onDeleteTap, this.large = false});

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
                  //height: msg.senderId == Auth.instance().user.value!.uid ? 240 : 128,
                  arrowHeight: 0,
                  arrowWidth: 0,
                  radius: 16,
                  backgroundColor: primaryColor.darken(0.4),
                  bodyBuilder: (ctx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
        width: isReply
            ? screenWidth
            : large
                ? null
                : null,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
          SizedBox(
            width: isReply
                ? screenWidth - 100
                : large
                    ? screenWidth * 0.6
                    : screenWidth * (Constants.msgWidthScale),
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
                        child: CachedNetworkImage(
                          imageUrl: msg.downloadUrl!,
                          width: large ? screenWidth * 0.55 : screenWidth * 0.5,
                          height: large ? null : screenWidth * 0.55,
                          errorWidget: (a, b, c) => SizedBox(
                              width: large ? screenWidth * 0.55 : screenWidth * Constants.msgWidthScale,
                              height: large ? screenWidth * 0.55 : screenWidth * Constants.msgWidthScale,
                              child: const CircularProgressIndicator()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                          width: screenWidth * 0.6,
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
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CachedNetworkImage(
                    imageUrl: msg.downloadUrl!,
                    width: large ? screenWidth * 0.55 : screenWidth * Constants.msgWidthScale,
                    height: large ? null : screenWidth * Constants.msgWidthScale,
                    errorWidget: (a, b, c) => SizedBox(
                        width: large ? screenWidth * 0.55 : screenWidth * Constants.msgWidthScale,
                        height: large ? screenWidth * 0.55 : screenWidth * Constants.msgWidthScale,
                        child: const Center(child: CircularProgressIndicator())),
                  ),
                  if (msg.message.isNotEmpty) const Positioned(right: -24, top: -5, child: Icon(Icons.chat_outlined))
                ],
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
