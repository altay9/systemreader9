import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:define9/main.dart';
import 'package:define9/services/globals.dart';

class FinishedProcess{
  static FinishedProcess _instance;

  static FinishedProcess getState() {
    if (_instance == null) {
      _instance = new FinishedProcess();
    }

    return _instance;
  }

  bool isFinished(topicFinished, topic){
    return (getFinishEntry(topicFinished, topic)!= null);
  }
  getFinishEntry(topicFinished, topic){
  var entry;
  if(topicFinished != null){
      entry = topicFinished.firstWhere((topicExist) => topicExist.id == topic, orElse: () => null);

    }
     return entry;
  }
  /// Database write to update quiz information if it is finished
  Future<void> updateTopicFinished(topic)  {
    Global.lockReportRef.upsert(
      ({


          '${topic}': { 'title': topic}

      }),
    );
   checkLock(topic);
  }
  checkLock(topic){
    Global.lockReportRef.getDocument().then((snapshot) {
      if(isFinished(snapshot, topic)){

        navigatorKey.currentState.pushNamed("/topics");

      }
    });
  }

}
