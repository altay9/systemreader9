import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';


class MessageHandler   {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;


  void initState(BuildContext context) {

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken(context);
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken(context);
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
    /*

        final snackbar = SnackBar(
         content: Text(message['notification']['title']),
        action: SnackBarAction(
         label: 'Go',
            onPressed: () => null,
          ),
          );

       Scaffold.of(context).showSnackBar(snackbar);
       */


        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );

  }


  void disposeNotifications() {
    if (iosSubscription != null) iosSubscription.cancel();

  }


  /// Get the token, save it to the database for current user
  _saveDeviceToken(BuildContext context) async {
    // Get the current user
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    if (user != null) {
      String uid = user.uid;
      // FirebaseUser user = await _auth.currentUser();

      // Get the token for this device
      String fcmToken = await _fcm.getToken();

      // Save it to Firestore
      if (fcmToken != null) {
        var tokens = _db
            .collection('users')
            .document(uid)
            .collection('tokens')
            .document(fcmToken);

        await tokens.setData({
          'token': fcmToken,
          'createdAt': FieldValue.serverTimestamp(), // optional
          'platform': Platform.operatingSystem // optional
        });
      }
    }

  }

  /// Subscribe the user to a topic
  _subscribeToTopic() async {
    // Subscribe the user to a topic
    _fcm.subscribeToTopic('puppies');
  }
}