import 'package:flutter/material.dart';
import 'package:app/models/post.dart';
import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostTile extends StatefulWidget {

  final PostModel postModel;
  final double width;

  PostTile({this.postModel, this.width});

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {

  int likeCount = 0;
  bool animateHeart = false;  // This boolean will be used to display animated heart when post is liked
  bool isLiked = false;

  handleLikePost() {
    // This function will handle liking and unliking a post
    if (isLiked) {
      setState(() {
        isLiked = false;
        likeCount -= 1;
      });
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
    }
    print("update in firestore");
  }

  showComments() {
    // This function will display comments
    print("display comments");
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
                radius: widget.width/20,
                backgroundColor: Colors.lightBlueAccent,
                foregroundImage: CachedNetworkImageProvider(widget.postModel.profileImgUrl),
              ) : CircleAvatar(
                radius: widget.width/20,
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
                aspectRatio: 1.0,
                child: Image(
                  image: CachedNetworkImageProvider(widget.postModel.mediaUrl),
                  fit: BoxFit.contain,
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
                onTap: () => showComments(),
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
