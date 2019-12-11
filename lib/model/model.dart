import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;

  User({this.uid});
  factory User.fromMap(Map data) {
    return User(
      uid: data['uid'] ?? '',
    );
  }
}

class MusicFiles {
  final String img;
  final String audioUrl;

  MusicFiles({this.img, this.audioUrl});
  factory MusicFiles.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return MusicFiles(
      img: data['img'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
    );
  }
}
