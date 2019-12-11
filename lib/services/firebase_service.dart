import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soofty/model/model.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore _firestore = Firestore.instance;

initializeUser() async {
  AuthResult result = await _auth.signInAnonymously();
  createUserDatabase(result.user);
}

Future<void> createUserDatabase(FirebaseUser user) async {
  var doc = await _firestore.document('users/${user.uid}').get();
  if (!doc.exists) {
    var userRef = _firestore.document('users/${user.uid}');
    var data = {
      'uid': user.uid,
    };
    userRef.setData(data, merge: true);
  }
}

Stream<User> streamUser(String uid) {
  return _firestore
      .collection('users')
      .document(uid)
      .snapshots()
      .map((snap) => User.fromMap(snap.data));
}

Future<QuerySnapshot> streamMusicTile(
    DocumentSnapshot lastDocument, bool isNext) {
  if (isNext) {
    return _firestore
        .collection('musicTiles')
        .orderBy('url')
        .startAfterDocument(lastDocument)
        .limit(10)
        .getDocuments();
  } else {
    return _firestore
        .collection('musicTiles')
        .orderBy('url')
        .limit(10)
        .getDocuments();
  }
}
