import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/local_data/local_data.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<Widget> images = List.empty(growable: true);
  List<Widget> text = List.empty(growable: true);
  late int selectedPage;
  late final PageController _pageController;
  @override
  void initState() {
    super.initState();
    images = [
      Container(color: Colors.red, width: 0.8.sw, height: 0.4.sh),
      Container(color: Colors.red, width: 0.8.sw, height: 0.4.sh),
      Container(color: Colors.red, width: 0.8.sw, height: 0.4.sh),
    ];
    text = const [
      Text(Localization.onboarding_1),
      Text(Localization.onboarding_2),
      Text(Localization.onboarding_3)
    ];
    selectedPage = 0;
    _pageController = PageController(initialPage: selectedPage);
  }

  @override
  Widget build(BuildContext context) {
    return LcScaffold(
        extendBodyBehindAppBar: true,
        appBar: const LcAppBar(
          automaticallyImplyLeading: false,
        ),
        body: PageView.builder(
            itemCount: 3,
            controller: _pageController,
            onPageChanged: (index) {
              selectedPage = index;
              setState(() {});
            },
            itemBuilder: (ctx, index) {
              return Column(
                children: [
                  const SizedBox(height: kToolbarHeight * 2),
                  images[index],
                  const SizedBox(
                    height: 32,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64),
                      child: text[index]),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PageViewDotIndicator(
                      currentItem: selectedPage,
                      count: 3,
                      unselectedColor: Colors.white,
                      selectedColor: Colors.grey,
                      duration: const Duration(milliseconds: 200),
                      boxShape: BoxShape.circle,
                      onItemClicked: (index) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                  if (index == 2) ...[
                    const SizedBox(height: 16),
                    LcButton(
                      text: 'Go',
                      onPressed: () {
                        LocalDataHandler.addData('on_boarding', true);
                        Get.toNamed(RouteConstants.authInit);
                      },
                    )
                  ]
                ],
              );
            }));
  }
}
