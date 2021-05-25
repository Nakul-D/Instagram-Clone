import 'package:flutter/material.dart';
import 'package:app/models/post.dart';
import 'package:app/widgets/postTile.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';

class HomeScreen extends StatelessWidget {
  
  final DatabaseBloc databaseBloc;
  
  HomeScreen({@required this.databaseBloc});

  @override
  Widget build(BuildContext context) {

    final event = GetTimelineEvent();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Timeline"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: databaseBloc.mapEventToState(event),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<PostModel> posts = snapshot.data;
              return ListView(
                children: [
                  for (int i = 0; i < posts.length; i++) Container(
                    padding: EdgeInsets.only(top: 16.0),
                    child: PostTile(
                      databaseBloc: databaseBloc,
                      width: width,
                      postModel: posts[i],
                    ),
                  )
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
