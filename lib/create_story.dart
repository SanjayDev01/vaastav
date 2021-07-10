import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:vaastav/progress.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vaastav/User.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_viewer.dart';

import 'home.dart';
import 'User.dart';

class CreateStory extends StatefulWidget {
  final User currentUser;
  CreateStory({
    this.currentUser,
  });

  @override
  _CreateStoryState createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  User user;
  File trimVideo;
  final _picker = ImagePicker();

  var gradesRange = RangeValues(0, 100);

  String outPath;
  int duration;
  final String currentUserId = currentUser?.id;
  // final String currentUserContact = currentUser?.contact;
  final String currentUserGPS = currentUser?.gps;
  bool isPrivate = false;
  // final String pId = currentUser.postID;
  // static int ptg = 0;
  // int ptag = ptg++;
  VideoPlayerController _controller;
  final Trimmer _trimmer = Trimmer();
  TextEditingController timeBoxControllerStart = TextEditingController();
  TextEditingController timeBoxControllerEnd = TextEditingController();
  bool isVideo = false;
  bool forContactsOnly = false;
  bool firstStoryUploaded = false;
  File _imageFile;
  File video;
  String fileName;
  String trimPath;
  //dynamic _pickImageError;
  bool isUploading = false;
  Directory directory;
  String storyId = Uuid().v4();
  String thumbId = Uuid().v4();
  bool progress = false;
  bool isDuration30s = false;
  // Duration position = new Duration(hours: 0, minutes: 0, seconds: 0);
  final navigatorKey = GlobalKey<NavigatorState>();
  String p1;

  final TextEditingController captionController = TextEditingController();
  bool takeFile = false;

  _CreateStoryState({
    this.trimVideo,
    this.duration,
  });

  @override
  void initState() {
    super.initState();
    timestamp = DateTime.now();
    checkForFirstStory();
  }

