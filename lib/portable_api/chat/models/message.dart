import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_code/portable_api/networking/firestore_handler.dart';

class Message {
  final String message;
  final String senderId;
  final DateTime timeStamp;

  Message(
      {required this.message, required this.senderId, required this.timeStamp});

  Future<DocumentReference?> sendMessage(String chatId) {
    return FirestoreHandler.instance().sendMessage(chatId, this);
  }

  Message.fromData(Map<String, dynamic> data)
      : message = data['message'],
        senderId = data['sender_id'],
        timeStamp = (data['timestamp'] as Timestamp).toDate();
}
