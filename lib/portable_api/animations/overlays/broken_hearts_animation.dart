import 'dart:math';

import 'package:flutter/material.dart';
import 'package:love_code/resources.dart';
import 'package:love_code/ui/helper/ui_helper.dart';

class BrokenHeartsAnimation extends StatefulWidget {
  const BrokenHeartsAnimation({super.key, this.onFinish, required this.width, required this.height});
  final Function()? onFinish;
  final double width;
  final double height;
  @override
  State<BrokenHeartsAnimation> createState() => _BrokenHeartsAnimationState();
}

class _BrokenHeartsAnimationState extends State<BrokenHeartsAnimation> with TickerProviderStateMixin {
  List<AnimatedIconWidget> icons = [];

  // late Ticker _ticker;
  List<Widget> bigHearts = List.empty(growable: true);
  late AnimationController risingHeartsController;
  late AnimationController bigHeartController;
  AssetImage? img;

  @override
  void initState() {
    super.initState();
    // _ticker = createTicker(_tick)..start();

    risingHeartsController = AnimationController(vsync: this, duration: const Duration(seconds: 9));
    bigHeartController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    // toBeFalling.addAll(generateFallingIcons(100));
    risingHeartsController.forward().whenComplete(() {
      if (widget.onFinish != null) {
        widget.onFinish!();
      }
    });
    bigHeartController.forward().whenComplete(() {
      bigHearts.clear();
      // iconsFalling.addAll(toBeFalling);
      // fallingHeartsController.forward();
      setState(() {});
    });
    icons.addAll(generateIcons(400));
    Animation<double> width = Tween<double>(begin: 200, end: 250)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.5, 0.9, curve: SmoothSawToothCurve())));
    Animation<double> moveAway = Tween<double>(begin: 0, end: 100)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.7, 0.85, curve: Curves.easeInExpo)));
    Animation<double> rotate = Tween<double>(begin: 0, end: pi / 2)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.7, 0.85, curve: Curves.easeInExpo)));
    Animation<double> fall = Tween<double>(begin: widget.height / 2, end: 0)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.7, 1.0, curve: Curves.easeInExpo)));

    Animation<double> position = Tween<double>(begin: 0.0, end: widget.height / 2)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.0, 0.5, curve: Curves.linear)));

    bigHearts.add(BrokenBigHeartWidget(
        screenWidth: widget.width,
        controller: bigHeartController,
        width: width,
        moveAway: moveAway,
        rotate: rotate,
        fall: fall,
        height: width,
        position: position,
        left: true));

    bigHearts.add(BrokenBigHeartWidget(
        screenWidth: widget.width,
        controller: bigHeartController,
        width: width,
        moveAway: moveAway,
        rotate: rotate,
        fall: fall,
        height: width,
        position: position,
        left: false));
  }

  @override
  void didChangeDependencies() {
    // Adjust the provider based on the image type
    precacheImage(img = const AssetImage(Resources.brokenHeartLogo), context);
    precacheImage(const AssetImage(Resources.leftBrokenHeartLogo), context);
    precacheImage(const AssetImage(Resources.rightBrokenHeartLogo), context);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    risingHeartsController.dispose();
    bigHeartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [...icons, ...bigHearts]);
  }

  Iterable<AnimatedIconWidget> generateIcons(int amount) {
    List<AnimatedIconWidget> iconList = List<AnimatedIconWidget>.empty(growable: true);
    for (int i = 0; i < amount; i++) {
      if (risingHeartsController.lastElapsedDuration == null) {
        continue;
      }
      double startX = Random.secure().nextDouble() * widget.width;
      AnimatedIconWidget icon = AnimatedIconWidget(
          startX: startX,
          iconSize: 16,
          animationController: risingHeartsController,
          initialDuration: risingHeartsController.lastElapsedDuration! + Duration(milliseconds: i * 10 + Random.secure().nextInt(20)),
          queueRemoval: (widget) {
            icons.remove(widget);
          },
          maxDuration: const Duration(seconds: 1),
          icon: Image.asset(
            Resources.brokenHeartLogo,
            scale: 1,
            color: Colors.grey.darken(0.5),
            cacheWidth: 30,
            cacheHeight: 30,
            filterQuality: FilterQuality.none,
          ));
      iconList.add(icon);
    }
    return iconList;
  }
}

class BrokenBigHeartWidget extends StatelessWidget {
  const BrokenBigHeartWidget(
      {super.key,
      required this.screenWidth,
      required this.controller,
      required this.width,
      required this.height,
      required this.position,
      required this.moveAway,
      required this.rotate,
      required this.fall,
      required this.left});
  final double screenWidth;
  final AnimationController controller;
  final Animation<double> width;
  final Animation<double> height;
  final Animation<double> moveAway;
  final Animation<double> fall;
  final Animation<double> rotate;
  final bool left;
  final Animation<double> position;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (ctx, child) {
          return Positioned(
            left: screenWidth / 2 - (width.value / 2) + (left ? -moveAway.value : moveAway.value),
            bottom: (controller.value >= 0.7 ? fall.value : position.value) - width.value / 2,
            child: Transform.rotate(
              angle: left ? -rotate.value : rotate.value,
              child: SizedBox(
                width: width.value,
                height: height.value,
                child: Image.asset(
                  left ? Resources.leftBrokenHeartLogo : Resources.rightBrokenHeartLogo,
                  color: Colors.grey.darken(0.4),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          );
        });
  }
}

class AnimatedIconWidget extends StatelessWidget {
  final AnimationController animationController;
  final Duration initialDuration;
  final Duration maxDuration;
  final double startX;
  final double iconSize;
  final Function(AnimatedIconWidget) queueRemoval;
  final Widget icon;
  const AnimatedIconWidget({
    super.key,
    required this.startX,
    required this.iconSize,
    required this.animationController,
    required this.initialDuration,
    required this.queueRemoval,
    required this.maxDuration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        if (animationController.lastElapsedDuration == null) {
          return Container();
        }
        final int elapsedMillis = (animationController.lastElapsedDuration! - initialDuration).inMilliseconds;
        if (elapsedMillis >= maxDuration.inMilliseconds + 200) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            queueRemoval(this);
          });
          return Container();
        }
        final double elapsedVal = elapsedMillis / maxDuration.inMilliseconds;
        final double topPosition = MediaQuery.of(context).size.height * (1.0 - elapsedVal);
        return Positioned(
          left: startX,
          top: topPosition,
          child: icon,
        );
      },
    );
  }
}

class AnimatedFallingIconWidget extends StatelessWidget {
  final AnimationController animationController;
  final double startX;
  final double startY;
  final Widget icon;
  final double velocity;
  const AnimatedFallingIconWidget({
    super.key,
    required this.startX,
    required this.startY,
    required this.animationController,
    required this.icon,
    required this.velocity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Positioned(
          left: startX,
          bottom: startY - (animationController.value * 1000 * velocity),
          child: icon,
        );
      },
    );
  }
}

class SmoothSawToothCurve extends Curve {
  const SmoothSawToothCurve();
  @override
  double transformInternal(double t) {
    return sin(t * 2 * pi * 4 / pi).abs();
  }
}
