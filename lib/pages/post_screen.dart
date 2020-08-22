import 'package:flutter/material.dart';
import 'package:girlybook/pages/home.dart';
import 'package:girlybook/widgets/header.dart';
import 'package:girlybook/widgets/progress.dart';
import 'package:girlybook/widgets/post.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    print(userId);
    return FutureBuilder(
      future: postsRef
          .document(userId)
          .collection('userPost')
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(titletext: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
