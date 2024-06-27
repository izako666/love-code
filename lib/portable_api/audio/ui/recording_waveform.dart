import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RecordingWaveform extends StatefulWidget {
  const RecordingWaveform(
      {super.key,
      required this.stream,
      required this.width,
      required this.height,
      required this.color,
      required this.thickness});
  final Stream<double> stream;
  final double width;
  final double height;
  final Color color;
  final double thickness;

  @override
  State<RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<RecordingWaveform> {
  List<double> dbList = List.empty(growable: true);
  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: widget.width,
      height: widget.height,
      child: StreamBuilder<double>(
          stream: widget.stream,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              dbList.add(snapshot.data!);
              _controller.jumpTo(_controller.position.maxScrollExtent);
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: dbList
                    .map((d) => Container(
                          height: widget.height * d,
                          width: widget.thickness,
                          color: Colors.white,
                        ))
                    .toList(),
              ),
            );
          }),
    );
  }
}
