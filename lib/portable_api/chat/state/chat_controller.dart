import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/http/http_handler.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';
import 'package:love_code/ui/helper/helper.dart';
import 'package:love_code/ui/theme.dart';

class ChatController extends GetxController {
  @override
  void onInit() {
    findChatRoom();
    pushToken();
    Auth.instance().exposeUserData();
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
    RemoteMessage? msg = await FirebaseMessaging.instance.getInitialMessage();
    _handleNotifOpened(msg);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotifOpened);
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      FirestoreHandler.instance().pushToken(fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FirestoreHandler.instance().pushToken(fcmToken);
    }).onError((err) {});
  }

  void _handleNotifOpened(RemoteMessage? msg) {
    if (msg != null && msg.data['messagetype'] == 'text/draw') {
      String? msgId = msg.data['message_id'];
      if (msgId != null) {
        Message? msg = messages
            .where((msg) => msg.messageId == msgId && msg.messageId != null)
            .firstOrNull;
        if (msg != null) {
          double screenWidth = MediaQueryData.fromView(
                  WidgetsBinding.instance.renderViews.first.flutterView)
              .size
              .width;

          Get.dialog(Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: screenWidth * 0.7,
                  height: screenWidth * 0.7,
                  child: Image.network(
                    msg.downloadUrl!,
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                    errorBuilder: (a, b, c) => SizedBox(
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        child: const CircularProgressIndicator()),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    width: screenWidth * 0.7,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          backgroundColor,
                          backgroundColor,
                          backgroundColor,
                          primaryColor
                        ],
                        stops: [0.1, 0.2, 0.5, 0.8, 0.9],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(child: Text(msg.message)))
              ],
            ),
          ));
        }
      }
    }
  }

  Future<void> pushNotification(
      {required String message,
      required String messageId,
      required DateTime timeStamp}) async {
    String recipId =
        await FirestoreHandler.instance().getRecipientId(chatRoom.value!);
    HttpHandler.post('/send_notification', {
      'title': 'New Message',
      'message': '$message   ${Helper.formatTime(timeStamp)}',
      'user_id': recipId,
      'message_id': messageId
    });
  }

  Future<void> pushVoiceNotification(
      {required String message,
      required String messageId,
      required DateTime timeStamp}) async {
    String recipId =
        await FirestoreHandler.instance().getRecipientId(chatRoom.value!);
    HttpHandler.post('/send_notification', {
      'title': 'New Message',
      'message':
          '${Auth.instance().user.value!.displayName} sent you a voice message.   ${Helper.formatTime(timeStamp)}',
      'user_id': recipId,
      'message_id': messageId
    });
  }

  Future<void> pushAlertNotification(
      {required String message,
      required String messageId,
      required DateTime timeStamp}) async {
    String recipId =
        await FirestoreHandler.instance().getRecipientId(chatRoom.value!);
    HttpHandler.post('/send_notification_alert', {
      'title': 'Alert!',
      'message': '$message   ${Helper.formatTime(timeStamp)}',
      'user_id': recipId,
      'message_id': messageId
    });
  }

  Future<void> pushDrawNotification(
      {required String message,
      required String messageId,
      required DateTime timeStamp}) async {
    String recipId =
        await FirestoreHandler.instance().getRecipientId(chatRoom.value!);
    HttpHandler.post('/send_notification_draw', {
      'title': 'Check this out!',
      'message':
          '${Auth.instance().user.value!.displayName!} sent you a drawing!  ${Helper.formatTime(timeStamp)}',
      'user_id': recipId,
      'message_id': messageId
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

enum MESSAGETYPES { text, audio, draw }

extension IdExtension on MESSAGETYPES {
  String get id {
    switch (this) {
      case MESSAGETYPES.text:
        return 'text';
      case MESSAGETYPES.audio:
        return 'audio';
      case MESSAGETYPES.draw:
        return 'text/draw';
      default:
        return 'text';
    }
  }
}
