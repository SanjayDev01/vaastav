import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vaastav/progress.dart';

import 'Stories.dart';
import 'User.dart';
import 'home.dart';

// ignore: must_be_immutable
class TrendingTab extends StatefulWidget {
  User currentUser;

  TrendingTab({this.currentUser});

  @override
  _TrendingTabState createState() => _TrendingTabState();
}

class _TrendingTabState extends State<TrendingTab> {
  void initState() {
    super.initState();
    launchSnack9();
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
            "No Stories in your Locality?",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          Text(
            "Create Stories! OR",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          Text(
            "Check if GPS is Allowed in Profile Page.",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  streamGpsTab() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
      stream: gpsRef
          .document(currentUser.gps)
          .collection("userPosts")
          .orderBy("likeCount", descending: true)
          .limit(50)
          .snapshots(),
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
                      crossAxisCount: 2,
                      children: posts,
                    ),
                  ),
                ],
              );
      },
    );
  }

  launchSnack9() async {
    final snackBar = SnackBar(
      content: Text(
        "Top Trending 50 Stories from your locality",
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 1),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfbb37474F),
      body: streamGpsTab(),
    );
  }
}
