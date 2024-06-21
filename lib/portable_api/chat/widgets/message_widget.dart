import 'package:flutter/material.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
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
      {super.key,
      required this.msg,
      this.isReply = false,
      this.onReplyTap,
      this.onCopyTap,
      this.onEditTap,
      this.onDeleteTap});

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
                  height: msg.senderId == Auth.instance().user.value!.uid
                      ? 240
                      : 128,
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
                            title: Text(Localization.reply),
                            trailing: Icon(Icons.reply),
                            onTap: () {
                              if (onReplyTap != null) onReplyTap!();
                              Navigator.pop(ctx);
                            },
                          ),
                          if (msg.senderId ==
                              Auth.instance().user.value!.uid) ...[
                            ListTile(
                              title: Text(Localization.edit),
                              trailing: Icon(Icons.edit),
                              onTap: () {
                                if (onEditTap != null) onEditTap!();

                                Navigator.pop(ctx);
                              },
                            )
                          ],
                          ListTile(
                            title: Text(Localization.copy),
                            trailing: Icon(Icons.copy),
                            onTap: () {
                              if (onCopyTap != null) onCopyTap!();

                              Navigator.pop(ctx);
                            },
                          ),
                          if (msg.senderId ==
                              Auth.instance().user.value!.uid) ...[
                            ListTile(
                              title: Text(Localization.delete),
                              trailing: Icon(Icons.delete),
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
        child: Row(children: [
          Container(
            width: isReply ? screenWidth - 100 : screenWidth * 0.3,
            child: Text(
              msg.message,
              softWrap: !isReply,
              overflow: isReply ? TextOverflow.ellipsis : null,
            ),
          ),
          Text("${msg.timeStamp.hour}:${msg.timeStamp.minute}"),
        ]),
      ),
    );
  }
}
