import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

showAlertDialog(BuildContext context, var title, var description) {
  // set up the buttons
  Widget remindButton = FlatButton(
    child: Text("Devam"),
    onPressed: () {
      navigatorKey.currentState.pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
    ),
    content:
    Text(description),
    actions: [
      remindButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


showAlertDialogWithAction(BuildContext context, var title, var description, Function func) {
  // set up the buttons
  Widget remindButton = FlatButton(
    child: Text("Devam"),
    onPressed: () {
      func();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
    ),
    content:
    Text(description),
    actions: [
      remindButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

getAlertDialog(var title, var description) {
  // set up the buttons
  Widget remindButton = FlatButton(
    child: Text("Devam"),
    onPressed: () {
      navigatorKey.currentState.pushNamed("/topics");

    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
    ),
    content:
    Text(description),
    actions: [
      remindButton,
    ],
  );


  return alert;

}