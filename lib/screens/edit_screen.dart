import 'package:flutter/material.dart';
import 'package:moor_ffi/database.dart';
import 'package:myownflashcard/db/database.dart';
import 'package:myownflashcard/main.dart';
import 'package:myownflashcard/screens/word_list_screen.dart';
import 'package:toast/toast.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;

  final Word word;

  EditScreen({@required this.status, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = "";

  bool _isQuestionEnabled;

  @override
  void initState() {
    super.initState();

    if (widget.status == EditStatus.ADD) {
      _isQuestionEnabled = true;
      _titleText = "新しい単語の追加";
      questionController.text = "";
      answerController.text = "";
    } else {
      _isQuestionEnabled = false;
      _titleText = "登録した単語の修正";
      questionController.text = widget.word.strQuestion;
      answerController.text = widget.word.strAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backWordListScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: "登録",
              onPressed: () => _onWordRegistered(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: Text(
                  "問題と答えを入力して、「登録」ボタンを押してください",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              //問題入力部分
              _questionInputPart(),
              SizedBox(
                height: 50.0,
              ),
              //答え入力部分
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            "問題",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ),
        ],
      ),
    );
  }

  Widget _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            "答え",
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          )
        ],
      ),
    );
  }

  Future<bool> _backWordListScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
    return Future.value(false); //trueのとき、popメソッド実行。 falseのとき、popメソッド未実行。
  }

  _onWordRegistered() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  //単語登録
  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      showToast("問題と答えの両方を入力しないと登録できません");
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("登録"),
              content: Text("登録してもいいですか？"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () async {
                    var word = Word(
                        strQuestion: questionController.text,
                        strAnswer: answerController.text);

                    try {
                      await myDatabase
                          .addWord(word); //登録文字列のクリアが実行されるまで待機するため非同期処理を実行
                      questionController.clear();
                      answerController.clear();
                      showToast("登録が完了しました");
                    } on SqliteException catch (e) {
                      showToast("重複した単語は登録できません");
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                  child: Text("はい"),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("いいえ"),
                ),
              ],
            ));
  }

  //登録済み単語更新
  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      showToast("問題と答えの両方を入力しないと登録できません");
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("${questionController.text}の変更"),
              content: Text("変更してもいいですか？"),
              actions: <Widget>[
                FlatButton(
                  child: Text("はい"),
                  onPressed: () async {
                    var word = Word(
                        strQuestion: questionController.text,
                        strAnswer: answerController.text,
                        isMemorized:
                            false); //再編集できるように、,暗記済みを示す「isMemorized」プロパティがnullにならないように、falseにする

                    try {
                      await myDatabase.updateWord(word);
                      Navigator.pop(context);
                      _backWordListScreen();
                      showToast("修正が完了しました");
                    } on SqliteException catch (e) {
                      Navigator.pop(context);
                      showToast("なんらかのエラーが出て登録できませんでした。 エラーコード：$e");
                    }
                  },
                ),
                FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("いいえ")),
              ],
            ));
  }

  showToast(String message) {
    FocusScope.of(context).unfocus();
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }
}
