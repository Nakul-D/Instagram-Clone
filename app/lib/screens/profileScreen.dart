import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:app/models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {

  final DatabaseBloc databaseBloc;
  final String profileUserId;
  
  ProfileScreen({@required this.databaseBloc, @required this.profileUserId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String postOrientation = "grid";

  Future getProfileData() async {
    // This function will fetch profile data of the given userId
    DatabaseEvents event = GetProfileEvent(profileUserId: widget.profileUserId);
    Map profileData = await widget.databaseBloc.mapEventToState(event).first;
    return profileData;
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
      onTap: () => print("Edit profile"),
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
          "Follow",
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
      onTap: () => print("Follow"),
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
      body: FutureBuilder(
        future: getProfileData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map profileData = snapshot.data;
            print(profileData);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      profilePicture(profileData['profileImgUrl'], width),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  buildCountColumn("Posts", profileData['postCount']),
                                  buildCountColumn("Followers", profileData['followers']),
                                  buildCountColumn("Following", profileData['following']),
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
                    "${profileData['username']}",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                  child: Text(
                    "${profileData['bio']}",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ),
                Divider(thickness: 2.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.grid_on),
                      color: postOrientation == "grid" ? Theme.of(context).primaryColor : Colors.grey,
                      onPressed: () {
                        setState(() {
                          postOrientation = "grid";
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.list),
                      color: postOrientation == "list" ? Theme.of(context).primaryColor : Colors.grey,
                      onPressed: () {
                        setState(() {
                          postOrientation = "list";
                        });
                      },
                    )
                  ],
                ),
                Divider(thickness: 2.0),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            );
          }
        }
      ),
    );
  }
}
