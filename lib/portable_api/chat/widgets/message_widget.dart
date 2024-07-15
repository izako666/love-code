import 'package:flutter/material.dart';
import 'package:love_code/constants.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/ui/helper/helper.dart';
import 'package:love_code/ui/helper/ui_helper.dart';
import 'package:love_code/ui/theme.dart';
import 'package:popover/popover.dart';

class MessageWidget extends StatelessWidget {
  final Message msg;
  final bool isReply;
  final Function()? onReplyTap;
  final Function()? onCopyTap;
  final Function()? onEditTap;
  final Function()? onDeleteTap;

  const MessageWidget(
      {super.key, required this.msg, this.isReply = false, this.onReplyTap, this.onCopyTap, this.onEditTap, this.onDeleteTap});

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
                  // height: msg.senderId == Auth.instance().user.value!.uid ? 240 : 64,
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
                              title: const Text(Localization.edit),
                              trailing: const Icon(Icons.edit),
                              onTap: () {
                                if (onEditTap != null) onEditTap!();

                                Navigator.pop(ctx);
                              },
                            )
                          ],
                          ListTile(
                            title: const Text(Localization.copy),
                            trailing: const Icon(Icons.copy),
                            onTap: () {
                              if (onCopyTap != null) onCopyTap!();

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
        width: isReply ? screenWidth : null,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: isReply ? screenWidth - 100 : screenWidth * Constants.msgWidthScale,
            child: Text(
              msg.messageType.contains('/') ? msg.message.split(' ')[1] : msg.message,
              softWrap: !isReply,
              overflow: isReply ? TextOverflow.ellipsis : null,
            ),
          ),
          Text(Helper.formatTime(msg.timeStamp)),
        ]),
      ),
    );
  }
}
