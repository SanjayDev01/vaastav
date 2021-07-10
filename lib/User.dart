import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String photoUrl;
  final String displayName;
  // final String contact;
  final String gps;

  User({
    this.id,
    //  this.contact,
    this.email,
    this.photoUrl,
    this.displayName,
    this.gps,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      //  contact: doc['contact'],
      gps: doc['gps'],
    );
  }
}

class Post1 {
  final String postId1;

  Post1({this.postId1});

  factory Post1.fromDocument(DocumentSnapshot doc) {
    return Post1(postId1: doc['postId1']);
  }
}
