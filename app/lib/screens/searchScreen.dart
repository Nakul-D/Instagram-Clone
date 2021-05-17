import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:app/screens/profileScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  
  final DatabaseBloc databaseBloc;
  
  SearchScreen({@required this.databaseBloc});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  List searchResult = [];
  TextEditingController searchController = TextEditingController();

  search() async {
    // This function will search the typed user
    SearchEvent event = SearchEvent(searchText: searchController.text);
    List result = await widget.databaseBloc.mapEventToState(event).first;
    setState(() {
      searchResult = result;
    });
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
                          hintText: "Search a user...",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                          ),
                          focusColor: Colors.white,
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold
                        ),
                        cursorColor: Colors.white,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(100.0)
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () => search(),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(100.0)
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < searchResult.length; i++) Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return ProfileScreen(
                              databaseBloc: widget.databaseBloc,
                              profileUserId: searchResult[i]["profileId"]
                            );
                          }),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.width/15,
                              backgroundColor: Colors.lightBlueAccent,
                              backgroundImage: CachedNetworkImageProvider(searchResult[i]["profileImgUrl"]),
                            ),
                            SizedBox(width: 12.0),
                            Text(
                              "${searchResult[i]["username"]}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(100.0)
                        ),
                      ),
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
