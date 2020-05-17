import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:systemreader9/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import './globals.dart';



class Document<T> {
  final Firestore _db = Firestore.instance;
  final String path; 
  DocumentReference ref;

  Document({ this.path }) {
    ref = _db.document(path);
  }

  Future<T> getData() {
    return ref.get().then((v) => Global.models[T](v.data) as T);
  }

  Stream<T> streamData() {
    return ref.snapshots().map((v) => Global.models[T](v.data) as T);
  }

  Future<void> upsert(Map data) {
    return ref.setData(Map<String, dynamic>.from(data), merge: true);
  }

}

class Collection<T> {
  final Firestore _db = Firestore.instance;
  final String path; 
  CollectionReference ref;
  Query queryRef;

  Collection({ this.path }) {
    ref = _db.collection(path);
    queryRef = _db.collection(path).orderBy('total', descending : true);
  }

  Future<List<T>> getData() async {
    var snapshots = await ref.getDocuments();
    return snapshots.documents.map((doc) => Global.models[T](doc.data) as T ).toList();
  }
  Future<List<T>> getDataOrderByTotal() async {
    var snapshots = await queryRef.getDocuments();
    return snapshots.documents.map((doc) => Global.models[T](doc.data) as T ).toList();
  }

  Stream<List<T>> streamData() {
    return ref.snapshots().map((list) => list.documents.map((doc) => Global.models[T](doc.data) as T) );
  }
  Stream<QuerySnapshot> snapshots() {
    return ref.snapshots();
  }
  /// Query a subcollection
  Stream<List<TopicFinished>> streamTopicFinished() {

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => TopicFinished.fromMap(doc.data)).toList());

  }
  Stream<List<Topic>> streamTopic() {

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => Topic.fromMap(doc.data)).toList());

  }
  Future add(var data) async {
    try {
      await ref.document(data.id).setData(data.toMap());
      return true;
    } catch (e) {
      return e.toString();
    }
  }

}

class UserData<T> {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collection;

  UserData({ this.collection });


  Stream<T> get documentStream {

    return Observable(_auth.onAuthStateChanged).switchMap((user) {
      if (user != null) {
          Document<T> doc = Document<T>(path: '$collection/${user.uid}'); 
          return doc.streamData();
      } else {
          return Observable<T>.just(null);
      }
    }); //.shareReplay(maxSize: 1).doOnData((d) => print('777 $d'));// as Stream<T>;
  }

  Future<T> getDocument() async {
    FirebaseUser user = await _auth.currentUser();

    if (user != null) {
      Document doc = Document<T>(path: '$collection/${user.uid}'); 
      return doc.getData();
    } else {
      return null;
    }

  }

  Future<void> upsert(Map data) async {
    FirebaseUser user = await _auth.currentUser();
    Document<T> ref = Document(path:  '$collection/${user.uid}');
    return ref.upsert(data);
  }

}
