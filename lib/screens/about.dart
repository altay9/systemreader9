import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('hakkında'), backgroundColor: Colors.blue),

      body: Center(child: Text('Define avı'),),
    );
  }
}