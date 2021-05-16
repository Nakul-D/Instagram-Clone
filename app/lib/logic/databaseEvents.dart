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

class GetProfileEvent extends DatabaseEvents {
  String profileUserId;
  GetProfileEvent({this.profileUserId});
}

class UpdateProfileEvent extends DatabaseEvents {
  String username;
  String bio;
  bool profileChanged;
  File profileImgFile;
  UpdateProfileEvent({this.username, this.bio, this.profileChanged, this.profileImgFile});
}

class LikePostEvent extends DatabaseEvents {
  String ownerId;
  String postId;
  LikePostEvent({this.ownerId, this.postId});
}

class UnlikePostEvent extends DatabaseEvents {
  String ownerId;
  String postId; 
  UnlikePostEvent({this.ownerId, this.postId});
}

class GetCommentsEvent extends DatabaseEvents {
  String postId;
  GetCommentsEvent({this.postId});
}

class AddCommentEvent extends DatabaseEvents {
  String postId;
  String comment;
  AddCommentEvent({this.postId ,this.comment});
}
