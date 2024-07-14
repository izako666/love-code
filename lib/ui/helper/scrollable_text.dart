import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ScrollableText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ScrollableText({super.key, required this.text, required this.style});

  @override
  State<ScrollableText> createState() => _ScrollableTextState();
}

class _ScrollableTextState extends State<ScrollableText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late Ticker _ticker;
  double _position = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration duration) {
    _position += 1;
    if (_scrollController.hasClients) {
      // if (_scrollController.position.maxScrollExtent > 0 &&
      //     _position >= _scrollController.position.maxScrollExtent) {
      //   _position = 0.0;
      // }
      // if (_position == 0.0) {
      //   _scrollController.animateTo(_position,
      //       duration: duration, curve: Curves.easeIn);
      // } else {
      //   _scrollController.jumpTo(_position);
      // }
      _scrollController.jumpTo(_position);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 18,
      child: ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) => Text(
          widget.text,
          style: widget.style,
        ),
      ),
    );
  }
}
