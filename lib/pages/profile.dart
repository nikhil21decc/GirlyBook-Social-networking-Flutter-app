import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:girlybook/pages/edit_profile.dart';
import 'package:girlybook/widgets/header.dart';
import 'home.dart';
import 'package:girlybook/widgets/progress.dart';
import 'package:girlybook/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:girlybook/widgets/post.dart';
import 'package:girlybook/widgets/post_tile.dart';
import 'package:flutter_svg/svg.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentUserId = currentUser?.id;
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  List<Post> lp = [];
  String po = 'grid';

  @override
  void initState() {
    super.initState();
    gp();
    checkIfFollowing();
    getfollowers();
    getfollowing();
  }

  getfollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();

    setState(() {
      followersCount = snapshot.documents.length;
    });
  }

  getfollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  gp() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot sn1 = await postsRef
        .document(widget.profileId)
        .collection('userPost')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = sn1.documents.length;
      print(postCount);
      lp = sn1.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column f2(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: function,
        child: Expanded(
          child: Container(
            width: 200,
            height: 27,
            child: Text(
              text,
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  f3() {
    //agar khud ki profile dekhh rahe h....
    bool myid = currentUserId == widget.profileId;

    if (myid) {
      return buildButton(
          text: 'Edit Profile',
          function: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditProfile(currentUserId: currentUserId)));
          });
    } else if (isFollowing) {
      return buildButton(
          text: 'Unfollow',
          function: () async {
            setState(() {
              isFollowing = false;
            });

            QuerySnapshot ds = await timelineRef
                .document(currentUserId)
                .collection('timelinePosts')
                .where('ownerId', isEqualTo: widget.profileId)
                .getDocuments();

            for (var m3 in ds.documents) {
              if (m3.exists) {
                m3.reference.delete();
              }
            }

            followersRef
                .document(widget.profileId)
                .collection('userFollowers')
                .document(currentUserId)
                .get()
                .then((doc) {
              if (doc.exists) {
                doc.reference.delete();
              }
            });

            followingRef
                .document(currentUserId)
                .collection('userFollowing')
                .document(widget.profileId)
                .get()
                .then((doc) {
              if (doc.exists) {
                doc.reference.delete();
              }
            });

            activityFeedRef
                .document(widget.profileId)
                .collection('feedItems')
                .document(currentUserId)
                .get()
                .then((doc) {
              if (doc.exists) {
                doc.reference.delete();
              }
            });
          });
    } else if (!isFollowing) {
      return buildButton(
          text: 'follow',
          function: () async {
            setState(() {
              isFollowing = true;
            });

            QuerySnapshot sp1 = await postsRef
                .document(widget.profileId)
                .collection('userPost')
                .getDocuments();

            for (var m2 in sp1.documents) {
              print(m2.data);
              timelineRef
                  .document(currentUserId)
                  .collection('timelinePosts')
                  .document()
                  .setData(m2.data);
            }

            followersRef
                .document(widget.profileId)
                .collection('userFollowers')
                .document(currentUserId)
                .setData({});

            followingRef
                .document(currentUserId)
                .collection('userFollowing')
                .document(widget.profileId)
                .setData({});

            activityFeedRef
                .document(widget.profileId)
                .collection('feedItems')
                .document(currentUserId)
                .setData({
              'type': 'follow',
              'ownerId': widget.profileId,
              'username': currentUser.username,
              'userId': currentUserId,
              'userProfileImg': currentUser.photoUrl,
              'timestamp': timestamp,
            });
          });
    }
  }

  FutureBuilder f1() {
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User u = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(u.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            f2('posts', postCount),
                            f2('followers', followersCount),
                            f2('following', followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            f3(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  u.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  u.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  u.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  f() {
    if (isLoading) {
      return circularProgress();
    }
    if (lp.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 200,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'No posts',
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (po == 'grid') {
      List<GridTile> g1 = [];
      lp.forEach((val) {
        g1.add(GridTile(child: PostTile(val)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: g1,
      );
    } else if (po == 'list') {
      return Column(
        children: lp,
      );
    }
  }

  ft() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () {
            setState(() {
              po = 'grid';
            });
          },
          icon: Icon(
            Icons.grid_on,
          ),
          color: po == 'grid' ? Colors.deepPurple : Colors.grey,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              po = 'list';
            });
          },
          icon: Icon(Icons.list),
          color: po == 'list' ? Colors.deepPurple : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(titletext: 'Profile'),
      body: ListView(
        children: <Widget>[
          f1(),
          Divider(),
          ft(),
          Divider(
            height: 0.0,
          ),
          f(),
        ],
      ),
    );
  }
}
