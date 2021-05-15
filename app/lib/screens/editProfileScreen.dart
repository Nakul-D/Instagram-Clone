import 'package:flutter/material.dart';
import 'dart:io';
import 'package:app/models/user.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {

  final DatabaseBloc databaseBloc;
  final UserModel userModel;

  EditProfileScreen({this.databaseBloc, this.userModel});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  Image profilePicture;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool profileChanged = false;
  File changedProfileFile;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    if (widget.userModel.profileImgUrl.isNotEmpty) {
      profilePicture = Image(
        image: CachedNetworkImageProvider(widget.userModel.profileImgUrl),
      );
    }
    usernameController.text = widget.userModel.username;
    bioController.text = widget.userModel.bio;
  }

  Widget getProfilePicture(double width) {
    // This function will return Circle Avatar
    if (profilePicture != null) {
      return CircleAvatar(
        radius: width/8,
        backgroundImage: profilePicture.image,
        backgroundColor: Colors.lightBlueAccent,
      );
    } else {
      return CircleAvatar(
        radius: width/8,
        backgroundColor: Colors.lightBlueAccent,
      );
    }
  }

  changeProfilePicture(BuildContext context) {
    // This function will display a dialog with image import options
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
                    if (pickedFile.path.isNotEmpty) {
                      setState(() {
                        profileChanged = true;
                        changedProfileFile = File(pickedFile.path);
                        profilePicture = Image.file(File(pickedFile.path));
                      });
                    } 
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          "Open camera",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
                    if (pickedFile.path.isNotEmpty) {
                      setState(() {
                        profileChanged = true;
                        changedProfileFile = File(pickedFile.path);
                        profilePicture = Image.file(File(pickedFile.path));
                      });
                    }                
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_rounded, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          "Import from gallery",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ],
            ),
          ]
        );
      }
    );
  }

  updateProfile(BuildContext context) async {
    // This function will update username/bio/profileImg in firestore
    setState(() {
      isUpdating = true;
    });
    UpdateProfileEvent event = UpdateProfileEvent(
      username: usernameController.text,
      bio: bioController.text,
      profileChanged: profileChanged,
      profileImgFile: changedProfileFile,
    );
    await widget.databaseBloc.mapEventToState(event).first;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit profile"
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        // Single child scroll view is used to avoid overflow error when keyboard appears
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: getProfilePicture(MediaQuery.of(context).size.width),
              ),
              SizedBox(height: 12.0),
              Center(
                child: GestureDetector(
                  child: Text(
                    "Change profile picture",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  onTap: () => changeProfilePicture(context)
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                "Username",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              TextFormField(controller: usernameController),
              SizedBox(height: 16.0),
              Text(
                "Bio",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              TextFormField(controller: bioController),
              SizedBox(height: 16.0),
              Center(
                child: GestureDetector(
                  onTap: () => updateProfile(context),
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.done, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          "Update",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0
                          ),
                        ),
                        SizedBox(width: 10.0),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          "Discard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0
                          ),
                        ),
                        SizedBox(width: 10.0),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              isUpdating ? LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.lightBlue)) : Text(''),
            ],
          ),
        ),
      ),
    );
  }
}
