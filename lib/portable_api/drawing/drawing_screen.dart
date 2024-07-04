import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/drawing/drawing_board.dart';
import 'package:love_code/resources.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late final DrawingController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.arguments['controller'];
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
      extendBodyBehindAppBar: true,
      appBar: LcAppBar(
          scrolledUnderElevation: 0.0,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Resources.heartLogo,
                width: 40,
                height: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(Localization.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      wordSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(
                width: 50,
              ),
            ],
          )),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight),
            IzDrawingBoard(
                width: MediaQuery.of(context).size.width - 60,
                height: MediaQuery.of(context).size.width - 60,
                background: Colors.white,
                controller: controller),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LcButton(
                  width: 128,
                  height: 32,
                  text: Localization.send,
                  onPressed: () {
                    Get.back(result: true);
                  },
                ),
                const SizedBox(width: 32),
                LcButton(
                  width: 128,
                  height: 32,
                  text: Localization.cancel,
                  onPressed: () {
                    Get.back(result: false);
                  },
                )
              ],
            ),
            const SizedBox(height: 32)
          ],
        ),
      ),
    );
  }
}
