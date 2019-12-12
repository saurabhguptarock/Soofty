import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String photoUrl;
  final String name;

  User({
    this.uid,
    this.email,
    this.photoUrl,
    this.name,
  });
  factory User.fromMap(Map data) {
    return User(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}

class MusicFiles {
  final String img;
  final String audioUrl;
  final String name;
  final String uid;

  MusicFiles({this.img, this.audioUrl, this.name, this.uid});
  factory MusicFiles.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return MusicFiles(
      img: data['img'] ?? '',
      name: data['name'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      uid: data['uid'] ?? '',
    );
  }
}
