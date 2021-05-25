import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app/models/user.dart';
import 'package:app/models/post.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

class DatabaseBloc extends Bloc<DatabaseEvents, dynamic> {

  DatabaseBloc() : super(null);

  FirebaseFirestore firestore = initializeFirestore();
  FirebaseAuth firebaseAuth = initializeFirebaseAuth();
  Reference firebaseStorage = initializeFirebaseStorage();
  UserModel currentUser = UserModel();
  
  @override
  Stream<dynamic> mapEventToState(DatabaseEvents event) async* {

    final usersRef = firestore.collection('users');
    final postsRef = firestore.collection('posts');
    final followersRef = firestore.collection('followers');
    final followingRef = firestore.collection('following');
    final commentsRef = firestore.collection('comments');
    final activityRef = firestore.collection('activity');

    // Authenticating user
    if (event is LoginEvent) {
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        ).then((credential) => currentUser.id = credential.user.uid);
        // Fetching current user's document
        DocumentSnapshot document = await usersRef.doc(currentUser.id).get();
        // Updating currentUser
        currentUser.username = document['username'];
        currentUser.bio = document['bio'];
        currentUser.profileImgUrl = document['profileImgUrl'];
        currentUser.email = document['email'];
        // Log In successful
        yield "Logged In";
      } on FirebaseAuthException catch (e) {
        // Log in Unsuccessful
        yield e.message;
      }
    }

    // Creating a new account
    if (event is SignUpEvent) {
      try {
        // Creating a user with firebase auth
        await firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password
        ).then((credential) => currentUser.id = credential.user.uid);
        // Creating a user document in firestore
        if (currentUser.id != null) {
          await usersRef
            .doc(currentUser.id)
            .set({
              "id": currentUser.id,
              "username": event.username,
              "email": event.email,
              "timestamp": DateTime.now(),
              "bio": "",
              "profileImgUrl": "",
            });
          currentUser.username = event.username;
          currentUser.bio = "";
          currentUser.profileImgUrl = "";
          currentUser.email = event.email;
          yield "Created new user";
        }
      } on FirebaseAuthException catch (e) {
        yield e.message;
      }
    }

    // Uploading a post
    if (event is UploadPostEvent) {
      // Generating post Id
      String postId = Uuid().v4();
      TaskSnapshot taskSnapshot;
      // Compressing image
      File image = await compressImage(event.imageFile, postId);
      // Uploading image
      UploadTask uploadTask = firebaseStorage.child("post_$postId.jpg").putFile(image);
      await uploadTask.whenComplete(() => taskSnapshot = uploadTask.snapshot);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      // Creating post in firestore
      postsRef
        .doc(currentUser.id)
        .collection("posts")
        .doc(postId)
        .set({
          "postId": postId,
          "ownerId": currentUser.id,
          "username": currentUser.username,
          "profileImgUrl": currentUser.profileImgUrl,
          "mediaUrl": downloadUrl,
          "caption": event.caption,
          "location": event.location,
          "timestamp": DateTime.now(),
          "like": {},
        });
      yield "Post uploaded";
    }

    // Fetching profile data
    if (event is GetProfileEvent) {
      // Fetching user's info
      String username;
      String bio;
      String profileImgUrl;
      List followers = [];
      List following = [];
      List<PostModel> posts = [];
      if (event.profileUserId == currentUser.id){
        username = currentUser.username;
        bio = currentUser.bio;
        profileImgUrl = currentUser.profileImgUrl;
      } else {
        DocumentSnapshot userDocument = await usersRef
          .doc(event.profileUserId)
          .get();
        username = userDocument["username"];
        bio = userDocument["bio"];
        profileImgUrl = userDocument["profileImgUrl"];
      }
      // Fetching user's followers
      QuerySnapshot followersSnapshot = await followersRef
        .doc(event.profileUserId)
        .collection("followers")
        .get();
      followersSnapshot.docs.forEach((doc) {
        followers.add(doc.id);
      });
      // Fetching user's following
      QuerySnapshot followingSnapshot = await followingRef
        .doc(event.profileUserId)
        .collection("following")
        .get();
      followingSnapshot.docs.forEach((doc) {
        following.add(doc.id);
      });
      // Getting user's posts
      QuerySnapshot postSnapshot = await postsRef
        .doc(event.profileUserId)
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .get();
      postSnapshot.docs.forEach((doc) {
        Map postData = doc.data();
        Timestamp timestamp = postData["timestamp"];
        PostModel post = PostModel(
          postId: postData["postId"],
          ownerId: postData["ownerId"],
          username: postData["username"],
          profileImgUrl: postData["profileImgUrl"],
          mediaUrl: postData["mediaUrl"],
          caption: postData["caption"],
          location: postData["location"],
          timestamp: timestamp.toDate(),
          like: postData["like"],
        );
        posts.add(post);
      });
      yield {
        "profileUserId": event.profileUserId,
        "username": username,
        "bio": bio,
        "profileImgUrl": profileImgUrl,
        "followers": followers,
        "following": following,
        "posts": posts,
      };
    }

    // Updating profile
    if (event is UpdateProfileEvent) {
      String profileImgUrl = currentUser.profileImgUrl;
      String username = currentUser.username;
      String bio = currentUser.bio;
      // Uploading profile picture if it is changed
      if (event.profileChanged) {
        // Generating profile picture Id
        String profilePictureId = Uuid().v4();
        TaskSnapshot taskSnapshot;
        // Compressing image
        File image = await compressImage(event.profileImgFile, profilePictureId);
        // Uploading image
        UploadTask uploadTask = firebaseStorage.child("profile_$profilePictureId.jpg").putFile(image);
        await uploadTask.whenComplete(() => taskSnapshot = uploadTask.snapshot);
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        profileImgUrl = downloadUrl;
      }
      // Checking if username is changed
      if (event.username != currentUser.username) {
        username = event.username;
      }
      // Checking if bio is changed
      if (event.bio != currentUser.bio) {
        bio = event.bio;
      }
      // Updating user in firestore
      await usersRef
        .doc(currentUser.id)
        .update({
          "username": username,
          "bio": bio,
          "profileImgUrl": profileImgUrl,
        });
      // Updating current user
      currentUser.username = username;
      currentUser.bio = bio;
      currentUser.profileImgUrl = profileImgUrl;
      yield "Profile updated";
    }

    // Liking a post
    if (event is LikePostEvent) {
      postsRef
        .doc(event.ownerId)
        .collection("posts")
        .doc(event.postId)
        .update({
          'like.${currentUser.id}' : true,
        });
      yield "Post liked";
    }

    // Unliking a post
    if (event is UnlikePostEvent) {
      postsRef
        .doc(event.ownerId)
        .collection("posts")
        .doc(event.postId)
        .update({
          'like.${currentUser.id}' : false,
        });
      yield "Post Unliked";
    }

    // Fetching comments
    if (event is GetCommentsEvent) {
      List comments = [];
      QuerySnapshot snapshot = await commentsRef
        .doc(event.postId)
        .collection('comments')
        .orderBy("timestamp", descending: false)
        .get();
      // Adding comment data to comments list
      for (int i = 0; i < snapshot.docs.length; i++) {
        QueryDocumentSnapshot doc = snapshot.docs[i];
        DocumentSnapshot documentSnapshot = await usersRef.doc(doc["userId"]).get();
        Map userDocument = documentSnapshot.data();
        String username = userDocument["username"];
        String profileImgUrl = userDocument["profileImgUrl"];
        Timestamp timestamp = doc["timestamp"];
        comments.add({
          "userId": doc["userId"],
          "username": username,
          "profileImgUrl": profileImgUrl,
          "comment": doc["comment"],
          "timestamp": timestamp.toDate(),
        });
      }
      yield comments;
    }

    // Posting a comment
    if (event is AddCommentEvent) {
      commentsRef
        .doc(event.postId)
        .collection("comments")
        .add({
          "userId": currentUser.id,
          "comment": event.comment,
          "timestamp": DateTime.now(),
        });
      yield "Comment posted";
    }

    // Search users
    if (event is SearchEvent) {
      List users = [];
      QuerySnapshot snapshot = await usersRef
        .where("username", isGreaterThanOrEqualTo: event.searchText)
        .get();
      snapshot.docs.forEach((doc) {
        users.add({
          "profileId": doc["id"],
          "username": doc["username"],
          "profileImgUrl": doc["profileImgUrl"],
        });
      });
      yield users;
    }

    // Following a user
    if (event is FollowEvent) {
      // Adding profile to user's following
      followingRef
        .doc(currentUser.id)
        .collection("following")
        .doc(event.profileId)
        .set({});
      // Adding user to profile's followers
      followersRef
        .doc(event.profileId)
        .collection("followers")
        .doc(currentUser.id)
        .set({});
      yield "Followed";
    }

    // Unfollowing a user
    if (event is UnfollowEvent) {
      // Deleting profile from user's following
      followingRef
        .doc(currentUser.id)
        .collection("following")
        .doc(event.profileId)
        .get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });
      // Deleting user from profile's followers
      followersRef
        .doc(event.profileId)
        .collection("followers")
        .doc(currentUser.id)
        .get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });
      yield "Unfollowed";
    }

    // Fetching activity feed data
    if (event is GetActivityFeedEvent) {
      List activityFeedData = [];
      QuerySnapshot snapshot = await activityRef
        .doc(currentUser.id)
        .collection("feed")
        .orderBy("timestamp", descending: true)
        .get();
      
      for (int i = 0; i < snapshot.docs.length; i++) {

        QueryDocumentSnapshot doc = snapshot.docs[i];
        String type = doc["type"];
        String userId = doc["userId"];
        Timestamp rawTimestamp = doc["timestamp"];
        DateTime timestamp = rawTimestamp.toDate();
        DocumentSnapshot userDoc = await usersRef
          .doc(userId)
          .get();
        String username = userDoc["username"];
        String profileImgUrl = userDoc["profileImgUrl"];
        String postId = type != "follow" ? doc["postId"] : "";
        String postImgUrl = "";
        if (type != "follow") {
          DocumentSnapshot postDoc = await postsRef
            .doc(currentUser.id)
            .collection("posts")
            .doc(postId)
            .get();
          postImgUrl = postDoc["mediaUrl"];
        }
        String commentData = type == "comment" ? doc["commentData"] : "";
        // Adding data to list activityFeedData
        activityFeedData.add({
          "type": type,
          "userId": userId,
          "timestamp": timestamp,
          "username": username,
          "profileImgUrl": profileImgUrl,
          "postId": postId,
          "postImgUrl": postImgUrl,
          "commentData": commentData,
        });
      }
      yield activityFeedData;
    }

    // Fetching posts for Timeline
    if (event is GetTimelineEvent) {
      
    }

  }
}

