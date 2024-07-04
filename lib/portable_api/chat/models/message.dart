import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  Message.fromData(Map<String, dynamic> data, String id)
      : message = data['message_type'] == 'text/draw'
            ? (data['message'] as String).substring(6)
            : data['message'],
        messageType = data['message_type'] ?? 'text',
        downloadUrl = data['file_url'],
        waves = data['wave_list'] != null
            ? (data['wave_list'] as List<dynamic>)
                .map((d) => (d as double))
                .toList()
            : null,
        file = null,
        durationTime = data['duration_time'] != null
            ? Duration(milliseconds: data['duration_time'])
            : null,
        senderId = data['sender_id'],
        timeStamp = (data['timestamp'] as Timestamp).toDate(),
        replyToRef = data['reply_to_message'] != null
            ? Message(
                message: data['reply_to_message'],
                timeStamp: (data['reply_to_date'] as Timestamp).toDate(),
                senderId: '')
            : null,
        messageId = id;
}
