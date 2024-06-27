import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/http/http_handler.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';
import 'package:love_code/ui/helper/helper.dart';

class ChatController extends GetxController {
  @override
  void onInit() {
    findChatRoom();
    pushToken();
    super.onInit();
  }

  static ChatController instance() => Get.find<ChatController>();
  RxList<Message> messages = RxList<Message>();
  Rx<String?> chatRoom = Rx<String?>(null);
  RxBool findingChatRoom = true.obs;
  void findChatRoom() async {
    User user = Auth.instance().user.value!;
    chatRoom.value = await FirestoreHandler.instance().findChatRoom(user.uid);
    findingChatRoom.value = false;
    if (chatRoom.value != null) {
      FirestoreHandler.instance().exposeMessagesStream(chatRoom.value!);
      Get.toNamed(RouteConstants.chats);
    }
  }

  Future<bool> confirmRoomCode(String code) async {
    String confirmation =
        await FirestoreHandler.instance().confirmRoomCode(code);
    if (confirmation.contains('success')) {
      String userId = confirmation.split('.').last;
      chatRoom.value = await FirestoreHandler.instance().createChat(userId);
      FirestoreHandler.instance().exposeMessagesStream(chatRoom.value!);
      Get.toNamed(RouteConstants.chats);
      return true;
    } else if (confirmation == 'expired') {
      Get.snackbar(Localization.oops, Localization.expiredCode);
      return false;
    } else if (confirmation == 'failed') {
      Get.snackbar(Localization.oops, Localization.smthnBad);
      return false;
    }
    return false;
  }

  Future<String> createRoomCode() async {
    List<String> existingCodes =
        await FirestoreHandler.instance().getExistingCodes();
    String roomCode = generateUniquePassword(6, existingCodes);
    await FirestoreHandler.instance().addRoomCode(roomCode);
    return roomCode;
  }

  String generateUniquePassword(int length, List<String> existingCodes) {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random.secure();
    String password = '';
    bool isUnique = false;

    while (!isUnique) {
      password = '';
      Map<String, int> charCount = {};

      while (password.length < length) {
        String char = chars[random.nextInt(chars.length)];
        if (charCount[char] == null) {
          charCount[char] = 1;
          password += char;
        } else if (charCount[char]! < 2) {
          charCount[char] = charCount[char]! + 1;
          password += char;
        }
      }

      if (!existingCodes.contains(password)) {
        isUnique = true;
      }
    }

    return password;
  }

  void hookInChatroomCheck() {
    FirestoreHandler.instance().getCodesStream().listen((snap) {
      List<QueryDocumentSnapshot> docs = snap.docs;
      for (int i = 0; i < docs.length; i++) {
        Map<String, dynamic>? data = docs[i].data() as Map<String, dynamic>?;
        if (data != null) {
          if (data['user_id'] == Auth.instance().user.value!.uid ||
              data['other_user_id'] == Auth.instance().user.value!.uid) {
            if (chatRoom.value == null) {
              chatRoom.value = docs[i].id;
              FirestoreHandler.instance().exposeMessagesStream(chatRoom.value!);
              Get.toNamed(RouteConstants.chats);
            }
          }
        }
      }
    });
  }

  void deleteChat() async {
    await FirestoreHandler.instance().deleteChat(chatRoom.value!);
    chatRoom.value = null;
    Get.toNamed(RouteConstants.makeRoom);
  }

  void pushToken() async {
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      FirestoreHandler.instance().pushToken(fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FirestoreHandler.instance().pushToken(fcmToken);
    }).onError((err) {});
  }

  Future<void> pushNotification(
      {required String message, required DateTime timeStamp}) async {
    String recipId =
        await FirestoreHandler.instance().getRecipientId(chatRoom.value!);
    HttpHandler.post('/send_notification', {
      'title': 'New Message',
      'message': '$message   ${Helper.formatTime(timeStamp)}',
      'user_id': recipId
    });
  }

  Future<void> sendAudioFile(
    String fileName,
    File file,
    Message message,
  ) async {
    FirestoreHandler.instance().sendAudioMessage(
        fileName, file, chatRoom.value!, message, message.waves!);
  }
}

enum MESSAGETYPES { text, audio }
