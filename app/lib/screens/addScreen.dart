import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';

class AddScreen extends StatelessWidget {
  
  final DatabaseBloc databaseBloc;
  
  AddScreen({@required this.databaseBloc});

  openCamera() {
    print("Open camera");
  }

  importFromGallery() {
    print("Import from gallery");
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
                onTap: openCamera,
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              GestureDetector(
                onTap: importFromGallery,
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
                    color: Colors.blue,
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
