import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaastav/User.dart';
import 'package:vaastav/create_story.dart';
import 'package:vaastav/gpstab.dart';
import 'package:vaastav/myFavourite.dart';
import 'package:vaastav/profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vaastav/trending.dart';
import 'package:vaastav/yourtab.dart';
import 'package:story_view/story_view.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:firebase_auth/firebase_auth.dart';

final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final StorageReference storageRef = FirebaseStorage.instance.ref();
DateTime timestamp = DateTime.now();
final contactRef = Firestore.instance.collection('phone');
final gpsRef = Firestore.instance.collection('gps');
final allViewsRef = Firestore.instance.collection('allViews');
final userGpsStoryRef = Firestore.instance.collection('UsersGps');
final userContactStoryRef = Firestore.instance.collection('UserContacts');
final storyRef = Firestore.instance.collection("userStory");
final myFavRef = Firestore.instance.collection("myFav");
final usersFavRef = Firestore.instance.collection("usersFav");
final storyController = StoryController();
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

User currentUser;
String postId = Uuid().v4();

class Home extends StatefulWidget {
  final User currentUser;

  Home({this.currentUser});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  TabController _tabController;
  TextEditingController locationController = TextEditingController();
  String gotGPS;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String currentUserId = currentUser?.id;
  String currentUserGPS = currentUser?.gps;

  submit() {
    return Timer(Duration(seconds: 0), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfilePage()));
    });
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

  submitFav() {
    return Timer(Duration(seconds: 0), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FavTab()));
    });
  }

  bool isAuth = false;

  customAppbar() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 25.0,
          ),
          onPressed: () => submit(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () => submitFav(),
          ),
        ],

        backgroundColor: Color(0xfbbE3008C),
        //  leading: Icon(Icons.ap),
        centerTitle: true,
        title: Text("Vaastav",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Pacifico',
              fontSize: 28.0,
              color: Colors.white,
            )),
        // centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          //  isScrollable: true,
          // labelStyle: TextStyle(
          //   fontSize: 30.0,
          //   fontWeight: FontWeight.bold,
          // ),
          labelColor: Colors.white,
          // labelPadding: EdgeInsets.symmetric(horizontal: 32.0),

          indicatorColor: Colors.white,
          indicatorWeight: 5.0,
          unselectedLabelColor: Colors.pink[900],
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.add_a_photo,
                size: 30.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person,
                size: 30.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.location_on,
                size: 30.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.whatshot,
                size: 30.0,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // physics: NeverScrollableScrollPhysics(),
        children: [
          CreateStory(),
          YoursTab(currentUser: currentUser),
          GPSTab(currentUser: currentUser),
          TrendingTab(currentUser: currentUser),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 1, length: 4);

    // // Detects When User Sign in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      //print();
    });
    // ReAuthenticate When User Opened App

    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    });
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
  }

  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => _launchURL(PLAY_STORE_URL),
            ),
            FlatButton(
              child: Text(btnLabelCancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  String PLAY_STORE_URL =
      "https://play.google.com/store/apps/details?id=com.sanjupoojari.vaastav";

  launchSnack8() {
    final snackBar = SnackBar(
      content: Text("Sign in Error!"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  getUserLocation() async {
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      //  String completeAddress = '${placemark.postalCode}';

      String formattedAddress = "${placemark.postalCode}";
      locationController.text = formattedAddress;
      final String gpsData = locationController.text;

      usersRef.document(currentUser.id).updateData({'gps': gpsData});
    } catch (e) {
      //  print(e);
    }
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFireStore();
      // await getUserLocation();
      if (await Permission.storage.request().isGranted &&
          await Permission.locationWhenInUse.request().isGranted) {
        setState(() {
          isAuth = true;
        });
      } else {
        allowStorageSnack();
        setState(() {
          isAuth = false;
        });
      }
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  allowStorageSnack() {
    final snackBar = SnackBar(
      content: Text("Please allow Permission to Enter."),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  createUserInFireStore() async {
    //1) check if user exists in users collection in database
    //(according to their id)

    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      //  String completeAddress = '${placemark.postalCode}';

      String formattedAddress = "${placemark.postalCode}";
      locationController.text = formattedAddress;
      final String gpsData = locationController.text;
      usersRef.document(user.id).setData({
        "id": user.id,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "timestamp": timestamp,
        // "contact": "",
        "gps": gpsData,
      });

      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  login() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    _auth
        .signInWithCredential(credential)
        .whenComplete(() => handleSignIn(googleSignInAccount));

    // final FirebaseUser user = authResult.user;

    // assert(!user.isAnonymous);
    // assert(await user.getIdToken() != null);

    // final FirebaseUser currentUser = await _auth.currentUser();
    // assert(user.uid == currentUser.uid);

    // return 'signInWithGoogle succeeded: $user';
  }

  logout() {
    googleSignIn.signOut();
  }

  // ignore: non_constant_identifier_names

  unAuthScreen() {
    return Scaffold(
      body: Container(
        // color: Colors.green[700],
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple,
              Colors.blueGrey,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Image(
            //   image: AssetImage("assets/images/tree.png"),
            //   height: 300.0,
            //   width: 300.0,
            // ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              "Vaastav",
              style: TextStyle(
                //letterSpacing: 4.0,
                fontSize: 65.0,
                color: Colors.white,
                fontFamily: 'Pacifico',
              ),
            ),
            Text(
              "Create Stories Daily !",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white70,
                // fontFamily: 'AmaticSC-Bold'
              ),
            ),
            SizedBox(
              height: 170.0,
            ),
            Container(
              //  alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(right: 10),
              child: Text(
                "to begin with Vaastav",
                style: TextStyle(color: Colors.white54, fontSize: 14.0),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 150.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/GoogleSign.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  Directory("/storage/emulated/0/Movies/Vaastav").create();

    return WillPopScope(
      child: isAuth ? customAppbar() : unAuthScreen(),
      onWillPop: () async => false,
    );
  }
}
