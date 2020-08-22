import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:girlybook/pages/search.dart';
import 'package:girlybook/widgets/header.dart';
import 'package:girlybook/widgets/progress.dart';
import 'package:girlybook/models/user.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:girlybook/widgets/post.dart';
import 'search.dart';

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline(this.currentUser);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];
  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView(children: posts);
    }
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          userRef.orderBy('timestamp', descending: true).limit(15).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> ur = [];
        snapshot.data.documents.forEach((doc) {
          User usr = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == usr.id;
          final bool isFollowingUser = followingList.contains(usr.id);
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(usr);
            ur.add(userResult);
          }
        });
        return Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      color: Colors.deepOrange,
                      size: 35,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Follow Users",
                      style: TextStyle(
                        color: Colors.orange,
                        fontFamily: "Signatra",
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: ur,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(b2: true),
        body: RefreshIndicator(
          onRefresh: () {
            return getTimeline();
          },
          child: buildTimeline(),
        ));
  }
}
