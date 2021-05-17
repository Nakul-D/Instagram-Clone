import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:app/screens/profileScreen.dart';

class SearchScreen extends StatefulWidget {
  
  final DatabaseBloc databaseBloc;
  
  SearchScreen({@required this.databaseBloc});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  search() {
    // This function will search the typed user
    print("Search");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(12.0, 2.0, 12.0, 2.0),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search a user",
                          border: InputBorder.none,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(100.0)
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => search(),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(100.0)
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [],
              )
            )
          ],
        ),
      ),
    );
  }
}
