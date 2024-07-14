import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/constants.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/audio/state_management/player_waveform_controller.dart';
import 'package:love_code/portable_api/audio/ui/player_waveform.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/ui/helper/helper.dart';
import 'package:love_code/ui/helper/ui_helper.dart';
import 'package:love_code/ui/theme.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class AudioMessageWidget extends StatefulWidget {
  final Message msg;
  final bool isReply;
  final Function()? onReplyTap;
  final Function()? onDeleteTap;

  const AudioMessageWidget({super.key, required this.msg, this.isReply = false, this.onReplyTap, this.onDeleteTap});

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  late PlayerWaveformController controller;
  bool playing = false;
  @override
  void initState() {
    super.initState();
    controller = PlayerWaveformController(url: widget.msg.downloadUrl!);
    controller.setMaxDuration(widget.msg.durationTime!);
    controller.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(update);
    controller.dispose();
  }

  void update() {
    try {
      if (controller.playing && !playing) {
        playing = true;
        setState(() {});
        Get.log('state updated, playing');
      } else if (!controller.playing && playing) {
        playing = false;
        Get.log('state updated, not playing');

        setState(() {});
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider.value(
      value: controller,
      child: GestureDetector(
        onLongPress: widget.isReply
            ? null
            : () {
                showPopover(
                    context: context,
                    width: 150,
                    // height: widget.msg.senderId == Auth.instance().user.value!.uid ? 240 : 128,
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
                                if (widget.onReplyTap != null) {
                                  widget.onReplyTap!();
                                }
                                Navigator.pop(ctx);
                              },
                            ),
                            if (widget.msg.senderId == Auth.instance().user.value!.uid) ...[
                              ListTile(
                                title: const Text(Localization.delete),
                                trailing: const Icon(Icons.delete),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  if (widget.onDeleteTap != null) {
                                    widget.onDeleteTap!();
                                  }
                                },
                              )
                            ],
                          ],
                        ),
                      );
                    });
              },
        child: Container(
          width: widget.isReply ? screenWidth : screenWidth * (Constants.msgWidthScale + 0.1),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(children: [
            SizedBox(
                width: widget.isReply ? screenWidth - 100 : screenWidth * Constants.msgWidthScale,
                child: Row(
                  children: [
                    PlayerWaveform(
                        dbList: widget.msg.waves!,
                        isReply: widget.isReply,
                        controller: controller,
                        width: screenWidth * (widget.isReply ? 0.8 : 0.3),
                        height: 80,
                        normalColor: Colors.white,
                        playedColor: accentColor,
                        maxDuration: widget.msg.durationTime!),
                    if (!widget.isReply) ...[
                      IconButton(
                          onPressed: () {
                            controller.setPlaying(!controller.playing);
                            setState(() {});
                          },
                          icon: Consumer<PlayerWaveformController>(
                            builder: (ctx, ctrler, _) => Icon(playing ? Icons.pause : Icons.play_arrow),
                          ))
                    ],
                  ],
                )),
            Text(Helper.formatTime(widget.msg.timeStamp)),
          ]),
        ),
      ),
    );
  }
}
