import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/resources.dart';

class HeartsAnimation extends StatefulWidget {
  const HeartsAnimation({super.key, this.onFinish, required this.width, required this.height});
  final Function()? onFinish;
  final double width;
  final double height;
  @override
  State<HeartsAnimation> createState() => _HeartsAnimationState();
}

class _HeartsAnimationState extends State<HeartsAnimation> with TickerProviderStateMixin {
  List<AnimatedIconWidget> icons = [];

  // late Ticker _ticker;
  late Widget bigHeart;
  late AnimationController risingHeartsController;
  late AnimationController bigHeartController;
  AssetImage? img;

  @override
  void initState() {
    super.initState();
    // _ticker = createTicker(_tick)..start();

    risingHeartsController = AnimationController(vsync: this, duration: const Duration(seconds: 9));
    bigHeartController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    // toBeFalling.addAll(generateFallingIcons(100));
    risingHeartsController.forward().whenComplete(() {
      if (widget.onFinish != null) {
        widget.onFinish!();
      }
    });
    bigHeartController.forward().whenComplete(() {
      bigHeart = Container();
      // iconsFalling.addAll(toBeFalling);
      // fallingHeartsController.forward();
      setState(() {});
    });
    icons.addAll(generateIcons(400));
    Animation<double> width = Tween<double>(begin: 200, end: 250)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.5, 0.7, curve: SmoothSawToothCurve())));
    Animation<double> disappear = Tween<double>(begin: 250, end: 5)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.7, 1.0, curve: Curves.linear)));
    Animation<double> position = Tween<double>(begin: 0.0, end: widget.height / 2)
        .animate(CurvedAnimation(parent: bigHeartController, curve: const Interval(0.0, 0.5, curve: Curves.linear)));

    bigHeart = BigHeartWidget(
        screenWidth: widget.width, controller: bigHeartController, width: width, disappear: disappear, height: width, position: position);
    // _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
    //   if (mounted) {
    //     if (controller.lastElapsedDuration != null && controller.lastElapsedDuration! >= const Duration(seconds: 13, milliseconds: 500)) {
    //       _timer.cancel();
    //     }
    //     icons.addAll(generateIcons(20));
    //     setState(() {});
    //   }
    // });
  }

  @override
  void didChangeDependencies() {
    // Adjust the provider based on the image type
    precacheImage(img = const AssetImage(Resources.heartLogo), context);
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
    return Stack(children: [...icons, bigHeart]);
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
            Resources.heartLogo,
            scale: 2.0,
            cacheWidth: 30,
            cacheHeight: 30,
            filterQuality: FilterQuality.none,
          ));
      iconList.add(icon);
    }
    return iconList;
  }
}

class BigHeartWidget extends StatelessWidget {
  const BigHeartWidget(
      {super.key,
      required this.screenWidth,
      required this.controller,
      required this.width,
      required this.height,
      required this.position,
      required this.disappear});
  final double screenWidth;
  final AnimationController controller;
  final Animation<double> width;
  final Animation<double> height;
  final Animation<double> disappear;
  final Animation<double> position;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (ctx, child) {
          Get.log((disappear.value).toString());
          return Positioned(
            left: screenWidth / 2 - (controller.value >= 0.7 ? disappear.value / 2 : width.value / 2),
            bottom: position.value - (controller.value >= 0.7 ? disappear.value / 2 : width.value / 2),
            child: SizedBox(
              width: controller.value >= 0.7 ? disappear.value : width.value,
              height: controller.value >= 0.7 ? disappear.value : height.value,
              child: Image.asset(
                Resources.heartLogo,
                fit: BoxFit.cover,
                cacheWidth: 100,
                cacheHeight: 100,
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
