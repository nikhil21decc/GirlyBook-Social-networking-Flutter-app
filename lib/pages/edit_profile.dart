import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:girlybook/pages/home.dart';
import 'package:girlybook/models/user.dart';
import 'package:girlybook/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isLoading = false;
  User user;
  bool _bioValid = true;
  bool _diplayNameValid = true;
  final _skey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column bf1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Display Name',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayController,
          decoration: InputDecoration(
            hintText: 'Update DisplayName',
            errorText: _diplayNameValid ? null : 'Display Name too short',
          ),
        ),
      ],
    );
  }

  Column bf2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Bio',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Update Bio',
            errorText: _bioValid ? null : 'Bio too long',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _skey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.done,
              size: 30,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            bf1(),
                            bf2(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          print('update');
                          setState(() {
                            displayController.text.trim().length < 3 ||
                                    displayController.text.isEmpty
                                ? _diplayNameValid = false
                                : _diplayNameValid = true;
                            bioController.text.trim().length > 100
                                ? _bioValid = false
                                : _bioValid = true;
                          });
                          if (_diplayNameValid && _bioValid) {
                            userRef.document(widget.currentUserId).updateData({
                              'displayName': displayController.text,
                              'bio': bioController.text,
                            });
                            SnackBar snackbar = SnackBar(
                              content: Text('Profile Updated!'),
                            );
                            _skey.currentState.showSnackBar(snackbar);
                          }
                        },
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        color: Colors.deepOrange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
