import 'package:get/get.dart';
import 'package:love_code/portable_api/local_data/local_data.dart';

class OnboardingController extends GetxController {
  RxInt currentPage = 0.obs;
  RxBool seenOnboarding = false.obs;
  @override
  void onInit() {
    seenOnboarding.value =
        LocalDataHandler.readData<bool>('on_boarding', false);

    super.onInit();
  }
}
