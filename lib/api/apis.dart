import 'dart:developer';
import 'dart:io';

import 'package:chat_app_hin/models/chat_user.dart';
import 'package:chat_app_hin/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for accessing firebase Messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then(
      (t) {
        if (t != null) {
          me.pushToken = t;
          log('Push Token: $t');
        }
      },
    );
  }

  // For getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        getFirebaseMessagingToken();
        log('My Data: ${user.data()}');
      } else {
        await createUser().then(
          (value) => getSelfInfo(),
        );
      }
    });
  }

  // for storing self information
  static late ChatUser me;

  // to return current user
  static get user => auth.currentUser!;

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for checking if user exists or not?
  static Future<void> getSelfInf() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then(
          (value) => getSelfInf(),
        );
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      image: user.photoURL.toString(),
      about: 'Hey, I\'m using We Chat!',
      name: user.displayName.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      id: user.uid,
      email: user.email.toString(),
      pushToken: '',
    );
    return await firestore.collection('users').doc(user.uid).set(
          chatUser.toJson(),
        );
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where(
          'id',
          isNotEqualTo: user.uid,
        )
        .snapshots();
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateprofilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    // storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    // updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatUser chatUser,
  ) {
    return firestore
        .collection('users')
        .where(
          'id',
          isEqualTo: chatUser.id,
        )
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecond.toString(),
      'push_token': me.pushToken,
    });
  }

  /**********Chat Screen Related Apis*************/

  // chats (collection) --> conversion_id(doc) --> messages(collection) --> message(doc)

  // useful for getting conversion id
  static String getCoversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversion from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getCoversationID(user.id)}/messages/')
        .orderBy(
          'sent',
          descending: true,
        )
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
    ChatUser chatUser,
    String msg,
    Type type,
  ) async {
    // messages sending time(also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
      msg: msg,
      read: '',
      told: chatUser.id,
      type: type,
      sent: time,
      fromId: user.uid,
    );
    final ref = firestore
        .collection('chats/${getCoversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(
          message.toJson(),
        );
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(
    Message message,
  ) async {
    firestore
        .collection('chats/${getCoversationID(
          message.fromId,
        )}/messages/')
        .doc(message.sent)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getCoversationID(user.id)}/messages/')
        .orderBy(
          'sent',
          descending: true,
        )
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = storage.ref().child(
        'images/${getCoversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    // updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(
      chatUser,
      imageUrl,
      Type.image,
    );
  }
}
