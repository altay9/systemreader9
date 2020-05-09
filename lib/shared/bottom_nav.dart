import 'package:define9/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
final MessageHandler messageHandler = new MessageHandler();
class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    messageHandler.initState(context);
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.graduationCap, size: 20),
            title: Text('Topics')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bolt, size: 20),
            title: Text('About')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userCircle, size: 20),
            title: Text('Profile')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.book, size: 20),
            title: Text('Öyküleri Oku')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.coins, size: 20),
            title: Text('Jeton')),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gem, size: 20),
            title: Text('En iyiler')),
      ].toList(),
      fixedColor: Colors.deepPurple[200],
      onTap: (int idx) {
        switch (idx) {
          case 0:
            // do nuttin
            break;
          case 1:
            Navigator.pushNamed(context, '/about');
            break;
          case 2:
            Navigator.pushNamed(context, '/profile');
            break;
          case 3:
            Navigator.pushNamed(context, '/read');
            break;
          case 4:
            Navigator.pushNamed(context, '/purchase');
            break;
          case 5:
            Navigator.pushNamed(context, '/ranking');
            break;
        }
      },
    );
  }
}