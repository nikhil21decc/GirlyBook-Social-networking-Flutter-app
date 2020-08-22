import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:girlybook/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:girlybook/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'home.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload(this.currentUser);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  File f;
  bool iu = false;
  String postId = Uuid().v4();

  Container f1() {
    return Container(
      color: Colors.green[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260,
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () {
                return showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('Create Post'),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text(
                              'Photo with Camera',
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              File f = await ImagePicker.pickImage(
                                source: ImageSource.camera,
                                maxHeight: 675,
                                maxWidth: 960,
                              );
                              setState(() {
                                this.f = f;
                              });
                            },
                          ),
                          SimpleDialogOption(
                            child: Text(
                              'Image from Gallery',
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              File f = await ImagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              setState(() {
                                this.f = f;
                              });
                            },
                          ),
                          SimpleDialogOption(
                            child: Text(
                              'Cancel',
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: FlatButton.icon(
                onPressed: () async {
                  print('log out');
                  await g1.signOut();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                label: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imagefile = Im.decodeImage(f.readAsBytesSync());
    final cmprsfile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imagefile, quality: 85));
    setState(() {
      f = cmprsfile;
    });
  }

  uploadImage(f) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(f);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) async {
    postsRef
        .document(widget.currentUser.id)
        .collection('userPost')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
    DocumentSnapshot pr = await postsRef
        .document(widget.currentUser.id)
        .collection('userPost')
        .document(postId)
        .get();

    QuerySnapshot fr = await followersRef
        .document(widget.currentUser.id)
        .collection('userFollowers')
        .getDocuments();

    for (var m2 in fr.documents) {
      print(m2.documentID.toString());
      timelineRef
          .document(m2.documentID.toString())
          .collection('timelinePosts')
          .document()
          .setData(pr.data);
    }
  }

  Scaffold f2() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              f = null;
            });
          },
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: iu
                ? null
                : () async {
                    print('pressed');
                    setState(() {
                      iu = true;
                    });
                    await compressImage();
                    String mediaUrl = await uploadImage(f);
                    createPostInFirestore(
                      mediaUrl: mediaUrl,
                      location: locationController.text,
                      description: captionController.text,
                    );
                    captionController.clear();
                    locationController.clear();
                    setState(() {
                      f = null;
                      iu = false;
                      postId = Uuid().v4();
                    });
                  },
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          iu ? linearProgress() : Text(''),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(f),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Write a caption',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Your Location!',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: () async {
                print('get location');
                Position p = await Geolocator()
                    .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                List<Placemark> p1 = await Geolocator()
                    .placemarkFromCoordinates(p.latitude, p.longitude);
                Placemark pm = p1[0];
                String address = '${pm.locality} , ${pm.country}';
                print('${pm.locality} , ${pm.country}');
                locationController.text = address;
              },
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return f == null ? f1() : f2();
  }
}
