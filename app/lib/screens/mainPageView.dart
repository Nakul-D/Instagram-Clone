import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';

class MainPageView extends StatelessWidget {

  final DatabaseBloc databaseBloc;
  
  MainPageView({@required this.databaseBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("MainPageView"),
      ),
    );
  }
}