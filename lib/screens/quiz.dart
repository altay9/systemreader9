import 'package:define9/main.dart';
import 'package:define9/shared/finishedprocess.dart';
import 'package:define9/shared/lockprocess.dart';
import 'package:define9/shared/show_alert.dart';
import 'package:define9/shared/tokenprocess.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../services/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Shared Data
class QuizState with ChangeNotifier {
  double _progress = 0;
  Option _selected;

  final PageController controller = PageController();

  get progress => _progress;
  get selected => _selected;

  set progress(double newValue) {
    _progress = newValue;
    notifyListeners();
  }

  set selected(Option newValue) {
    _selected = newValue;
    notifyListeners();
  }

  void nextPage() async {
    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}

class QuizScreen extends StatelessWidget {
  QuizScreen({this.quizId});
  final String quizId;

  @override
  Widget build(BuildContext context) {


    return ChangeNotifierProvider(
      builder: (_) => QuizState(),
      child: FutureBuilder(
        future: Document<Quiz>(path: 'quizzes/$quizId').getData(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          var state = Provider.of<QuizState>(context);

          if (!snap.hasData || snap.hasError) {
            return LoadingScreen();
          } else {
            Quiz quiz = snap.data;
            return Scaffold(
              appBar: AppBar(
                title: AnimatedProgressbar(value: state.progress),
                leading: IconButton(
                  icon: Icon(FontAwesomeIcons.times),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                controller: state.controller,
                onPageChanged: (int idx) =>
                state.progress = (idx / (quiz.questions.length + 1)),
                itemBuilder: (BuildContext context, int idx) {
                  if (idx == 0) {
                    return StartPage(quiz: quiz);
                  } else if (idx == quiz.questions.length + 1) {
                    return CongratsPage(quiz: quiz);
                  } else {
                    return QuestionPage(question: quiz.questions[idx - 1], quiz: quiz);
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}
class StartPage extends StatelessWidget {
  final Quiz quiz;
  final PageController controller;
  StartPage({this.quiz, this.controller});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(quiz.title, style: Theme.of(context).textTheme.headline),
          Divider(),
          Expanded(child: Text(quiz.description)),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                onPressed: state.nextPage,
                label: false ? Text('Locked') : Text('Start Quiz!'),
                icon: Icon(Icons.poll),
                color: Colors.green,
              )
            ],
          )
        ],
      ),
    );




  }
}

class CongratsPage extends StatelessWidget {
  final Quiz quiz;
  CongratsPage({this.quiz});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Congrats! You completed the ${quiz.title} quiz',
            textAlign: TextAlign.center,
          ),
          Divider(),
          Image.asset('assets/congrats.gif'),
          Divider(),
          FlatButton.icon(
            color: Colors.green,
            icon: Icon(FontAwesomeIcons.check),
            label: Text(' Mark Complete!'),
            onPressed: () {
              _updateUserReport(quiz);
              markTopicFinished(quiz).then((String username) {

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/topics',
                      (route) => false,
                );

                  showAlertDialog( context, "💎 Defineyi buldun!"
                      , "Define avcısı " + username + " defineyi buldun! Tebrikler!");


              });


            },
          )
        ],
      ),
    );
  }
  redirect(BuildContext context){

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/topics',
          (route) => false,
    );
  }
  Future<String>  markTopicFinished(Quiz quiz) async{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    TopicFinished topicFinished= new TopicFinished.withParams(quiz.topic, user.displayName, user.uid);

    Global.topicFinishedRef.add(topicFinished);
    return topicFinished.user;
  }
  /// Database write to update report doc when complete
  Future<void> _updateUserReport(Quiz quiz) {
    return Global.reportRef.upsert(
      ({
        'total': FieldValue.increment(1),
        'topics': {
          '${quiz.topic}': FieldValue.arrayUnion([quiz.id])
        }
      }),
    );
  }
}


class QuestionPage extends StatelessWidget {
  final Question question;
  final Quiz quiz;
  QuestionPage({this.question, this.quiz});
  Token token;
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);
    token = Provider.of<Token>(context);
    List<TopicFinished> topicFinished =  Provider.of<List<TopicFinished>>(context);
    TopicFinished entry= FinishedProcess.getState().getFinishEntry(topicFinished, quiz.topic);
    if(entry!=null)
    {
     return  getAlertDialog(  "💎 Define bulundu!", "Define avcısı " + entry.user + " defineyi buldu! Tebrikler!");
    }
    LockReport lockReport =  Provider.of<LockReport>(context);
    if(LockProcess.getState().isLocked(lockReport, quiz.topic))
    {
      return  getAlertDialog( "🔒 Kilitli","Bu bulmaca 3 adet yanlış cevap verdiğiniz için kitlenmiştir." );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(question.text),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: question.options.map((opt) {
              return Container(
                height: 90,
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.black26,
                child: InkWell(
                  onTap: () {
                    state.selected = opt;
                    _bottomSheet(context, opt);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                            state.selected == opt
                                ? FontAwesomeIcons.checkCircle
                                : FontAwesomeIcons.circle,
                            size: 30),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Text(
                              opt.value,
                              style: Theme.of(context).textTheme.body2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }



  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, Option opt) {
    bool correct = opt.correct;

    var state = Provider.of<QuizState>(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(correct ? '🎉 Doğru!' : '😞 Yanlış...'),
              Text(correct ? '' :'${token.total-1 ?? 0} jetonunuz kaldı.'),


              Text(
                opt.detail,
                style: TextStyle(fontSize: 18, color: Colors.white54),
              ),
              FlatButton(
                color: correct ? Colors.green : Colors.red,
                child: Text(
                  correct ? 'Devam!' : 'Yeniden deneyin',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (correct) {
                    state.nextPage();
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
    if(!correct){
      TokenProcess.getState().updateUserTokenConsume();
      LockProcess.getState().updateUserReportForWrongQuestion(quiz.topic);

    }
  }

}
