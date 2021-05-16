import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class CommentScreen extends StatefulWidget {

  final String postId;
  final DatabaseBloc databaseBloc;

  CommentScreen({this.postId, this.databaseBloc});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {

  bool posting = false;
  TextEditingController commentController = TextEditingController();

  Stream getComments() {
    // This function will fetch comments of a post
    GetCommentsEvent event = GetCommentsEvent(postId: widget.postId);
    return widget.databaseBloc.mapEventToState(event);
  }

  addComment() async {
    // This function will post comments on a post
    setState(() {
      posting = true;
    });
    AddCommentEvent event = AddCommentEvent(
      postId: widget.postId,
      comment: commentController.text
    );
    await widget.databaseBloc.mapEventToState(event).first;
    setState(() {
      posting = false;
    });
    commentController.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Comments"
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getComments(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List comments = snapshot.data;
                  return ListView(
                    children: [
                      for (int i = 0; i < comments.length; i++) Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: MediaQuery.of(context).size.width/12,
                              backgroundColor: Colors.lightBlueAccent,
                              foregroundImage: CachedNetworkImageProvider(
                                comments[i]["profileImgUrl"]
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  "${comments[i]["username"]}",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Text(
                                  "${timeago.format(comments[i]["timestamp"])}",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              "${comments[i]["comment"]}",
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ],
                  );
                } else {
                  return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blueAccent));
                }
              }
            ),
          ),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Write a comment..."
              ),
            ),
            trailing: !posting ? GestureDetector(
              onTap: () => addComment(),
              child: Container(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                child: Text(
                  "Post",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
            ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blueAccent)),
          )
        ],
      ),
    );
  }
}
