import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vaastav/progress.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'Stories.dart';
import 'User.dart';
import 'create_story.dart';
import 'home.dart';

class YoursTab extends StatefulWidget {
  final User currentUser;

  YoursTab({this.currentUser});

  @override
  _YoursTabState createState() => _YoursTabState();
}

class _YoursTabState extends State<YoursTab> {
  void initState() {
    super.initState();
    //  streamYoursData();
    // launchSnack10();
  }

  submitAt() {
    return Timer(Duration(seconds: 0), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateStory(
            currentUser: currentUser,
          ),
        ),
      );
    });
  }

  postsEmpty2() {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(bottom: 200.0),
      child: Center(
        child: Text(
          "No Viewers.",
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
    );
  }

  postsIsEmpty1() {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(bottom: 200.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "You have zero Stories",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          Text(
            "Create Stories",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  streamYoursData() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
      stream:
          postsRef.document(currentUser.id).collection("userPosts").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Story> posts = snapshot.data.documents
            .map((doc) => Story.fromDocument(doc))
            .toList();

        return (posts.isEmpty)
            ? postsIsEmpty1()
            : CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.all(3),
                    sliver: SliverGrid.count(
                      mainAxisSpacing: 7,
                      crossAxisSpacing: 7,
                      childAspectRatio: (w / 2) / (h / 3),
                      // childAspectRatio: (210 / 310),
                      crossAxisCount: 2,
                      children: posts,
                    ),
                  ),
                ],
              );
      },
    );
  }

  streamViewers() {
    return StreamBuilder<QuerySnapshot>(
      stream: allViewsRef
          .document(currentUser.id)
          .collection("allViewers")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<ListOfViewer> viewerList = snapshot.data.documents
            .map((e) => ListOfViewer.fromDocument(e))
            .toList();
        return viewerList.isEmpty
            ? postsEmpty2()
            : ListView(
                children: viewerList,
              );
      },
    );
  }

  // launchSnack10() async {
  //   final snackBar = SnackBar(
  //     content: Text("Your Stories"),
  //     behavior: SnackBarBehavior.floating,
  //     duration: Duration(seconds: 2),
  //   );
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  listOfAllViewers() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xfbbE3008C),
          title: Text(
            "Viewers",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
                fontSize: 26.0),
          ),
          centerTitle: true,
        ),
        backgroundColor: Color(0xfbb37474F),
        body: streamViewers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfbb37474F),
        body: streamYoursData(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          autofocus: true,

          clipBehavior: Clip.hardEdge,
          backgroundColor: Color(0xfbb546E7A),
          elevation: 5.0,
          highlightElevation: 14.0,
          //ini: true,
          child: Icon(
            Icons.remove_red_eye,
            size: 25.0,
            color: Colors.white70,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return listOfAllViewers();
            }));
          },
        ));
  }
}

class ListOfViewer extends StatelessWidget {
  final String photoURL;
  final String displayName;
  final Timestamp timestamp;

  ListOfViewer({
    this.photoURL,
    this.displayName,
    this.timestamp,
  });

  factory ListOfViewer.fromDocument(DocumentSnapshot doc) {
    return ListOfViewer(
      photoURL: doc["photoURL"],
      displayName: doc["displayName"],
      timestamp: doc["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 2.0),
        child: Card(
          color: Color(0xfbb455A64),
          elevation: 5.0,
          child: ListTile(
            title: Text(
              displayName,
              //overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(photoURL),
              radius: 25.0,
            ),
            subtitle: Text(
              timeAgo.format(timestamp.toDate()),
              // overflow: TextOverflow.ellipsis,
              //timestamp..toString() + ' minutes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
