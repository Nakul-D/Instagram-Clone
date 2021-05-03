import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class DatabaseBloc extends Bloc<DatabaseEvents, dynamic> {

  DatabaseBloc() : super(null);

  FirebaseFirestore firestore = initializeFirestore();
  FirebaseAuth firebaseAuth = initializeFirebaseAuth();
  
  @override
  Stream<dynamic> mapEventToState(DatabaseEvents event) async* {

    final usersRef = firestore.collection('users');

    // Authenticating user
    if (event is LoginEvent) {
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        yield "Logged In";
      } on FirebaseAuthException catch (e) {
        yield e.message;
      }
    }

    // Creating a new account
    if (event is SignUpEvent) {
      String userId;
      try {
        // Creating a user with firebase auth
        await firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password
        ).then((credential) => userId = credential.user.uid);
        // Creating a user document in firestore
        if (userId != null) {
          await usersRef
            .doc()
            .set({
              "id": userId,
              "username": event.username,
              "email": event.email,
              "password": event.password,
              "timestamp": DateTime.now(),
              "bio": "",
              "profileImgUrl": "",
            });
          yield "Created new user";
        }
      } on FirebaseAuthException catch (e) {
        yield e.message;
      }
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
