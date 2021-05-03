import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';

class AddScreen extends StatelessWidget {
  
  final DatabaseBloc databaseBloc;
  
  AddScreen({@required this.databaseBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Add screen"),
      ),
    );
  }
}
