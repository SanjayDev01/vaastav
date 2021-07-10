import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:vaastav/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'User.dart';
import 'home.dart';
import 'package:image/image.dart' as Im;

class ProfilePage extends StatefulWidget {
  final String currentUserId = currentUser?.id;
  // final String currentUserContact = currentUser?.contact;
  final String currentUserGPS = currentUser?.gps;

//  ProfilePage({this.currentUserId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController locationController = TextEditingController();
  bool isLoading = false;
  bool isload = false;
  User user;
  String updatedGps;
  File newdp;
  bool gotGPS = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    getUser();

    //  getUserLocation();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    setState(() {
      isLoading = false;
    });
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  getUserLocation() async {
    bool serviceResult = await Geolocator().isLocationServiceEnabled();
    if (serviceResult) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      //  String completeAddress = '${placemark.postalCode}';

      String formattedAddress = "${placemark.postalCode}";
      locationController.text = formattedAddress;
      final String gpsData = locationController.text;

      usersRef
          .document(currentUser.id)
          .updateData({'gps': gpsData}).whenComplete(() => launchSnack3());

      //  gpsRef.document(user.gps).setData({});
      setState(() {
        gotGPS = true;
      });
    } else {
      return launchSnack2();
    }
  }

  afterGetGPS(context) {
    return Container(
      width: 200,
      height: 80,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: 9.0,
      ),
      child: RaisedButton(
        onPressed: () => getUserLocation(),
        color: Colors.white60,
        elevation: 12.0,
        child: Text(
          "Update Location",
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("profile_${currentUser.id}").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  launchSnack3() {
    final snackBar = SnackBar(
      content: Text("Your Location Updated"),
      duration: Duration(seconds: 2),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  launchSnack2() {
    final snackBar = SnackBar(
      content: Text("Please Switch on GPS."),
      duration: Duration(seconds: 2),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  launchSnack1() {
    final snackBar = SnackBar(
      content: Text("Profile Picture Updated Successfully."),
      duration: Duration(seconds: 2),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  compressMedia() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(newdp.readAsBytesSync());

    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 70));
    setState(() {
      newdp = compressedImageFile;
    });
  }

  changeDp(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          elevation: 12.0,
          backgroundColor: Colors.white,
          title: Text("Select Photo"),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.camera,
                        size: 30,
                      ),
                      onPressed: () async {
                        setState(() {
                          isload = true;
                        });
                        Navigator.of(context).pop();

                        PickedFile newdp0 =
                            await _picker.getImage(source: ImageSource.camera);
                        newdp = File(newdp0.path);

                        if (newdp != null) {
                          await compressMedia();

                          String mediaUrl = await uploadImage(newdp)
                              .whenComplete(() => launchSnack1());

                          usersRef.document(currentUser.id).updateData({
                            "photoUrl": mediaUrl,
                          });
                        }
                        setState(() {
                          isload = false;
                        });
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.photo_library,
                        size: 30,
                      ),
                      onPressed: () async {
                        setState(() {
                          isload = true;
                        });
                        Navigator.of(context).pop();

                        PickedFile newdp0 =
                            await _picker.getImage(source: ImageSource.gallery);
                        newdp = File(newdp0.path);
                        if (newdp != null) {
                          await compressMedia();

                          String mediaUrl = await uploadImage(newdp)
                              .whenComplete(() => launchSnack1());

                          usersRef.document(currentUser.id).updateData({
                            "photoUrl": mediaUrl,
                          });
                        }
                        setState(() {
                          isload = false;
                        });
                      }),
                ),
              ],
            ),
            SimpleDialogOption(
              child: Container(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 15.0, color: Colors.blue),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xfbb455A64),
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(fontSize: 28.0, color: Colors.white),
          ),
          backgroundColor: Color(0xfbbE3008C),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () => getUser(),
          child: isLoading
              ? circularProgress()
              : Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    top: 14.0,
                    left: 14.0,
                    right: 14.0,
                    bottom: 14.0,
                  ),
                  child: Card(
                    elevation: 8.0,
                    borderOnForeground: true,
                    color: Colors.white,
                    child: ListView(
                      children: <Widget>[
                        isload ? linearProgress() : Text(""),
                        Container(
                          margin: EdgeInsets.all(20.0),
                          alignment: Alignment.center,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 16.0, bottom: 8.0),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: <Widget>[
                                    CircleAvatar(
                                      foregroundColor: Colors.white,
                                      radius: 80.0,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              user.photoUrl),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_a_photo,
                                        size: 40.0,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => changeDp(context),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  user.displayName,
                                  style: TextStyle(
                                    //  fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                    decoration: TextDecoration.underline,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  user.email,
                                  style: TextStyle(
                                    //  fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.black54,
                                    decoration: TextDecoration.underline,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // ifNotVerify ? checkVerify() : myPhoneNumber(),
                              SizedBox(
                                height: 1.0,
                              ),
                              afterGetGPS(context),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 20.0),
                                child: FlatButton(
                                  autofocus: true,
                                  onPressed: logout,
                                  child: Text(
                                    "Signout",
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
