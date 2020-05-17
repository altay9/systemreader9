import 'package:systemreader9/services/globals.dart';
import 'package:systemreader9/services/models.dart';
import 'package:flutter/material.dart';

class RankingScreen extends StatelessWidget {
  List<Token> ran = [];
  Widget _buildFriendListTile(BuildContext context, int index) {
    var ranking = ran[index];

    return new ListTile(
      onTap: () => _navigateToFriendDetails(),
      leading: new Hero(
        tag: index,
        child: new CircleAvatar(
          backgroundImage: new NetworkImage(ranking.photoUrl),
        ),
      ),
      title: new Text(ranking.displayName),
      subtitle: new Text("📀 " +ranking.total.toString()),
    );
  }

  void _navigateToFriendDetails() {

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Global.tokenCollectionRef.getDataOrderByTotal(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.hasData) {
          ran = snap.data;
          Widget content;

            content = new ListView.builder(
              itemCount: ran.length,
              itemBuilder: _buildFriendListTile,
            );


          return new Scaffold(
            appBar: new AppBar(title: new Text('En İyiler')),
            body: content,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
