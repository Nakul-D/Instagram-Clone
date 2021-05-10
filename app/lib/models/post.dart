class PostModel {
  String postId;
  String ownerId;
  String username;
  String mediaUrl;
  String caption;
  String location;
  DateTime timestamp;
  Map like;

  PostModel({
    this.postId,
    this.ownerId,
    this.username,
    this.mediaUrl,
    this.caption,
    this.location,
    this.timestamp,
    this.like,
  });
  
}