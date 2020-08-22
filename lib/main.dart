import 'package:flutter/material.dart';
import 'package:girlybook/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firestore.instance.settings().then((_) {
    print('enabling timestamps\n');
  }, onError: (_) {
    print('error enabling timestamps\n');
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      title: 'GirlyBook',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