FirebaseAuth initializeFirebaseAuth() {
  // This function will initialize firebaseAuth and will connect the running device
  // to the local firebase emulator
  final String host = Platform.isAndroid ? "http://10.0.2.2:9099" : "http://localhost:9099";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  firebaseAuth.useEmulator(host);
  return firebaseAuth;
}

FirebaseFirestore initializeFirestore() {
  // This function will initialize firebaseFirestore and will connect the running device
  // to the local firebase emulator
  final String host = Platform.isAndroid ? "10.0.2.2:8080" : "localhost:8080";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = Settings(host: host, sslEnabled: false, persistenceEnabled: false);
  return firestore;
}

Reference initializeFirebaseStorage() {
  // This function will initialize firebaseStorage  and will connect the running device
  // to the local firebase emulator
  final String host = Platform.isAndroid ? "10.0.2.2" : "localhost";
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  firebaseStorage.useEmulator(host: host, port: 9199);
  return firebaseStorage.ref();
}

Future<File> compressImage(File rawImage, String id) async {
  // This function will compress the given image
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  Im.Image decodedImageFile = Im.decodeImage(rawImage.readAsBytesSync());
  final compressedImageFile = File('$path/img_$id.jpg')..writeAsBytesSync(
    Im.encodeJpg(decodedImageFile, quality: 80),
  );
  return compressedImageFile;
}
