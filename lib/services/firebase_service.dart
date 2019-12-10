import 'package:firebase_auth/firebase_auth.dart';

demo() {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  firebaseAuth.signInAnonymously().then((user) {});
}
