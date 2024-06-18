import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:love_code/constants.dart';
import 'package:love_code/portable_api/chat/models/message.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
// import 'package:love_code/api/data/message.dart';

class FirestoreHandler extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  static FirestoreHandler instance() => Get.find<FirestoreHandler>();
  @override
  void onInit() {
    super.onInit();
    db.settings = const Settings(persistenceEnabled: true);
  }
  // Future<void> addMessage(Message msg) async {

  //   db.collection(Constants.fireStoreRooms).doc(Auth().userChatId).set(data);
  // }

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
      'sender_id': message.senderId
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
      messages.add(Message.fromData(data));
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
}
