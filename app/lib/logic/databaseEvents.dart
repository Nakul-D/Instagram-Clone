import 'dart:io';

abstract class DatabaseEvents {}

class LoginEvent extends DatabaseEvents {
  String email;
  String password;
  LoginEvent({this.email, this.password});
}

class SignUpEvent extends DatabaseEvents {
  String username;
  String email;
  String password;
  SignUpEvent({this.username, this.email, this.password});
}

class UploadPostEvent extends DatabaseEvents {
  File imageFile;
  String caption;
  String location;
  UploadPostEvent({this.imageFile, this.caption, this.location});
}