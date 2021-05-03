import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';

class ProfileScreen extends StatelessWidget {
  
  final DatabaseBloc databaseBloc;
  
  ProfileScreen({@required this.databaseBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Profile screen"),
      ),
    );
  }
}
