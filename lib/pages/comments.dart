import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:girlybook/widgets/header.dart';
import 'package:girlybook/widgets/progress.dart';
import 'home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController c1 = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });
  f1() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> cl = [];
        snapshot.data.documents.forEach((doc) {
          cl.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: cl,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(titletext: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: f1(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: c1,
              decoration: InputDecoration(
                labelText: 'Write a comment',
              ),
            ),
            trailing: OutlineButton(
              onPressed: () {
                commentsRef.document(postId).collection('comments').add({
                  'username': currentUser.username,
                  'comment': c1.text,
                  'timestamp': DateTime.now(),
                  'avatarUrl': currentUser.photoUrl,
                  'userId': currentUser.id,
                });
                bool isNotPostOwner = postOwnerId != currentUser.id;
                if (isNotPostOwner) {
                  activityFeedRef
                      .document(postOwnerId)
                      .collection('feedItems')
                      .add({
                    'type': 'comment',
                    'commentData': c1.text,
                    'username': currentUser.username,
                    'userId': currentUser.id,
                    'userProfileImg': currentUser.photoUrl,
                    'postId': postId,
                    'mediaUrl': postMediaUrl,
                    'timestamp': timestamp,
                  });
                }

                c1.clear();
              },
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          )
        ],
      ),
    );
    ;
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
