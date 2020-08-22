import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:girlybook/pages/activity_feed.dart';
import 'package:girlybook/pages/comments.dart';
import 'package:girlybook/pages/home.dart';
import 'progress.dart';
import 'package:girlybook/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'custom_image.dart';
import 'dart:async';
import 'package:girlybook/pages/comments.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }
  int getLikeCount(likes) {
    if (likes == null) return 0;

    int count = 0;

    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });

    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map likes;
  int likeCount;
  bool isliked;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });
  likekardi() async {
    bool _isliked = likes[currentUserId] == true;
    if (_isliked) {
      postsRef
          .document(ownerId)
          .collection('userPost')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      QuerySnapshot tf = await timelineRef
          .document(currentUserId)
          .collection('timelinePosts')
          .where('postId', isEqualTo: postId)
          .getDocuments();

      for (var m in tf.documents) {
        timelineRef
            .document(currentUserId)
            .collection('timelinePosts')
            .document(m.documentID.toString())
            .updateData({'likes.$currentUserId': false});
      }

      rf();
      setState(() {
        likeCount -= 1;
        isliked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isliked) {
      postsRef
          .document(ownerId)
          .collection('userPost')
          .document(postId)
          .updateData({'likes.$currentUserId': true});

      QuerySnapshot tf = await timelineRef
          .document(currentUserId)
          .collection('timelinePosts')
          .where('postId', isEqualTo: postId)
          .getDocuments();

      for (var m in tf.documents) {
        timelineRef
            .document(currentUserId)
            .collection('timelinePosts')
            .document(m.documentID.toString())
            .updateData({'likes.$currentUserId': true});
      }

      af();
      setState(() {
        likeCount += 1;
        isliked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  af() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': mediaUrl,
        'timestamp': timestamp,
      });
    }
  }

  rf() {
    bool isNotPostOwner = currentUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  f1() {
    return FutureBuilder(
        future: userRef.document(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User u1 = User.fromDocument(snapshot.data);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(u1.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () {
                print('showing profile');
                showProfile(context, profileId: u1.id);
              },
              child: Text(
                u1.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(location),
            trailing: IconButton(
              onPressed: () {
                print('deleting post');
              },
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  f2() {
    return GestureDetector(
      onDoubleTap: () {
        print('liking post');
        likekardi();
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.white70,
                )
              : Text(''),
        ],
      ),
    );
  }

  f3() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
            ),
            GestureDetector(
              onTap: () {
                print('liking post');
                likekardi();
              },
              child: Icon(
                isliked ? Icons.favorite : Icons.favorite_border,
                size: 33,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
            ),
            GestureDetector(
              onTap: () {
                print('showing comments');
                return showComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                );
              },
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28,
                color: Colors.lightBlue,
              ),
            ),
          ],
        ),
        Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$likeCount likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$username',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isliked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        f1(),
        f2(),
        f3(),
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
