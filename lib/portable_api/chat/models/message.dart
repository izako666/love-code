import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';

class Message {
  final String message;
  final String? messageId;
  final String senderId;
  final DateTime timeStamp;
  final Message? replyToRef;
  final String messageType;
  final File? file;
  final String? downloadUrl;
  final List<double>? waves;
  final Duration? durationTime;

  Message({
    required this.message,
    this.messageId,
    this.replyToRef,
    required this.senderId,
    required this.timeStamp,
    this.messageType = 'text',
    this.file,
    this.downloadUrl,
    this.waves,
    this.durationTime,
  });

  Future<DocumentReference?> sendMessage(String chatId) {
    return FirestoreHandler.instance().sendMessage(chatId, this);
  }

  static Message fromData(Map<String, dynamic> data, String id, bool getReply) {
    String message = data['message_type'] == 'text/draw' ? (data['message'] as String).substring(6) : data['message'];
    String messageType = data['message_type'] ?? 'text';
    String? downloadUrl = data['file_url'];
    List<double>? waves = data['wave_list'] != null ? (data['wave_list'] as List<dynamic>).map((d) => (d as double)).toList() : null;
    File? file;
    Duration? durationTime = data['duration_time'] != null ? Duration(milliseconds: data['duration_time']) : null;
    String senderId = data['sender_id'];
    DateTime timeStamp = (data['timestamp'] as Timestamp).toDate();
    // replyToRef = data['reply_to_message'] != null
    //     ? Message(
    //         message: data['reply_to_message'],
    //         timeStamp: (data['reply_to_date'] as Timestamp).toDate(),
    //         senderId: '')
    //     : null,
    String messageId = id;
    Message? replyToMessage = (data['reply_to_message'] != null && getReply)
        ? FirestoreHandler.instance().getMessage(ChatController.instance().chatRoom.value!, data['reply_to_message'])
        : null;
    Message msg = Message(
        message: message,
        messageId: id,
        messageType: messageType,
        downloadUrl: downloadUrl,
        waves: waves,
        file: file,
        durationTime: durationTime,
        senderId: senderId,
        timeStamp: timeStamp,
        replyToRef: replyToMessage);
    return msg;
  }
  // Message.fromData(Map<String, dynamic> data, String id)
  //     : message = data['message_type'] == 'text/draw'
  //           ? (data['message'] as String).substring(6)
  //           : data['message'],
  //       messageType = data['message_type'] ?? 'text',
  //       downloadUrl = data['file_url'],
  //       waves = data['wave_list'] != null
  //           ? (data['wave_list'] as List<dynamic>)
  //               .map((d) => (d as double))
  //               .toList()
  //           : null,
  //       file = null,
  //       durationTime = data['duration_time'] != null
  //           ? Duration(milliseconds: data['duration_time'])
  //           : null,
  //       senderId = data['sender_id'],
  //       timeStamp = (data['timestamp'] as Timestamp).toDate(),
  //       replyToRef = data['reply_to_message'] != null
  //           ? Message(
  //               message: data['reply_to_message'],
  //               timeStamp: (data['reply_to_date'] as Timestamp).toDate(),
  //               senderId: '')
  //           : null,
  //       messageId = id;
}
