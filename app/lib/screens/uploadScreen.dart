import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'package:app/logic/databaseEvents.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UploadScreen extends StatefulWidget {

  final DatabaseBloc databaseBloc;
  final File imageFile;

  UploadScreen({@required this.databaseBloc, @required this.imageFile});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  final captionController = TextEditingController();
  final locationController = TextEditingController();
  bool uploadingPost = false;

  getLocation() async {
    // This function will get current location and format it
    Position position = await Geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await GeocodingPlatform
      .instance
      .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

  upload(BuildContext context) async {
    setState(() {
      uploadingPost = true;
    });
    // This function will upload the post to firebase
    UploadPostEvent event = UploadPostEvent(
      imageFile: widget.imageFile,
      caption: captionController.text,
      location: locationController.text,
    );
    await widget.databaseBloc.mapEventToState(event).first;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Caption Post"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: ListView(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width/1.5,
                  child: AspectRatio(
                    aspectRatio: 1/1,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(widget.imageFile),
                          fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.keyboard, color: Colors.blueAccent, size: 35.0),
                title: Container(
                  width: 250,
                  child: TextField(
                    controller: captionController,
                    decoration: InputDecoration(
                      hintText: "Write a caption",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.pin_drop, color: Colors.blueAccent, size: 35.0),
                title: Container(
                  width: 250,
                  child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: "Where was this photo taken?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: GestureDetector(
                  onTap: () => getLocation(),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.my_location, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "Get current location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(100)
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: GestureDetector(
                  onTap: () => upload(context),
                  child: Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0, bottom: 10.0),
                    child: Text(
                      "Upload",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(100)
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              uploadingPost ? LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.lightBlue)) : Text(''),
            ],
          ),
        ),
      ),
    );
  }
}
