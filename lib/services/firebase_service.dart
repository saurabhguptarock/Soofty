import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soofty/model/model.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
]);
final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore _firestore = Firestore.instance;

Future<void> login() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  AuthResult result = await _auth.signInWithCredential(credential);
  createUserDatabase(result.user);
}

Future<void> createUserDatabase(FirebaseUser user) async {
  var doc = await _firestore.document('users/${user.uid}').get();
  if (!doc.exists) {
    var userRef = _firestore.document('users/${user.uid}');
    var data = {
      'uid': user.uid,
      'photoUrl': user.photoUrl,
      'name': user.displayName,
      'email': user.email,
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
        .orderBy('uid')
        .startAfterDocument(lastDocument)
        .limit(10)
        .getDocuments();
  } else {
    return _firestore
        .collection('musicTiles')
        .orderBy('uid')
        .limit(10)
        .getDocuments();
  }
}

void signOut() {
  _auth.signOut();
}
