import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:define9/services/globals.dart';

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
    return Global.tokenRef.upsert(
      ({'total': FieldValue.increment(9)}),
    );
  }

  Future<void> updateUserTokenConsume() {
    return Global.tokenRef.upsert(
      ({'total': FieldValue.increment(-1)}),
    );
  }

}
