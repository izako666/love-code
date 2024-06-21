import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';

class Message {
  final String message;
  final String? messageId;
  final String senderId;
  final DateTime timeStamp;
  final Message? replyToRef;

  Message(
      {required this.message,
      this.messageId,
      this.replyToRef,
      required this.senderId,
      required this.timeStamp});

  Future<DocumentReference?> sendMessage(String chatId) {
    return FirestoreHandler.instance().sendMessage(chatId, this);
  }

  Message.fromData(Map<String, dynamic> data, String id)
      : message = data['message'],
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
