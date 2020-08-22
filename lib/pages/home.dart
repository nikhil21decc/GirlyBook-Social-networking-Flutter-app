import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:girlybook/pages/activity_feed.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'timeline.dart';
import 'upload.dart';
import 'search.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_account.dart';
import 'package:girlybook/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

final GoogleSignIn g1 = GoogleSignIn();
final storageRef = FirebaseStorage.instance.ref();
final userRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final activityFeedRef = Firestore.instance.collection('feed');
final commentsRef = Firestore.instance.collection('comments');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();

User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool b1 = false;
  PageController p1;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    p1 = PageController(
      initialPage: 0,
    );
    g1.onCurrentUserChanged.listen((GoogleSignInAccount account) async {
      if (account != null) {
        print(account);
        await fcufs();
        setState(() {
          b1 = true;
        });
      } else {
        setState(() {
          b1 = false;
        });
      }
    }, onError: (err) {
      print('MY error1 $err');
    });
    g1.signInSilently(suppressErrors: false).then((account) async {
      if (account != null) {
        print(account);
        await fcufs();
        setState(() {
          b1 = true;
        });
      } else {
        setState(() {
          b1 = false;
        });
      }
    }).catchError((err) {
      print('MY error2 $err');
    });
  }

  fcufs() async {
    final GoogleSignInAccount u1 = g1.currentUser;
    DocumentSnapshot doc = await userRef.document(u1.id).get();
    if (!doc.exists) {
      // agar user exist nahi karta tho register it..
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      userRef.document(u1.id).setData({
        'id': u1.id,
        'username': username,
        'photoUrl': u1.photoUrl,
        'email': u1.email,
        'displayName': u1.displayName,
        'bio': '',
        'timestamp': timestamp,
      });
      doc = await userRef.document(u1.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    super.dispose();
    p1.dispose();
  }

  flogin() {
    g1.signIn();
  }

  Scaffold f1() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser),
          ActivityFeed(),
          Upload(currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: p1,
        onPageChanged: (int pageIndex) {
          setState(() {
            this.pageIndex = pageIndex;
          });
        },
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: (int pageIndex) {
          p1.animateToPage(
            pageIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.bounceInOut,
          );
        },
        activeColor: Colors.red[900],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 40,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
//    return RaisedButton(
//      child: Text('Logout'),
//      onPressed: () {
//        g1.signOut();
//      },
//    );
  }

  Scaffold f2() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.pink, Colors.deepPurple[800]]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'GirlyBook',
              style: TextStyle(
                fontSize: 90,
                fontFamily: "Signatra",
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () {
                  print('yes');
                  flogin();
                },
                child: Container(
                  width: 260,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/google_signin_button.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Made  ',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: "Signatra",
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                Text(
                  'In  ',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: "Signatra",
                    color: Colors.white,
                  ),
                ),
                Text(
                  'India  ',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: "Signatra",
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            Text(
              'developer: nikhil21decc@gmail.com',
              style: TextStyle(
                fontSize: 15,
                //  fontFamily: "Signatra",
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return b1 ? f1() : f2();
  }
}
