import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentry/sentry.dart';
import 'package:systemreader9/main.dart';
import 'package:systemreader9/services/globals.dart';
import 'package:systemreader9/shared/show_alert.dart';

class LogProcess {
  static LogProcess _instance;

  static LogProcess getState() {
    if (_instance == null) {
      _instance = new LogProcess();
    }

    return _instance;
  }

  final SentryClient _sentry = SentryClient(dsn: "https://ff39982924d24619b5467a08c90efd79@o394178.ingest.sentry.io/5243993");

  bool get isInDebugMode {
    // Assume you're in production mode.
    bool inDebugMode = false;

    // Assert expressions are only evaluated during development. They are ignored
    // in production. Therefore, this code only sets `inDebugMode` to true
    // in a development environment.
   assert(inDebugMode = true);

    return inDebugMode;
  }
  Future<void> reportError(dynamic error, dynamic stackTrace) async {
    // Print the exception to the console.
    print('Caught error: $error');
    if (isInDebugMode) {
      // Print the full stacktrace in debug mode.
      print(stackTrace);
    } else {
      // Send the Exception and Stacktrace to Sentry in Production mode.
      _sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }
}
