import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app/screens/uploadScreen.dart';

class AddScreen extends StatelessWidget {

  final DatabaseBloc databaseBloc;
  
  AddScreen({@required this.databaseBloc});

  openCamera(BuildContext context) async {
    // This function will handle taking photo
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UploadScreen(
            databaseBloc: databaseBloc,
            imageFile: File(pickedFile.path),
          ),
        )
      );
    }
  }

  importFromGallery(BuildContext context) async {
    // This function will handle picking image from gallery
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UploadScreen(
            databaseBloc: databaseBloc,
            imageFile: File(pickedFile.path),
          ),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Post"
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => openCamera(context),
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
                onTap: () => importFromGallery(context),
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
          )
        ),
      ),
    );
  }
}
