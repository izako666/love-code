import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:love_code/constants.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';

class FirestoreHandler extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  static FirestoreHandler instance() => Get.find<FirestoreHandler>();
  @override
  void onInit() {
    super.onInit();
    db.settings = const Settings(persistenceEnabled: true);
  }

  Future<bool> signUpUser(String userId, String email, String user) async {
    try {
      await db
          .collection(Constants.fireStoreUsers)
          .doc(userId)
          .set({'email': email, 'username': user});
      return true;
    } catch (e) {
      printError(info: e.toString());
      return false;
    }
  }

  Future<DocumentReference?> sendMessage(chatId, Message message) async {
    return await db
        .collection(Constants.fireStoreRooms)
        .doc(chatId)
        .collection(Constants.msgBox)
        .add({
      'message': message.message,
      'timestamp': Timestamp.fromDate(message.timeStamp),
      'sender_id': message.senderId,
      if (message.replyToRef != null) ...{
        'reply_to_message': message.replyToRef!.message,
        'reply_to_date': Timestamp.fromDate(message.replyToRef!.timeStamp)
      }
    });
  }

  Future<List<Message>> getMessages(String chatId) async {
    QuerySnapshot<Map<String, dynamic>> snap = await db
        .collection(Constants.fireStoreRooms)
        .doc(chatId)
        .collection(Constants.msgBox)
        .get();

    return docsToMessages(snap);
  }

  List<Message> docsToMessages(QuerySnapshot<Map<String, dynamic>> snap) {
    List<Message> messages = List.empty(growable: true);
    for (int i = 0; i < snap.docs.length; i++) {
      var data = snap.docs[i].data();
      messages.add(Message.fromData(data, snap.docs[i].id));
    }
    return messages;
  }

  void exposeMessagesStream(String chatId) {
    db
        .collection(Constants.fireStoreRooms)
        .doc(chatId)
        .collection(Constants.msgBox)
        .orderBy('timestamp')
        .snapshots()
        .listen((d) {
      ChatController.instance().messages.clear();
      ChatController.instance().messages.value = docsToMessages(d);
      Get.log('messages updated');
    }, onError: (a, b) {
      Get.log('message stream errored $b');
    }, onDone: () {
      Get.log('message stream finished');
    });
  }

  Future<void> deleteMessage(chatId, Message message) async {
    await db
        .collection(Constants.fireStoreRooms)
        .doc(chatId)
        .collection(Constants.msgBox)
        .doc(message.messageId)
        .delete();
  }

  Future<void> editMessage(chatId, Message message, String newMessage) async {
    await db
        .collection(Constants.fireStoreRooms)
        .doc(chatId)
        .collection(Constants.msgBox)
        .doc(message.messageId)
        .update({'message': newMessage});
  }

  DocumentReference getDocRef(String chatId, String msgId) {
    return db
        .collection(Constants.fireStoreRooms)
        .doc(chatId)
        .collection(Constants.msgBox)
        .doc(msgId);
  }

  Future<String?> findChatRoom(String userId) async {
    Query<Map<String, dynamic>> query = db
        .collection(Constants.fireStoreRooms)
        .where(Filter.or(Filter('user_id', isEqualTo: userId),
            Filter('other_user_id', isEqualTo: userId)));
    QuerySnapshot<Map<String, dynamic>> snapshot = await query.limit(1).get();
    return snapshot.docs.isEmpty ? null : snapshot.docs.first.id;
  }

  Future<List<String>> getExistingCodes() async {
    List<QueryDocumentSnapshot> snapshots =
        (await db.collection(Constants.fireStoreCodes).get()).docs;
    List<String> codes = List.empty(growable: true);
    for (int i = 0; i < snapshots.length; i++) {
      Map<String, dynamic>? data = snapshots[i].data() as Map<String, dynamic>?;
      if (data != null) {
        codes.add(data['code']);
      }
    }
    return codes;
  }

  Future<void> addRoomCode(String roomCode) async {
    db.collection(Constants.fireStoreCodes).add({
      'code': roomCode,
      'owner_id': Auth.instance().user.value!.uid,
      'timestamp': Timestamp.fromDate(DateTime.now())
    });
  }

  Future<String> confirmRoomCode(String code) async {
    List<QueryDocumentSnapshot> snapshots =
        (await db.collection(Constants.fireStoreCodes).get()).docs;
    for (int i = 0; i < snapshots.length; i++) {
      Map<String, dynamic>? data = snapshots[i].data() as Map<String, dynamic>?;
      if (data == null) continue;
      if (data['code'] == code) {
        if ((data['timestamp'] as Timestamp)
                .toDate()
                .difference(DateTime.now())
                .inMinutes >=
            60) {
          return 'expired';
        } else {
          if (data['owner_id'] == Auth.instance().user.value!.uid) {
            return 'failed';
          } else {
            return 'success.${data['owner_id']}';
          }
        }
      }
    }
    return 'failed';
  }

  Future<String> createChat(String userId) async {
    DocumentReference doc = await db.collection(Constants.fireStoreRooms).add(
        {'user_id': userId, 'other_user_id': Auth.instance().user.value!.uid});
    doc.collection(Constants.msgBox);
    return doc.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCodesStream() {
    return db.collection(Constants.fireStoreRooms).snapshots();
  }

  Future<void> deleteChat(String chatRoom) async {
    await db.collection(Constants.fireStoreRooms).doc(chatRoom).delete();
  }
}
