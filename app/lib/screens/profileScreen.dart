import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:app/widgets/postTile.dart';
import 'package:app/models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'editProfileScreen.dart';

class ProfileScreen extends StatefulWidget {

  final DatabaseBloc databaseBloc;
  final String profileUserId;
  
  ProfileScreen({@required this.databaseBloc, @required this.profileUserId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String username;
  String bio;
  String profileImgUrl;
  List followers = [];
  List following = [];
  List<PostModel> posts = [];
  bool isLoading = true;
  bool isFollowing;

  void initState() {
    getProfileData();
    super.initState();
  }

  getProfileData() async {
    // This function will fetch profile screen data
    DatabaseEvents event = GetProfileEvent(profileUserId: widget.profileUserId);
    Map data = await widget.databaseBloc.mapEventToState(event).first;
    setState(() {
      username = data['username'];
      bio = data['bio'];
      profileImgUrl =  data['profileImgUrl'];
      followers = data['followers'];
      following = data['following'];
      posts = data['posts'];
      isFollowing = followers.contains(widget.databaseBloc.currentUser.id);
      isLoading = false;
    });
  }

  followProfile() async {
    if (isFollowing) {
      // Unfollowing profile
      UnfollowEvent event = UnfollowEvent(profileId: widget.profileUserId);
      await widget.databaseBloc.mapEventToState(event).first;
      setState(() {
        followers.remove(widget.databaseBloc.currentUser.id);
        isFollowing = false;
      });
    } else {
      // Following profile
      FollowEvent event = FollowEvent(profileId: widget.profileUserId);
      await widget.databaseBloc.mapEventToState(event).first;
      setState(() {
        followers.add(widget.databaseBloc.currentUser.id);
        isFollowing = true;
      });
    }
  }

  Widget profilePicture(String url, double width) {
    // This function will check if String url is empty
    // If url is not empty then the function will fetch the url
    // Else the function will return a empty circle avatar
    if (url.isNotEmpty) {
      return CircleAvatar(
        radius: width/8,
        backgroundColor: Colors.lightBlueAccent,
        foregroundImage: CachedNetworkImageProvider(url),
      );
    } else {
      return CircleAvatar(
        radius: width/8,
        backgroundColor: Colors.lightBlueAccent,
      );
    }
  }

  Column buildCountColumn(String label, int count) {
    // This function will return a column with posts/followers/following count
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w400
            ),
          ),
        ),
      ],
    );
  }

  Widget editButton(BuildContext context) {
    // This function will build edit button
    // On tapped: will push to Edit screen
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        padding: EdgeInsets.all(7.0),
        child: Text(
          "Edit profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          ),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProfileScreen(
            databaseBloc: widget.databaseBloc,
            userModel: widget.databaseBloc.currentUser)
          )
        );
        getProfileData(); // Refreshing profile page
      },
    );
  }

  Widget followButton(BuildContext context) {
    // This function will build follow button
    // On tapped: will follow the user
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        padding: EdgeInsets.all(7.0),
        child: Text(
          isFollowing ? "Unfollow" : "Follow",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          ),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
      onTap: () => followProfile(),
    );
  }

  showPostTile(PostModel postModel) {
    // This function will display a dialog
    // Similar to a full screen post in instagram
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            PostTile(
              postModel: postModel,
              width: MediaQuery.of(context).size.width,
              databaseBloc: widget.databaseBloc
            )
          ],
        );
      }
    );
  }
  
  Widget gridViewPosts(List<PostModel> posts,BuildContext context) {
    // This function will display posts in a grid view
    List<GridTile> gridTiles = [];
    posts.forEach((element) {
      gridTiles.add(
        GridTile(
          child: GestureDetector(
            child: Container(
              child: Image(
                image: CachedNetworkImageProvider(element.mediaUrl),
                fit: BoxFit.cover,
              ),
            ),
            onTap: () => showPostTile(element),
          ),
        )
      );
    });
    
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        children: gridTiles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile"
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        ),
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                profilePicture(profileImgUrl, width),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildCountColumn("Posts", posts.length),
                            buildCountColumn("Followers", followers.length),
                            buildCountColumn("Following", following.length),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        widget.profileUserId == widget.databaseBloc.currentUser.id ? editButton(context) : followButton(context)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              "$username",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Text(
              "$bio",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400
              ),
            ),
          ),
          Divider(thickness: 2.0, height: 0.0),
          gridViewPosts(posts, context),
        ],
      )
    );
  }
}
