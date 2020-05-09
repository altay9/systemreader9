import 'services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


/// Static global state. Immutable services that do not care about build context. 
class Global {
  // App Data
  static final String title = 'Define9';

  // Services
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

    // Data Models
  static final Map models = {
    Topic: (data) => Topic.fromMap(data),
    TopicFinished: (data) => TopicFinished.fromMap(data),
    Quiz: (data) => Quiz.fromMap(data),
    Report: (data) => Report.fromMap(data),
    Token: (data) => Token.fromMap(data),
    LockReport: (data) => LockReport.fromMap(data),

  };

  // Firestore References for Writes
  static final Collection<TopicFinished> topicFinishedRef = Collection<TopicFinished>(path: 'topicFinished');
  static final Collection<Topic> topicsRef = Collection<Topic>(path: 'topics');
  static final UserData<Report> reportRef = UserData<Report>(collection: 'reports');
  static final UserData<LockReport> lockReportRef = UserData<LockReport>(collection: 'lockReports');
  static final UserData<Token> tokenRef = UserData<Token>(collection: 'tokens');
  static final Collection<Token> tokenCollectionRef = Collection<Token>(path: 'tokens');
}
