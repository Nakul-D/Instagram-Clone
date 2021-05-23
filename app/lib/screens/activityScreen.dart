import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:app/screens/profileScreen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class ActivityScreen extends StatefulWidget {

  final DatabaseBloc databaseBloc;
  
  ActivityScreen({@required this.databaseBloc});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {

  GetActivityFeedEvent event;

  void initState() {
    super.initState();
    event = GetActivityFeedEvent(profileId: widget.databaseBloc.currentUser.id);
  }

  Widget activityFeedItem(Map data, double width, double height) {

    String subtitleText(String type, String commentData) {
      if (type == "follow") {
        return "Started following you";
      } else if (type == "like") {
        return "Liked your post";
      } else if (type == "comment") {
        return commentData;
      } else {
        return "invalid action";
      }
    }

    return Container(
      height: height/12,
      padding: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return ProfileScreen(
                  databaseBloc: widget.databaseBloc,
                  profileUserId: data["userId"]
                );
              }),
            );
          },
          child: CircleAvatar(
            radius: width/10,
            backgroundColor: Colors.lightBlueAccent,
            foregroundImage: data["profileImgUrl"] != "" ? CachedNetworkImageProvider(
              data["profileImgUrl"]
            ) : null,
          ),
        ),
        title: Row(
          children: [
            Text(
              data["username"],
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(width: 6.0),
            Text(
              "${timeago.format(data["timestamp"])}",
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        subtitle: Text(
          "${subtitleText(data["type"], data["commentData"])}",
          style: TextStyle(fontSize: 15.0),
        ),
        trailing: data["type"] != "follow" ? Image(
          width: height/15,
          height: height/15,
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(data["postImgUrl"])
        ) : Text(""),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activity"
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: widget.databaseBloc.mapEventToState(event),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List data = snapshot.data;
              return ListView(
                children: [
                  for (int i = 0; i < data.length; i++) activityFeedItem(data[i], width, height),
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
