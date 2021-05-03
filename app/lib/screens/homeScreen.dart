import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';

class HomeScreen extends StatelessWidget {
  
  final DatabaseBloc databaseBloc;
  
  HomeScreen({@required this.databaseBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Home screen"),
      ),
    );
  }
}
