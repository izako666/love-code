import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';

class SwipeReply extends StatefulWidget {
  const SwipeReply({super.key, required this.left, required this.child, required this.onReply});
  final bool left;
  final Widget child;
  final Function onReply;
  @override
  State<SwipeReply> createState() => _SwipeReplyState();
}

class _SwipeReplyState extends State<SwipeReply> with SingleTickerProviderStateMixin {
  double pos = 0.0;
  late Ticker _ticker;
  late StreamController<double> anim;

  @override
  void initState() {
    super.initState();
    anim = StreamController();
    anim.add(pos);
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration duration) {
    anim.add(pos);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: (d) {
          pos += d.delta.dx;
          if (pos >= 100) {
            pos = 100;
          } else if (pos <= -100) {
            pos = -100;
          }
          if ((pos < 0 && widget.left) || (pos > 0 && !widget.left)) {
            pos = 0.0;
          }
          anim.add(pos);
          //setState(() {});
        },
        onHorizontalDragEnd: (d) {
          if ((pos > 50 && widget.left) || (pos < 50 && !widget.left)) {
            widget.onReply();
          }
          pos = 0.0;
          anim.add(0.0);
        },
        child: StreamBuilder(
            initialData: 0.0,
            stream: anim.stream,
            builder: (ctx, snap) {
              return Transform.translate(offset: Offset(pos, 0), child: widget.child);
            }));
  }
}
