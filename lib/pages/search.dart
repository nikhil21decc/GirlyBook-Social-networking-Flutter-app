import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:girlybook/pages/activity_feed.dart';
import 'home.dart';
import 'package:girlybook/widgets/progress.dart';
import 'package:girlybook/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController t1 = TextEditingController();
  Future<QuerySnapshot> ans;
  AppBar f1() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: t1,
        decoration: InputDecoration(
          hintText: 'Search for users..',
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            color: Colors.grey,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.purple,
            ),
            onPressed: () {
              t1.clear();
              print('cleared');
            },
          ),
        ),
        onFieldSubmitted: (String value) {
          Future<QuerySnapshot> u2 = userRef
              .where('displayName', isGreaterThanOrEqualTo: value)
              .getDocuments();
          setState(() {
            ans = u2;
          });
        },
      ),
    );
  }

  Container f2() {
    final Orientation o1 = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: o1 == Orientation.portrait ? 300 : 200,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60,
              ),
            )
          ],
        ),
      ),
    );
  }

  f3() {
    return FutureBuilder(
      future: ans,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> l1 = [];
        snapshot.data.documents.forEach((doc) {
          User u = User.fromDocument(doc);
          print(u.username);
          UserResult res = UserResult(u);
          l1.add(res);
        });
        return ListView(
          children: l1,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      appBar: f1(),
      body: ans == null ? f2() : f3(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User us;

  UserResult(this.us);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[200],
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              showProfile(context, profileId: us.id);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(us.photoUrl),
              ),
              title: Text(
                us.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                us.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
