import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String user_id;
  String user_pw;
  String createTime;

  User(this.user_id, this.user_pw, this.createTime);

  User.fromSnapshot(DocumentSnapshot snapshot)
      : user_id = snapshot['user_id'],
        user_pw = snapshot['user_pw'],
        createTime = snapshot['createTime'];

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'user_pw': user_pw,
      'createTime': createTime,
    };
  }
}

class FirestoreService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> addUser(User user) {
    return usersCollection
        .doc(user.user_id)  // 사용자의 ID를 문서 ID로 설정합니다.
        .set(user.toJson())
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<User?> getUser(String documentId) async {
    DocumentSnapshot snapshot = await usersCollection.doc(documentId).get();
    if (snapshot.exists) {
      return User.fromSnapshot(snapshot);
    } else {
      print("No user found with the given document ID.");
      return null;
    }
  }
}
