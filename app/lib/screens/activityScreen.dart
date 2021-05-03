import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';

class ActivityScreen extends StatelessWidget {

  final DatabaseBloc databaseBloc;
  
  ActivityScreen({@required this.databaseBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Activity screen"),
      ),
    );
  }
}
