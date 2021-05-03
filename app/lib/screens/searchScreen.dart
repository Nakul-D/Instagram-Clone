import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';

class SearchScreen extends StatelessWidget {
  
  final DatabaseBloc databaseBloc;
  
  SearchScreen({@required this.databaseBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Search screen"),
      ),
    );
  }
}
