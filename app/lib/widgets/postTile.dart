import 'package:flutter/material.dart';
import 'package:app/models/post.dart';
import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:app/screens/commentScreen.dart';

class PostTile extends StatefulWidget {

  final PostModel postModel;
  final double width;
  final DatabaseBloc databaseBloc;

  PostTile({this.postModel, this.width, this.databaseBloc});

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {

  int likeCount;
  bool isLiked;
  bool animateHeart = false;  // This boolean will be used to display animated heart when post is liked

  @override
  void initState() {
    super.initState();
    likeCount = getLikes();
    if (widget.postModel.like.containsKey(widget.databaseBloc.currentUser.id)) {
      isLiked = widget.postModel.like[widget.databaseBloc.currentUser.id];
    } else {
      isLiked = false;
    }
  }

  int getLikes() {
    // This function will return total number of likes of a post
    int _likes = 0;
    widget.postModel.like.forEach((key, value) {
      if (value == true) {
        _likes += 1;
      }
    });
    return _likes;
  }

  handleLikePost() {
    // This function will handle liking and unliking a post
    if (isLiked) {
      setState(() {
        isLiked = false;
        likeCount -= 1;
      });
      // Updating post in firestore
      UnlikePostEvent event = UnlikePostEvent(
        ownerId: widget.postModel.ownerId,
        postId: widget.postModel.postId,
      );
      widget.databaseBloc.add(event);
    } else {
      setState(() {
        isLiked = true;
        likeCount += 1;
        animateHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          animateHeart = false;
        });
      });
      // Update in firestore
      LikePostEvent event = LikePostEvent(
        ownerId: widget.postModel.ownerId,
        postId: widget.postModel.postId,
      );
      widget.databaseBloc.add(event);
    }
  }

  showComments(BuildContext context) {
    // This function will display comments
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentScreen(
          postId: widget.postModel.postId,
          databaseBloc: widget.databaseBloc
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 8.0),
          child: Row(
            children: [
              widget.postModel.profileImgUrl != "" ? CircleAvatar(
                radius: widget.width/15,
                backgroundColor: Colors.lightBlueAccent,
                foregroundImage: CachedNetworkImageProvider(widget.postModel.profileImgUrl),
              ) : CircleAvatar(
                radius: widget.width/15,
                backgroundColor: Colors.lightBlueAccent,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.postModel.username}",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    "${widget.postModel.location}",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onDoubleTap: () => handleLikePost(),
              child: AspectRatio(
                aspectRatio: 1/1,
                child: Image(
                  image: CachedNetworkImageProvider(widget.postModel.mediaUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            animateHeart ? Animator(
              duration: Duration(milliseconds: 300),
              tween: Tween(
                begin: 0.8,
                end: 1.4
              ),
              curve: Curves.elasticOut,
              cycles: 0,
              builder: (context, animatorState, child) => Transform.scale(
                scale: animatorState.value,
                child:  Icon(Icons.favorite, size: 80.0, color: Colors.redAccent),
              ),
            ) : Text(""),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0,
                  color: Colors.redAccent,
                ),
                onTap: () => handleLikePost(),
              ),
              SizedBox(width: 10.0),
              GestureDetector(
                child: Icon(
                  Icons.chat,
                  size: 28.0,
                  color: Colors.blue,
                ),
                onTap: () => showComments(context),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0, top: 5.0),
          child: Text(
            "${widget.postModel.caption}"
          ),
        ),
      ],
    );
  }
}
