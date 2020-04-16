import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:define9/main.dart';
import 'package:define9/services/globals.dart';

class LockProcess{
  static LockProcess _instance;

  static LockProcess getState() {
    if (_instance == null) {
      _instance = new LockProcess();
    }

    return _instance;
  }
  bool isLocked(lockReport, topic){
    return (lockReport != null &&
        lockReport.quizzes != null &&
        lockReport.quizzes[topic] != null &&
        lockReport.quizzes[topic]["wrongNumber"] >2);
  }
  /// Database write to update report doc when complete
  Future<void> updateUserReportForWrongQuestion(topic)  {
    Global.lockReportRef.upsert(
      ({

        'quizzes': {
          '${topic}': { 'wrongNumber': FieldValue.increment(1)}
        }
      }),
    );
   checkLock(topic);
  }
  checkLock(topic){
    Global.lockReportRef.getDocument().then((snapshot) {
      if(isLocked(snapshot, topic)){
        print(topic + " checklock");
        navigatorKey.currentState.pushNamed("/topics");

      }
    });
  }

}
