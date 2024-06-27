import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
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

  void _onTick(delta) {
    if (widget.controller.playing) {
      Duration finalDuration =
          widget.controller.playPosition + Duration(milliseconds: delta);
      if (finalDuration.compareTo(widget.controller.maxDuration) >= 0) {
        finalDuration = widget.controller.maxDuration;
      }
      widget.controller.setPlayingPosition(finalDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.transparent,
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            colors: [widget.playedColor, widget.normalColor],
            stops: [
              widget.controller.playPosition.inMilliseconds /
                  widget.controller.maxDuration.inMilliseconds,
              1
            ],
          ).createShader(rect);
        },
        child: Row(
          children: widget.dbList
              .map((d) => Container(
                    height: widget.height * d,
                    width: widget.width / widget.dbList.length,
                    color: Colors.white,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
