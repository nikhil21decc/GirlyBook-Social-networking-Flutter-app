import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:girlybook/widgets/header.dart';
import 'dart:async';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formkey = GlobalKey<FormState>();
  final _skey = GlobalKey<ScaffoldState>();
  String username;
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _skey,
      appBar: header(titletext: 'Set up your Profile', b3: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text(
                      'Create UserName',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formkey,
                    autovalidate: true,
                    child: TextFormField(
                      validator: (value) {
                        if (value.trim().length < 3 || value.isEmpty) {
                          return 'Username too short';
                        } else if (value.trim().length > 10) {
                          return 'Username too long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        username = value;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'UserName',
                        labelStyle: TextStyle(fontSize: 15),
                        hintText: 'Enter Username',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_formkey.currentState.validate()) {
                _formkey.currentState.save();
                SnackBar s1 = SnackBar(content: Text('Welcome $username!'));
                _skey.currentState.showSnackBar(s1);
                Timer(Duration(seconds: 2), () {
                  Navigator.pop(context, username);
                });
              }
            },
            child: Expanded(
              child: Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
