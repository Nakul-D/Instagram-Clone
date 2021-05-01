import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/loginScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {

          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  "Something went wrong"
                ),
              ),
            );
          }

          // Once initialized, display login screen
          if (snapshot.connectionState == ConnectionState.done) {
            return LoginScreen();
          }

          // Otherwise, show loading
          return Scaffold(
            body: Center(
              child: Text(
                "Loading",
              ),
            ),
          );

        },
      ),
    );
  }
}
