import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? id;
  String? name;
  String? phone;
  String? email;

  UserModel({this.id, this.name, this.phone, this.email});

  UserModel.fromSnapshot(DataSnapshot snap) {
    id = snap.key;
    name = (snap.value as dynamic)['name'];
    phone = (snap.value as dynamic)['phone'];
    email = (snap.value as dynamic)['email'];
  }
}
