import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'main.i18n.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: I18n(
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text('Welcome to my App'.i18n),
            ),
            backgroundColor: Colors.teal,
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Locale: ${I18n.locale}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                FlatButton(
                  onPressed: () {
                    print('pressed');
                    return I18n.of(context).locale =
                        (I18n.localeStr == "hi_in") ? null : Locale("hi", "IN");
                  },
                  color: Colors.teal,
                  child: Text(
                    'hello'.i18n,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
