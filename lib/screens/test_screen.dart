import 'package:flutter/material.dart';
import 'package:myownflashcard/db/database.dart';
import 'package:myownflashcard/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludeMemorizedWords;

  TestScreen({this.isIncludeMemorizedWords});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion;

  String _txtQuestion = "てすと"; //TODO

  String _txtAnswer = "こたえ";

  bool _isMemorized = false;

  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isCheckBoxVisible = false;
  bool _isFabVisible = false;

  List<Word> _testDataList;
  TestStatus _testStatus;

  int _index = 0; //出題番号
  Word _currentWord; //出題内容

  @override
  void initState() {
    super.initState();

    _getTestData();
  }

  void _getTestData() async {
    if (widget.isIncludeMemorizedWords) {
      _testDataList = await myDatabase.allWords;
    } else {
      _testDataList = await myDatabase.allWordsExcludedMemorized;
    }

    //ランダムに出題するために、配列をシャッフルする
    _testDataList.shuffle();
    print(_testDataList.toString());

    //画面の状態を設定
    _testStatus = TestStatus.BEFORE_START;

    //出題番号
    _index = 0;

    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;

      _numberOfQuestion = _testDataList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
//    var isInclude = widget.isIncludeMemorizedWords;
    return WillPopScope(
      onWillPop: () => _finishTestScreen(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("確認テスト"),
            centerTitle: true,
          ),
          floatingActionButton: _isFabVisible
              ? FloatingActionButton(
                  onPressed: () => _goNextStatus(), //次の問題ボタンを押したときの処理
                  child: Icon(Icons.skip_next),
                  tooltip: "次に進む",
                )
              : null,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    _numberOfQuestionPart(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _questionCardPart(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _answerCardPart(),
                    _isMemorizedCheckPart(),
                  ],
                ),
                _endMessage(),
              ],
            ),
          )),
    );
  }

  //TODO 残り問題数表示部分
  Widget _numberOfQuestionPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "残り問題数：",
          style: TextStyle(fontSize: 14.0),
        ),
        SizedBox(
          width: 30,
        ),
        Text(
          _numberOfQuestion.toString(),
          style: TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

  //TODO 問題カード表示部分
  Widget _questionCardPart() {
    if (_isQuestionCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset("assets/images/image_flash_question.png"),
          Text(
            _txtQuestion,
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  // 答えカード表示部分
  Widget _answerCardPart() {
    if (_isAnswerCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset("assets/images/image_flash_answer.png"),
          Text(
            _txtAnswer,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  // 暗記済みチェック部分
  Widget _isMemorizedCheckPart() {
    if (_isCheckBoxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: CheckboxListTile(
          title: Text(
            "暗記済みにする場合は、チェックを入れてください",
            style: TextStyle(fontSize: 12.0),
          ),
          value: _isMemorized,
          onChanged: (value) {
            setState(() {
              _isMemorized = value;
            });
          },
        ),
      );
    } else {
      return Container();
    }
    //チェックボックスがタイトル左側
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        Checkbox(
//          value: _isMemorized,
//          onChanged: (value) {
//            setState(() {
//              _isMemorized = value;
//            });
//          },
//        ),
//        Text(
//          "暗記済みにする場合は、チェックを入れてください",
//          style: TextStyle(fontSize: 12.0),
//        ),
//      ],
//    );
  }

  //テスト終了メッセージ
  Widget _endMessage() {
    if (_testStatus == TestStatus.FINISHED) {
      return Center(
        child: Text(
          "テスト終了",
          style: TextStyle(fontSize: 50.0),
        ),
      );
    } else {
      return Container();
    }
  }

  _goNextStatus() async {
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        _testStatus = TestStatus.SHOW_QUESTION;
        _shoQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        await _updateMemorizedFlag();
        if (_numberOfQuestion <= 0) {
          setState(() {
            _isFabVisible = false;
            _testStatus = TestStatus.FINISHED;
          });
        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _shoQuestion();
        }
        break;
      case TestStatus.FINISHED:
        break;
    }
  }

  void _shoQuestion() {
    _currentWord = _testDataList[_index];
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isCheckBoxVisible = false;
      _isFabVisible = true;
      _txtQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestion--;
    _index++;
  }

  void _showAnswer() {
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = true;
      _isCheckBoxVisible = true;
      _isFabVisible = true;
      _txtAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  Future<void> _updateMemorizedFlag() async {
    var updateWord = Word(
        strQuestion: _currentWord.strQuestion,
        strAnswer: _currentWord.strAnswer,
        isMemorized: _isMemorized); //「isMemorized」のステータスだけ更新
    await myDatabase.updateWord(updateWord);
    print(updateWord.toString());
  }

  Future<bool> _finishTestScreen() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("テスト終了"),
            content: Text("テストを終了してもいいですか？"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("はい"),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("いいえ"),
              )
            ],
          ),
        ) ??
        false; //戻り値が「true」の場合、「Navigator.pop」が呼ばれる。今回は、上記の「onPressed」内で必要な「Navigator.pop」が呼ばれているので、これ以上Widgetをpopする必要ないため「false」を返す。
  }
}
