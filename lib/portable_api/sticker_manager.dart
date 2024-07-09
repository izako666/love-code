import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/ui/helper/ui_helper.dart';
import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';
import 'package:popover/popover.dart';

class StickerWidget extends StatelessWidget {
  const StickerWidget({super.key, required this.src, required this.width, required this.height});
  final String src;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(
        color: hintColor,
        width: 2.0,
      )),
      child: Image.network(src,
          width: width,
          height: height,
          errorBuilder: (a, b, c) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.width * 0.3,
              child: const CircularProgressIndicator())),
    );
  }
}

class StickerMessageWidget extends StatelessWidget {
  final Message msg;
  final bool isReply;
  final Function()? onReplyTap;
  final Function()? onDeleteTap;

  const StickerMessageWidget({super.key, required this.msg, this.isReply = false, this.onReplyTap, this.onDeleteTap});

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
        child: Row(children: [
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
              child: StickerWidget(
                src: msg.downloadUrl!,
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
              ),
            ),
          ),
          Text("${msg.timeStamp.hour}:${msg.timeStamp.minute}"),
        ]),
      ),
    );
  }
}

class StickerPickerSheet extends StatefulWidget {
  const StickerPickerSheet({super.key, this.onTapSticker, this.onTapNew});
  final Function(String)? onTapSticker;
  final Function()? onTapNew;
  @override
  State<StickerPickerSheet> createState() => _StickerPickerSheetState();
}

class _StickerPickerSheetState extends State<StickerPickerSheet> {
  List<String>? stickers;

  @override
  void initState() {
    super.initState();
    ChatController.instance().getStickers().then((val) {
      stickers = val;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      extendBodyBehindAppBar: true,
      appBar: const LcAppBar(
        title: Text('Pick a Sticker'),
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
      ),
      body: stickers == null
          ? const SizedBox(width: 100, height: 100, child: CircularProgressIndicator())
          : Obx(
              () => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: ChatController.instance().stickers.length + 1,
                itemBuilder: (context, index) {
                  if (index == ChatController.instance().stickers.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: widget.onTapNew,
                        child: SizedBox(
                          width: 120.w,
                          height: 120.w,
                          child: const Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.image), SizedBox(height: 10), Text('Add a new sticker')],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            if (widget.onTapSticker != null) {
                              widget.onTapSticker!(ChatController.instance().stickers[index]);
                            }
                          },
                          child: StickerWidget(width: 120.w, height: 120.w, src: ChatController.instance().stickers[index])),
                    );
                  }
                },
              ),
            ),
    );
  }
}
