import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/services.dart';

class LoginScreen extends StatefulWidget {
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  AuthService auth = AuthService();

  @override
  void initState() {
    super.initState();
    auth.getUser.then(
      (user) {
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/topics');
          Navigator.pushReplacementNamed(context, '/topics');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Image(
                      image: new AssetImage("assets/logo.png")),
                ]),
            Text(
              'Hoşgeldiniz!',
              style: Theme.of(context).textTheme.headline,
              textAlign: TextAlign.center,
            ),
            Text('Başlamak için giriş yapınız.'),
            LoginButton(
              text: 'GOOGLE İLE GİRİŞ',
              icon: FontAwesomeIcons.google,
              color: Colors.black26,
              loginMethod: auth.googleSignIn,
            )
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  const LoginButton(
      {Key key, this.text, this.icon, this.color, this.loginMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FlatButton.icon(
        padding: EdgeInsets.all(30),
        icon: Icon(icon, color: Colors.white),
        color: color,
        onPressed: () async {
          var user = await loginMethod();
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/topics');
          }
        },
        label: Expanded(
          child: Text('$text', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
