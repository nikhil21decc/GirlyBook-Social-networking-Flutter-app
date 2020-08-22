import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar header({bool b2 = false, String titletext, bool b3 = false}) {
  return AppBar(
    automaticallyImplyLeading: b3 ? false : true,
    title: Text(
      b2 ? "GirlyBook" : titletext,
      style: TextStyle(
        color: Colors.white,
        fontFamily: b2 ? "Signatra" : "",
        fontSize: b2 ? 45 : 25,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.pink,
  );
}
