import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app/models/user.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

class DatabaseBloc extends Bloc<DatabaseEvents, dynamic> {

  DatabaseBloc() : super(null);

  FirebaseFirestore firestore = initializeFirestore();
  FirebaseAuth firebaseAuth = initializeFirebaseAuth();
  Reference firebaseStorage = FirebaseStorage.instance.ref();
  UserModel currentUser = UserModel();
  
  @override
  Stream<dynamic> mapEventToState(DatabaseEvents event) async* {

    final usersRef = firestore.collection('users');
    final postsRef = firestore.collection('posts');

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
              "password": event.password,
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
          "mediaUrl": downloadUrl,
          "caption": event.caption,
          "location": event.location,
          "timestamp": DateTime.now(),
          "like": {},
        });
      yield "Post uploaded";
    }
    
  }
}

FirebaseFirestore initializeFirestore() {
  // This function will initialize firestore and will connect the running device
  // to the local firebase emulator
  final String host = Platform.isAndroid ? "10.0.2.2:8080" : "localhost:8080";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = Settings(host: host, sslEnabled: false, persistenceEnabled: false);
  return firestore;
}

FirebaseAuth initializeFirebaseAuth() {
  // This function will initialize firebaseAuth and will connect the running device
  // to the local firebase emulator
  final String host = Platform.isAndroid ? "http://10.0.2.2:9099" : "http://localhost:9099";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  firebaseAuth.useEmulator(host);
  return firebaseAuth;
}

Future<File> compressImage(File rawImage, String postId) async {
  // This function will compress the given image
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  Im.Image decodedImageFile = Im.decodeImage(rawImage.readAsBytesSync());
  final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(
    Im.encodeJpg(decodedImageFile, quality: 80),
  );
  return compressedImageFile;
}
