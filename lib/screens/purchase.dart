import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:systemreader9/shared/tokenprocess.dart';
import 'package:systemreader9/services/globals.dart';
import 'package:systemreader9/services/models.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatefulWidget {
  createState() => MarketScreenState();
}

class MarketScreenState extends State<MarketScreen> {
  final String testID = 'token';
  Token token;
  /// Is the API available on the device
  bool _available = true;

  /// The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  /// Products for sale
  List<ProductDetails> _products = [];

  /// Past purchases
  List<PurchaseDetails> _purchases = [];

  /// Updates to purchases
  StreamSubscription _subscription;

  /// Consumable credits the user can buy
  int _credits = 0;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Initialize data
  void _initialize() async {
    // Check availability of In App Purchases
    _available = await _iap.isAvailable();

    if (_available) {
      await _getProducts();
      await _getPastPurchases();
    }

    _subscription = _iap.purchaseUpdatedStream.listen((data) => setState(() {
      _verifyPurchase(data[0]);
    }));
  }

  /// Get all products available for sale
  Future<void> _getProducts() async {
    Set<String> ids = Set.from([testID]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    setState(() {
      _products = response.productDetails;
    });
  }

  /// Gets past purchases
  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    if (response.error != null) {
      print('Error querying past purchases: ${response.error.message}');
      return;
    }
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }

    setState(() {
      _purchases = response.pastPurchases;
    });
  }

  /// Returns purchase of specific product ID
  PurchaseDetails _hasPurchased(String productID) {
    return _purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  /// Your own business logic to setup a consumable
  void _verifyPurchase(PurchaseDetails purchase) {

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      TokenProcess.getState().updateUserTokenPurchase();

    }
  }



  /// Purchase a product
  void _buyProduct(ProductDetails prod) {

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    // _iap.buyNonConsumable(purchaseParam: purchaseParam);

    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }



  makeConsumedTest(prod) async {
    // Mark consumed just after succesful purchase.
    PurchaseDetails pd = _hasPurchased(prod.id);
    var res = await _iap.consumePurchase(pd);
    await _getPastPurchases();
  }

  Future<List<ProductDetails>> getProductsAfterLoading() async {
    return _products;
  }

  @override
  Widget build(context) {
    return FutureBuilder<List<ProductDetails>>(
        future: getProductsAfterLoading(),
        builder: (context, AsyncSnapshot<List<ProductDetails>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.length > 0) {
            token = Provider.of<Token>(context);
            return Scaffold(
              appBar: AppBar(
                title: Text(_available ? 'Open for Business' : 'Not Available'),
              ),
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _getData(snapshot)),
              ),
            );
          } else {
            return new CircularProgressIndicator();
          }
        });
  }

  List<Widget> _getData(AsyncSnapshot snapshot) {
    ProductDetails prod = snapshot.data[0];
    return [
      // UI if already purchased
       if(token!=null)
         Text('📀 ${token.total ?? 0} Jeton', style: TextStyle(fontSize: 60))
       ,
      FlatButton(
        child: Text('Buy It'),
        color: Colors.green,
        onPressed: () => _buyProduct(prod),
      ),

      Text("("+ prod.price +")",
          style: TextStyle(color: Colors.greenAccent, fontSize: 18)),
    ];
  }
}