  launchDialog(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            elevation: 12.0,
            backgroundColor: Colors.white,
            title: Text("Create Post"),
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Add Photo",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              SimpleDialogOption(
                  child: Text(
                    "From Camera",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    isVideo = false;
                    _onImageButtonPressed(ImageSource.camera, context: context);
                  }),
              SimpleDialogOption(
                  child: Text(
                    "From Gallery",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    isVideo = false;
                    _onImageButtonPressed(ImageSource.gallery,
                        context: context);
                  }),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Add Video",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              SimpleDialogOption(
                child: Text(
                  "From Camera",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  isVideo = true;
                  _onImageButtonPressed(ImageSource.camera, context: context);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  "From Gallery",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  isVideo = true;
                  _onImageButtonPressed(ImageSource.gallery, context: context);
                },
              ),
              SimpleDialogOption(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 20.0, color: Colors.blue),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    if (isVideo) {
      PickedFile videoFle = await _picker.getVideo(
          source: source, maxDuration: Duration(seconds: 30));
      // fileName =
      //     'Vaastav' + DateTime.now().millisecondsSinceEpoch.toString() + '.mp4';

      // outPath = '/storage/emulated/0/Movies/Vaastav/$fileName';

      setState(() {
        video = File(videoFle.path);
        takeFile = true;
      });
      if (video != null) {
        await _trimmer
            .loadVideo(videoFile: video)
            .whenComplete(() => setState(() {
                  loadtrue = true;
                }));
      }
    } else {
      PickedFile imageFile = await _picker.getImage(
        source: source,
      );
      setState(() {
        _imageFile = File(imageFile.path);
      });
      if (_imageFile.exists() != null) {
        setState(() {
          takeFile = true;
        });
      }
    }
  }

  bool loadtrue = false;

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;

  Widget _previewVideo() {
    if (video == null) {
      return firstStoryUploaded ? mediaEmptyForOthers() : mediaEmpty();
    }
    return loadtrue
        ? Builder(
            builder: (context) => Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    VideoViewer(),
                    Center(
                      child: TrimEditor(
                        viewerHeight: 50.0,
                        viewerWidth: MediaQuery.of(context).size.width,
                        maxVideoLength: Duration(seconds: 30),
                        onChangeStart: (value) {
                          _startValue = value;
                        },
                        onChangeEnd: (value) {
                          _endValue = value;
                        },
                        onChangePlaybackState: (value) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => setState(() {
                                    _isPlaying = value;
                                  }));
                        },
                      ),
                    ),
                    FlatButton(
                      child: _isPlaying
                          ? Icon(
                              Icons.pause,
                              size: 30.0,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.play_arrow,
                              size: 30.0,
                              color: Colors.white,
                            ),
                      onPressed: () async {
                        bool playbackState = await _trimmer.videPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(() {
                          _isPlaying = playbackState;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        : circularProgress();
  }

  Widget _previewImage() {
    if (_imageFile != null) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          Image.file(_imageFile),
          Padding(
            padding: EdgeInsets.only(left: 5.0, bottom: 10.0, right: 5.0),
            child: ClipOval(
              child: Material(
                color: Color(0xfbbE3008C), // button color
                child: InkWell(
                  splashColor: Colors.red, // inkwell color
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.crop,
                        size: 25.0,
                        color: Colors.white,
                      )),
                  onTap: () => _cropImage(),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return firstStoryUploaded ? mediaEmptyForOthers() : mediaEmpty();
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Color(0xfbbE3008C),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _imageFile = croppedFile;
      setState(() {});
    }
  }

  mediaEmpty() {
    return Container(
      height: 300.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      width: 360.0,
      child: Card(
        elevation: 8.0,
        color: Colors.white,
        child: FlatButton(
          onPressed: () {
            launchDialog(context);
            setState(() {
              takeFile = true;
            });
          },
          child: Text(
            "Click to add media files.",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  mediaEmptyForOthers() {
    return Container(
      height: 300.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      width: 360.0,
      child: Card(
        elevation: 8.0,
        color: Colors.white,
        child: FlatButton(
          onPressed: () {
            launchDialog(context);
            setState(() {
              takeFile = true;
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Already added!",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black54,
                ),
              ),
              Text(
                "Click to add more media files.",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  mediaCaption() {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        // expands: true,
        // validator: captionController.text < 10,
        style: TextStyle(
          fontSize: 24.0,
          color: Colors.black,
          // fontWeight: FontWeight.bold,
        ),
        controller: captionController, maxLength: 20,
        decoration: InputDecoration(
            border: InputBorder.none,
            helperText: "Caption",
            hintText: "Add Caption",

            //  filled: true,
            // fillColor: Colors.white12,
            hintStyle: TextStyle(color: Colors.black45),
            //  labelText: "Caption",
            labelStyle: TextStyle(color: Colors.black, fontSize: 15.0)),
        autofocus: true,
      ),
    );
  }

  mediaFull() {
    return Center(
      child: isVideo ? _previewVideo() : _previewImage(),
    );
  }

  handleSubmitForImage() async {
    setState(() {
      isUploading = true;
    });
    await compressMedia();

    String mediaUrl =
        await uploadImage(_imageFile).whenComplete(() => launchSnack1());
    String getMediaType = 'image';

    createPostInFireStoreWithGps(
      mediaUrl: mediaUrl,
      mediaPreview: mediaUrl,
      mediaType: getMediaType,
      caption: captionController.text,
    );
    captionController.clear();
    setState(() {
      _imageFile = null;
      isUploading = false;
      firstStoryUploaded = true;
    });
    imageCache.clear();
  }

  handleSubmitForVideo() async {
    setState(() {
      progress = true;
      isUploading = true;
    });

    await _trimmer
        .saveTrimmedVideo(
            startValue: _startValue,
            endValue: _endValue,
            videoFileName:
                "Vaastav" + DateTime.now().millisecondsSinceEpoch.toString(),
            videoFolderName: "Vaastav")
        .then((value) {
      setState(() {
        trimVideo = File(value);

        _controller = VideoPlayerController.file(trimVideo)
          ..initialize().then((value) => setState(() {
                duration = _controller.value.duration.inSeconds;
              }));
      });
      if (trimVideo.path.isNotEmpty) {
        handleVideo();
      } else {
        setState(() {
          video = null;
          trimVideo = null;
          isUploading = false;
        });
      }
    });
  }

  handleVideo() async {
    String mediaUrl = await uploadVideo(trimVideo);

    String mediaPreviewUrl =
        await convertIntoThumbnail().whenComplete(() => launchSnack1());
    String getMediaType = 'video';

    createPostInFireStoreWithGps(
      mediaUrl: mediaUrl,
      mediaPreview: mediaPreviewUrl,
      mediaType: getMediaType,
      caption: captionController.text,
    );
    captionController.clear();
    setState(() {
      video = null;
      trimVideo = null;
      isUploading = false;
      firstStoryUploaded = true;
    });
  }

  launchSnack1() {
    final snackBar = SnackBar(
      content: Text("Uploaded Successfully."),
      duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  convertIntoThumbnail() async {
    final unit8list = await VideoThumbnail.thumbnailFile(
      video: trimVideo.path,

      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );
    File mediaFile = File(unit8list);
    String mediaPreview = await uploadThumb(mediaFile);
    return mediaPreview;
  }

  compressMedia() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(_imageFile.readAsBytesSync());

    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _imageFile = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$storyId").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadThumb(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$thumbId").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadVideo(trimVideo) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$storyId").putFile(trimVideo);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFireStoreWithGps({
    String mediaUrl,
    String mediaPreview,
    String mediaType,
    String caption,
    int lc,
  }) {
    lc = 0;
    List file = [
      {
        "filetype": mediaType,
        "url": mediaUrl,
        "otherCaption": caption,
        "time1": timestamp,
        "duration": duration,
      }
    ];

    if (!firstStoryUploaded) {
      postsRef
          .document(currentUser.id)
          .collection("userPosts")
          .document(postId)
          .setData({
        "date": timestamp,
        "postID": postId,
        "userID": currentUser.id,
        "gpsID": currentUser.gps,
        "likeCount": lc,
        "displayName": currentUser.displayName,
        "photoURL": currentUser.photoUrl,
        "file": file,
        "previewImage": mediaPreview,
        "previewTitle": caption,
        "like": {},
        "totalViews": {},
        "report": {}
      });
      gpsRef
          .document(currentUser.gps)
          .collection("userPosts")
          .document(postId)
          .setData({
        "date": timestamp,
        "postID": postId,
        "userID": currentUser.id,
        "gpsID": currentUser.gps,
        "displayName": currentUser.displayName,
        "likeCount": lc,
        "photoURL": currentUser.photoUrl,
        "file": file,
        "previewImage": mediaPreview,
        "previewTitle": caption,
        "like": {},
        "totalViews": {},
        "report": {}
      });
      storyRef
          .document(currentUser.id)
          .collection("userPosts")
          .document(storyId)
          .setData({});
      storyRef
          .document(currentUser.id)
          .collection("userPosts")
          .document(thumbId)
          .setData({});
      postsRef.document(currentUser.id).setData({"postId1": postId});
    } else {
      postsRef
          .document(currentUser.id)
          .collection("userPosts")
          .document(p1)
          .updateData({'file': FieldValue.arrayUnion(file)});
      gpsRef
          .document(currentUser.gps)
          .collection("userPosts")
          .document(p1)
          .updateData({
        "date": timestamp,
        "displayName": currentUser.displayName,
        "postID": p1,
        "userID": currentUser.id,
        "gpsID": currentUser.gps,
        "photoURL": currentUser.photoUrl,
        "file": FieldValue.arrayUnion(file),
        "previewImage": mediaPreview,
        "previewTitle": caption,
        "like": {},
        "totalViews": {},
        "report": {}
      });
      storyRef
          .document(currentUser.id)
          .collection("userPosts")
          .document(storyId)
          .setData({});
      storyRef
          .document(currentUser.id)
          .collection("userPosts")
          .document(thumbId)
          .setData({});
    }
  }

  checkForFirstStory() async {
    QuerySnapshot snapshot = await postsRef
        .document(currentUser.id)
        .collection("userPosts")
        .getDocuments();
    if (snapshot.documents.isNotEmpty) {
      DocumentSnapshot doc = await postsRef.document(currentUser.id).get();
      Post1 p = Post1.fromDocument(doc);
      setState(() {
        firstStoryUploaded = true;
        p1 = p.postId1;
      });
    } else {
      setState(() {
        firstStoryUploaded = false;
      });
    }
    setState(() {
      video = null;
      trimVideo = null;
      isUploading = false;
      _imageFile = null;
      captionController.clear();
    });
  }

  launchSnack() {
    final snackBar = SnackBar(
      content: Text("Duration of the video cannot be more than 30 seconds"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  launchSnack2() {
    final snackBar = SnackBar(
      content: Text("No file is Selected, Please Select Files."),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  postStory() {
    return Container(
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.only(
          top: 13,
          bottom: 13,
          left: 100,
          right: 100,
        ),
        elevation: 5.0,
        child: FlatButton(
          onPressed: isUploading
              ? null
              : (takeFile
                  ? (isVideo ? handleSubmitForVideo : handleSubmitForImage)
                  : launchSnack2),
          padding: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 40.0,
            right: 40.0,
          ),
          child: Text(
            "Submit",
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
      ),
    );
  }

  bodyPart() {
    return ListView(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Stack(
          children: <Widget>[
            takeFile
                ? mediaFull()
                : (firstStoryUploaded ? mediaEmptyForOthers() : mediaEmpty()),
            isUploading ? circularProgress() : Text(""),
          ],
          alignment: Alignment.center,
        ),
        SizedBox(
          height: 10.0,
        ),
        mediaCaption(),
        SizedBox(
          height: 10.0,
        ),
        postStory(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfbb37474F),
      body: RefreshIndicator(
        child: bodyPart(),
        onRefresh: () => checkForFirstStory(),
      ),
    );
  }
}
