import 'package:flutter/material.dart';
import 'package:girlybook/widgets/custom_image.dart';
import 'package:girlybook/widgets/post.dart';
import 'package:girlybook/pages/post_screen.dart';

class PostTile extends StatelessWidget {
  final Post p1;

  PostTile(this.p1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('showing post');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostScreen(
                      postId: p1.postId,
                      userId: p1.ownerId,
                    )));
      },
      child: cachedNetworkImage(p1.mediaUrl),
    );
  }
}
