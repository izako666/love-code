import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:love_code/portable_api/audio/audio_controller.dart';
import 'package:love_code/portable_api/audio/state_management/player_waveform_controller.dart';

class PlayerWaveform extends StatefulWidget {
  const PlayerWaveform(
      {super.key,
      required this.dbList,
      required this.controller,
      required this.width,
      required this.height,
      required this.normalColor,
      required this.playedColor,
      required this.maxDuration});
  final List<double> dbList;
  final PlayerWaveformController controller;
  final Duration maxDuration;
  final double width;
  final double height;
  final Color normalColor;
  final Color playedColor;

  @override
  State<PlayerWaveform> createState() => _PlayerWaveformState();
}

class _PlayerWaveformState extends State<PlayerWaveform>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration oldDuration = Duration();
  @override
  void initState() {
    widget.controller.setMaxDuration(widget.maxDuration);
    widget.controller.addListener(update);
    _ticker = createTicker(_onTick)..start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    widget.controller.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  void _onTick(Duration delta) {
    if (widget.controller.playing) {
      Duration finalDuration =
          widget.controller.playPosition + (delta - oldDuration);

      if (finalDuration
              .compareTo(AudioController.instance.playbackDuration.value) >=
          0) {
        finalDuration = AudioController.instance.playbackDuration.value;
      }
      widget.controller.setPlayingPosition(finalDuration);

      Get.log(
          '${AudioController.instance.playbackPosition.value.inMilliseconds}');
      if (AudioController.instance.finishedPlaying.value) {
        widget.controller.setFinishedPlaying();
      }
    }
    oldDuration = delta;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        double dX = details.localPosition.dx;
        Duration maxDuration = widget.controller.maxDuration;
        double maxX = widget.width;
        double scale = dX / maxX;
        int millisecondsNew =
            (maxDuration.inMilliseconds.toDouble() * scale).toInt();
        Duration finalDuration = Duration(milliseconds: millisecondsNew);
        if (widget.controller.playing ||
            (AudioController.instance.player.isPaused &&
                AudioController.instance.currentUrl.value ==
                    widget.controller.url)) {
          widget.controller.setPlayingPositionAudio(finalDuration);
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.transparent,
        child: Obx(
          () {
            AudioController.instance.currentUrl.value;
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) {
                double finalStop =
                    widget.controller.playPosition.inMilliseconds.toDouble() /
                        widget.controller.maxDuration.inMilliseconds.toDouble();
                if (AudioController.instance.currentUrl.value !=
                    widget.controller.url) {
                  finalStop = 0;
                }
                Get.log('final stoppu ${finalStop}');
                return LinearGradient(
                  colors: [
                    widget.playedColor,
                    widget.playedColor,
                    widget.playedColor,
                    widget.playedColor,
                    widget.playedColor,
                    widget.playedColor,
                    widget.normalColor
                  ],
                  stops: [
                    0,
                    finalStop,
                    finalStop,
                    finalStop,
                    finalStop,
                    finalStop,
                    finalStop,
                  ],
                ).createShader(rect);
              },
              child: Row(
                children: widget.dbList
                    .map((d) => Container(
                          height: widget.height * pow(d, 10),
                          width: widget.width / widget.dbList.length,
                          color: Colors.white,
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
