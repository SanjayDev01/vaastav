import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vaastav/View_Stories.dart';
import 'package:vaastav/custom_image.dart';
import 'package:story_view/story_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'home.dart';

class Story extends StatefulWidget {
  final String previewImage;
  final String previewTitle;
  final String photoURL;
  final String postID;
  final String userID;
  final String gpsID;
  final dynamic like;
  final String displayName;
  final dynamic totalViews;
  final List file;
  final Timestamp date;

  Story({
    this.previewImage,
    this.previewTitle,
    this.photoURL,
    this.postID,
    this.userID,
    this.gpsID,
    this.like,
    this.totalViews,
    this.displayName,
    this.file,
    this.date,
  });

  factory Story.fromDocument(DocumentSnapshot doc) {
    return Story(
        previewImage: doc["previewImage"],
        photoURL: doc["photoURL"],
        postID: doc["postID"],
        userID: doc["userID"],
        gpsID: doc["gpsID"],
        previewTitle: doc["previewTitle"],
        displayName: doc["displayName"],
        like: doc["like"],
        date: doc["date"],
        totalViews: doc["totalViews"],
        file: doc["file"].map<files>((item) {
          return files.fromMap(item);
        }).toList());
  }

  int getLikeCount(like) {
    if (like == null) {
      return 0;
    }
    int count = 0;
    like.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  int getViewCount(totalViews) {
    if (totalViews == null) {
      return 0;
    }
    int count = 0;
    totalViews.values.forEach((val) {
      count += 1;
    });
    return count;
  }

  @override
  _StoryState createState() => _StoryState(
        previewImage: this.previewImage,
        previewTitle: this.previewTitle,
        photoURL: this.photoURL,
        postID: this.postID,
        userID: this.userID,
        gpsID: this.gpsID,
        file: this.file,
        date: this.date,
        like: this.like,
        displayName: this.displayName,
        totalViews: this.totalViews,
        likeCount: getLikeCount(this.like),
        viewCount: getViewCount(this.totalViews),
      );
}

class _StoryState extends State<Story> {
  final String previewImage;
  final String previewTitle;
  final String postID;
  final String userID;
  final String photoURL;
  final String gpsID;
  final String displayName;
  List file;
  Map like;
  Map totalViews;
  int likeCount;
  int viewCount;
  Story story;
  bool showHeart = false;
  bool isLiked = false;
  String currentUserId = currentUser?.id;
  bool isOwner;
  Timestamp date;

  _StoryState({
    this.previewImage,
    this.previewTitle,
    this.photoURL,
    this.postID,
    this.date,
    this.userID,
    this.gpsID,
    this.displayName,
    this.file,
    this.like,
    this.totalViews,
    this.likeCount,
    this.viewCount,
  });
  @override
  initState() {
    super.initState();
    checkOwner();
    timestamp = DateTime.now();
  }

  checkOwner() {
    if (userID == currentUser.id) {
      setState(() {
        isOwner = true;
      });
    } else {
      setState(() {
        isOwner = false;
      });
    }
  }

