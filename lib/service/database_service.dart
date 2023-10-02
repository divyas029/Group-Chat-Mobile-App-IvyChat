import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference enclaveCollection =
      FirebaseFirestore.instance.collection("enclaves");

  // saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "enclaves": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // get user enclaves
  getUserEnclaves() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating an enclave
  Future createEnclave(String userName, String id, String enclaveName) async {
    DocumentReference enclaveDocumentReference = await enclaveCollection.add({
      "enclaveName": enclaveName,
      "enclaveIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "enclaveId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    await enclaveDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "enclaveId": enclaveDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "enclaves":
          FieldValue.arrayUnion(["${enclaveDocumentReference.id}_$enclaveName"])
    });
  }

  // getting the chats
  getChats(String enclaveId) async {
    return enclaveCollection
        .doc(enclaveId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getEnclaveAdmin(String enclaveId) async {
    DocumentReference d = enclaveCollection.doc(enclaveId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get enclave members
  getEnclaveMembers(enclaveId) async {
    return enclaveCollection.doc(enclaveId).snapshots();
  }

  // search
  searchByName(String enclaveName) {
    return enclaveCollection.where("enclaveName", isEqualTo: enclaveName).get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String enclaveName, String enclaveId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> enclaves = await documentSnapshot['enclaves'];
    if (enclaves.contains("${enclaveId}_$enclaveName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the enclave join/exit
  Future toggleEnclaveJoin(
      String enclaveId, String userName, String enclaveName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference enclaveDocumentReference =
        enclaveCollection.doc(enclaveId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> enclaves = await documentSnapshot['enclaves'];

    // if user has our enclaves -> then remove then or also in other part re join
    if (enclaves.contains("${enclaveId}_$enclaveName")) {
      await userDocumentReference.update({
        "enclaves": FieldValue.arrayRemove(["${enclaveId}_$enclaveName"])
      });
      await enclaveDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "enclaves": FieldValue.arrayUnion(["${enclaveId}_$enclaveName"])
      });
      await enclaveDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String enclaveId, Map<String, dynamic> chatMessageData) async {
    enclaveCollection
        .doc(enclaveId)
        .collection("messages")
        .add(chatMessageData);
    enclaveCollection.doc(enclaveId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
