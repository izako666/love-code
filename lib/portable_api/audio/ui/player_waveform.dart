import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      required this.maxDuration,
      required this.isReply});
  final List<double> dbList;
  final PlayerWaveformController controller;
  final Duration maxDuration;
  final double width;
  final double height;
  final Color normalColor;
  final Color playedColor;
  final bool isReply;

  @override
  State<PlayerWaveform> createState() => _PlayerWaveformState();
}

class _PlayerWaveformState extends State<PlayerWaveform> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<double> finalDbList = List.empty(growable: true);
  Duration oldDuration = const Duration();
  @override
  void initState() {
    widget.controller.setMaxDuration(widget.maxDuration);
    widget.controller.addListener(update);
    _ticker = createTicker(_onTick)..start();
    finalDbList = averageChunks(widget.dbList, (widget.dbList.length / (widget.isReply ? 66 : 22)).round());
    super.initState();
  }

  List<double> averageChunks(List<double> inputList, int chunkSize) {
    List<double> result = [];

    for (int i = 0; i < inputList.length; i += chunkSize) {
      int end = (i + chunkSize < inputList.length) ? i + chunkSize : inputList.length;
      List<double> chunk = inputList.sublist(i, end);
      double sum = chunk.reduce((a, b) => a + b);
      double average = sum / chunk.length;
      result.add(average);
    }

    return result;
  }

  List<double> scaleToMinimumZero(List<double> inputList) {
    if (inputList.isEmpty) return [];

    // Find the minimum value in the list
    double minValue = inputList.reduce((a, b) => a < b ? a : b);

    // Scale all values so that the minimum value becomes 0
    List<double> scaledList = inputList.map((value) => value - minValue).toList();

    return scaledList;
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
      Duration finalDuration = widget.controller.playPosition + (delta - oldDuration);

      if (finalDuration.compareTo(AudioController.instance.playbackDuration.value) >= 0) {
        finalDuration = AudioController.instance.playbackDuration.value;
      }
      widget.controller.setPlayingPosition(finalDuration);

      Get.log('${AudioController.instance.playbackPosition.value.inMilliseconds}');
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
        int millisecondsNew = (maxDuration.inMilliseconds.toDouble() * scale).toInt();
        Duration finalDuration = Duration(milliseconds: millisecondsNew);
        if (widget.controller.playing ||
            (AudioController.instance.player.isPaused && AudioController.instance.currentUrl.value == widget.controller.url)) {
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
                    widget.controller.playPosition.inMilliseconds.toDouble() / widget.controller.maxDuration.inMilliseconds.toDouble();
                if (AudioController.instance.currentUrl.value != widget.controller.url) {
                  finalStop = 0;
                }
                Get.log('final stoppu $finalStop');
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
                children: finalDbList
                    .map((d) => Container(
                          height: 100.0 * pow(d, 10),
                          width: widget.width / finalDbList.length,
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
