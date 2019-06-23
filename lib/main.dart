import 'package:flutter/material.dart';
import 'appNavBar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MaterialApp(
      title: 'Sikh Games of New Jersey',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    _firebaseMessaging.configure(
      onLaunch: (Map<String,dynamic> msg){
        print("onLaunch called");
      },
      onMessage: (Map<String,dynamic> msg){
        print("onMessage called");
      },
      onResume: (Map<String,dynamic> msg){
        print("onResume called");
      }
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        alert: true,
        badge: true
      )
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting){
      print("iOS settings registered");
    });
    _firebaseMessaging.getToken().then((token) {
      update(token);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppNavBar();
  }

  void update(String token) {
    print(token);
  }
}
