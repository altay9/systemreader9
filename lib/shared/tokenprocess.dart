import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:define9/main.dart';
import 'package:define9/services/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class TokenProcess{
  static TokenProcess _instance;

  static TokenProcess getState() {
    if (_instance == null) {
      _instance = new TokenProcess();
    }

    return _instance;
  }
  /// Database write to update token after purchase
  Future<void> updateUserTokenPurchase() {

    FirebaseUser user = Provider.of<FirebaseUser>(navigatorKey.currentContext);
    return Global.tokenRef.upsert(
      ({'uid': user.uid,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'total': FieldValue.increment(9)
      }),
    );
  }

  Future<void> updateUserTokenConsume() {
    return Global.tokenRef.upsert(
      ({'total': FieldValue.increment(-1)}),
    );
  }

}
