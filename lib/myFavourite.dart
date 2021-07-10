import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vaastav/progress.dart';

import 'Stories.dart';
import 'User.dart';
import 'home.dart';

// ignore: must_be_immutable
class FavTab extends StatefulWidget {
  User currentUser;

  FavTab({this.currentUser});

  @override
  _FavTabState createState() => _FavTabState();
}

class _FavTabState extends State<FavTab> {
  List<Story> favPosts = [];

  void initState() {
    super.initState();
    getYourData();
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
            "You didn't liked any Stories",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          Text(
            "Stories Stays here for 48 hrs",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  getYourData() async {
    QuerySnapshot snapshot = await usersFavRef
        .document(currentUser.id)
        .collection("userPosts")
        .orderBy("date", descending: true)
        .getDocuments();

    List<Story> posts =
        snapshot.documents.map((doc) => Story.fromDocument(doc)).toList();
    setState(() {
      this.favPosts = posts;
    });
  }

  buildYourTab() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    if (favPosts == null) {
      return circularProgress();
    } else if (favPosts.isEmpty) {
      return postsIsEmpty1();
    } else {
      return CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.all(3),
            sliver: SliverGrid.count(
              mainAxisSpacing: 7,
              crossAxisSpacing: 7,
              childAspectRatio: (w / 2) / (h / 3),
              crossAxisCount: 2,
              children: favPosts,
            ),
          ),
        ],
      );
    }
  }

  // streamGpsTab() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream:
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return circularProgress();
  //       }
  //       List<Story> posts = snapshot.data.documents
  //           .map((doc) => Story.fromDocument(doc))
  //           .toList();

  //       return (posts.isEmpty)
  //           ? postsIsEmpty1()
  //           : CustomScrollView(
  //               slivers: <Widget>[
  //                 SliverPadding(
  //                   padding: EdgeInsets.all(3),
  //                   sliver: SliverGrid.count(
  //                     mainAxisSpacing: 7,
  //                     crossAxisSpacing: 7,
  //                     childAspectRatio: (210 / 310),
  //                     crossAxisCount: 2,
  //                     children: posts,
  //                   ),
  //                 ),
  //               ],
  //             );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfbb37474F),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Favorites",
              style: TextStyle(
                fontSize: 26.0,
                fontFamily: 'Pacifico',
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Icon(Icons.favorite)
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xfbbE3008C),
      ),
      body: RefreshIndicator(
        child: buildYourTab(),
        onRefresh: () => getYourData(),
      ),
    );
  }
}