  postStory() {
    return GestureDetector(
      onLongPress: isOwner ? askDelete : null,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AllOtherStory(
                  file: file,
                  displayName: displayName,
                  gpsID: gpsID,
                  photoURL: photoURL,
                  postID: postID,
                  userID: userID,
                )));
      },
      child: Card(
        borderOnForeground: false,
        shadowColor: Colors.black,
        semanticContainer: false,
        elevation: 25.0,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    color: Color(0xfbb455A64),
                    child: cachedNetworkImage(previewImage),
                  ),
                  Container(
                    child: CircleAvatar(
                      child: Text(
                        "${file.asMap().length}",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Color(0xfbb455A64),
                      radius: 15.0,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                color: Color(0xfbb455A64),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Text(
                                previewTitle,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                            fit: FlexFit.loose,
                            flex: 2,
                          ),
                          Flexible(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                            fit: FlexFit.loose,
                            flex: 1,
                          ),
                          Flexible(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                left: 10.0,
                                bottom: 2.0,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "$viewCount views",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                            fit: FlexFit.loose,
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(
                          right: 10.0,
                          top: 4.0,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Padding(
                                child: handleLike(),
                                padding: EdgeInsets.only(left: 10.0),
                              ),
                              flex: 2,
                              fit: FlexFit.tight,
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 10.0,
                                  top: 2.0,
                                  bottom: 2.0,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "$likeCount likes",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              fit: FlexFit.tight,
                              flex: 1,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  handleDelete() {
    postsRef
        .document(currentUser.id)
        .collection("userPosts")
        .document(postID)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    gpsRef
        .document(currentUser.gps)
        .collection("userPosts")
        .document(postID)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    allViewsRef
        .document(currentUser.id)
        .collection("allViewers")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });

    Navigator.of(context).pop();
    launchSnack4();
  }

  launchSnack4() {
    final snackBar = SnackBar(
      content: Text("Story Deleted!"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  askDelete() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          elevation: 12.0,
          backgroundColor: Colors.white,
          title: Text("Delete Stories ?"),
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: FlatButton(
                      onPressed: handleDelete,
                      child: Text(
                        "Yes",
                        style: TextStyle(fontSize: 20.0, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 60.0,
                    left: 20.0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "No",
                        style: TextStyle(fontSize: 20.0, color: Colors.blue),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  // handleReport() {
  //   postsRef
  //       .document(currentUser.id)
  //       .collection("userPosts")
  //       .document(postID)
  //       .updateData({'report.$currentUserId': true});

  //   gpsRef
  //       .document(currentUser.gps)
  //       .collection("userPosts")
  //       .document(postID)
  //       .updateData({'report.$currentUserId': true});
  // }

  // askReport() {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SimpleDialog(
  //         elevation: 12.0,
  //         backgroundColor: Colors.white,
  //         title: Text("Report Stories ?"),
  //         children: <Widget>[
  //           Row(
  //             children: <Widget>[
  //               Padding(
  //                 padding: EdgeInsets.only(left: 20.0),
  //                 child: FittedBox(
  //                   fit: BoxFit.scaleDown,
  //                   child: FlatButton(
  //                     onPressed: handleReport,
  //                     child: Text(
  //                       "Yes",
  //                       style: TextStyle(fontSize: 20.0, color: Colors.blue),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: EdgeInsets.only(
  //                   right: 60.0,
  //                   left: 20.0,
  //                 ),
  //                 child: FittedBox(
  //                   fit: BoxFit.scaleDown,
  //                   child: FlatButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       "No",
  //                       style: TextStyle(fontSize: 20.0, color: Colors.blue),
  //                     ),
  //                   ),
  //                 ),
  //               )
  //             ],
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  handleLikePost() {
    bool _isLiked = like[currentUser.id] == true;
    if (_isLiked) {
      setState(() {
        postsRef
            .document(userID)
            .collection("userPosts")
            .document(postID)
            .updateData({'like.$currentUserId': false});
        gpsRef
            .document(gpsID)
            .collection("userPosts")
            .document(postID)
            .updateData({'like.$currentUserId': false});
        myFavRef
            .document(currentUser.id)
            .collection("user")
            .document(userID)
            .collection("posts")
            .document(postID)
            .delete();

        likeCount -= 1;
        like[currentUser.id] = false;
        isLiked = false;
      });
      gpsRef
          .document(gpsID)
          .collection("userPosts")
          .document(postID)
          .updateData({
        'likeCount': likeCount,
      });
      launchSnack3();
    } else if (!_isLiked) {
      setState(() {
        postsRef
            .document(userID)
            .collection("userPosts")
            .document(postID)
            .updateData({'like.$currentUserId': true});
        gpsRef
            .document(gpsID)
            .collection("userPosts")
            .document(postID)
            .updateData({'like.$currentUserId': true});
        myFavRef
            .document(currentUser.id)
            .collection("user")
            .document(userID)
            .collection("posts")
            .document(postID)
            .setData({
          "Post Liked": true,
        });
        likeCount += 1;
        isLiked = true;
        like[currentUser.id] = true;
      });
      gpsRef
          .document(gpsID)
          .collection("userPosts")
          .document(postID)
          .updateData({
        'likeCount': likeCount,
      });
      launchSnack2();
    }
  }

  launchSnack2() {
    final snackBar = SnackBar(
      content: Text("Story Liked!"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  launchSnack3() {
    final snackBar = SnackBar(
      content: Text("Story Unliked!"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  handleLike() {
    return GestureDetector(
      onTap: handleLikePost,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
            size: 34.0, color: Colors.pink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (like[currentUser.id] == true);
    return postStory();
  }
}

class AllOtherStory extends StatefulWidget {
  final List file;
  final String photoURL;
  final String postID;
  final String userID;
  final String gpsID;
  final String displayName;

  const AllOtherStory({
    this.displayName,
    this.file,
    this.gpsID,
    this.photoURL,
    this.postID,
    this.userID,
  });
  @override
  _AllOtherStoryState createState() => _AllOtherStoryState(
        file: file,
        photoURL: photoURL,
        postID: postID,
        userID: userID,
        gpsID: gpsID,
        displayName: displayName,
      );
}

class _AllOtherStoryState extends State<AllOtherStory> {
  files fa;
  List file;
  final String postID;
  final String userID;
  final String photoURL;
  final String gpsID;

  final String displayName;
  List<StoryItem> storyItems = [];
  Timestamp time1;
  String currentUserId = currentUser?.id;

  _AllOtherStoryState({
    this.file,
    this.displayName,
    this.gpsID,
    this.postID,
    this.userID,
    this.photoURL,
  });

  @override
  void initState() {
    super.initState();
    fetchStory();

    time1 = widget.file[0].time1;
  }

  fetchStory() {
    file.asMap().forEach((index, fa) {
      if (fa.filetype == "video") {
        storyItems.add(
          StoryItem.pageVideo(
            fa.url,
            controller: storyController,
            caption: "${fa.otherCaption}",
            imageFit: BoxFit.contain,
            duration: Duration(
              seconds: fa.duration,
            ),
          ),
        );
      } else {
        storyItems.add(
          StoryItem.pageImage(
            url: fa.url,
            controller: storyController,
            caption: "${fa.otherCaption}",
            imageFit: BoxFit.contain,
            duration: Duration(
              seconds: 5,
            ),
          ),
        );
      }
    });
  }

  Widget _buildProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(photoURL),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                displayName,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "${timeAgo.format(time1.toDate())}",
                //"$time2",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 15.0,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  addUserToDb() {
    postsRef
        .document(userID)
        .collection("userPosts")
        .document(postID)
        .updateData({'totalViews.$currentUserId': true});
    gpsRef
        .document(gpsID)
        .collection("userPosts")
        .document(postID)
        .updateData({'totalViews.$currentUserId': true});
    allViewsRef
        .document(userID)
        .collection("allViewers")
        .document(currentUser.id)
        .setData({
      "photoURL": currentUser.photoUrl,
      "displayName": currentUser.displayName,
      "timestamp": timestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StoryView(
            storyItems: storyItems,
            controller: storyController,
            progressPosition: ProgressPosition.top,
            onStoryShow: (storyItem) {
              int pos = storyItems.indexOf(storyItem);
              if (pos > 0) {
                setState(() {
                  time1 = widget.file[pos].time1;
                });
              }
              addUserToDb();
            },
            onComplete: () => Navigator.of(context).pop(),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 48,
              left: 16,
              right: 16,
            ),
            child: _buildProfileView(),
          )
        ],
      ),
    );
  }
}
