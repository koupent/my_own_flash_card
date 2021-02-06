import 'package:flutter/material.dart';
import 'package:myownflashcard/db/database.dart';
import 'package:myownflashcard/main.dart';
import 'package:toast/toast.dart';

import 'edit_screen.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _wordList = List();

  @override
  void initState() {
    super.initState();
    _getAllWords(); //DBからリスト抽出
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("単語一覧"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            tooltip: "暗記済みの単語を下になるようにソート",
            onPressed: () => _sortWords(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewWord(), //単語追加
        child: Icon(Icons.add),
        tooltip: "新しい単語の登録",
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _wordListWidget(),
      ),
    );
  }

  _addNewWord() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => EditScreen(
                status: EditStatus.ADD,
              )),
    );
  }

  void _getAllWords() async {
    _wordList = await myDatabase.allWords;
    setState(() {});
  }

  Widget _wordListWidget() {
    return ListView.builder(
      itemCount: _wordList.length,
      itemBuilder: (context, position) => _wordItem(position),
    );
  }

  Widget _wordItem(int position) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: Colors.indigo,
      child: ListTile(
        title: Text(
          "${_wordList[position].strQuestion}",
        ),
        subtitle: Text(
          "${_wordList[position].strAnswer}",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
        trailing:
            _wordList[position].isMemorized ? Icon(Icons.check_circle) : null,
        onTap: () => _editWord(_wordList[position]),
        onLongPress: () => _deleteWord(_wordList[position]), //DB削除処理
      ),
    );
  }

  _deleteWord(Word selectedWord) async {
    //削除前にアラートを表示
    showDialog(
      context: context,
      barrierDismissible: false, //アラート表示領域以外の操作禁止
      builder: (BuildContext context) => AlertDialog(
        title: Text(selectedWord.strQuestion),
        content: Text("削除してもいいですか？"),
        actions: <Widget>[
          FlatButton(
            child: Text("はい"),
            onPressed: () async {
              await myDatabase.deleteWord(selectedWord);
              Toast.show("削除が完了しました", context);
              _getAllWords();
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("いいえ"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  _editWord(Word selectedWord) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditScreen(
                  status: EditStatus.EDIT,
                  word: selectedWord,
                )));
  }

  _sortWords() async {
    _wordList = await myDatabase.allWordsSorted;
    setState(() {});
  }
}
