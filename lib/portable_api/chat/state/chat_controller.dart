import 'package:get/get.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';

class ChatController extends GetxController {
  @override
  void onInit() {
    FirestoreHandler.instance().exposeMessagesStream('U9YSnKNBEFpATnRM2Y9R');
    super.onInit();
  }

  static ChatController instance() => Get.find<ChatController>();
  RxList<Message> messages = RxList<Message>();
}
