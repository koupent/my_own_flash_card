import 'package:flutter/material.dart';
import 'package:myownflashcard/parts/button_with_icon.dart';
import 'package:myownflashcard/screens/test_screen.dart';

import 'word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isIncludeMemorizedWords = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: Image.asset("assets/images/image_title.png")),
            _titleText(),
            //横線
            Divider(
              height: 30.0,
              indent: 8.0,
              endIndent: 8.0,
              color: Colors.white,
            ),
            // 確認テストをするボタン
            ButtonWithIcon(
              onPressed: () => _startTestScreen(context), // 「確認テスト開始」ボタン押下時の処理
              icon: Icon(Icons.play_arrow),
              label: "確認テストをする",
              color: Colors.brown,
            ),
            SizedBox(
              height: 5.0,
            ),

            //ラジオボタン
//            _radioButtons(),
            //トグルボタン
            _switch(),
            SizedBox(
              height: 40.0,
            ),
            // 単語一覧を見るボタン
            ButtonWithIcon(
              onPressed: () => _startWordListScreen(context),
              // 「単語一覧表示」ボタン押下時の処理
              icon: Icon(Icons.list),
              label: ("単語一覧を見る"),
              color: Colors.grey,
            ),
            SizedBox(
              height: 60.0,
            ),
            Text(
              "powered by Telulu LCC 2019",
              style: TextStyle(fontFamily: "Montserrat"),
            ),
            SizedBox(
              height: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  _titleText() {
    return Column(
      children: <Widget>[
        Text(
          "私だけの単語帳",
          style: TextStyle(
            fontSize: 40.0,
          ),
        ),
        Text(
          "My Own FrashCard",
          style: TextStyle(fontSize: 24.0, fontFamily: "Montserrat"),
        ),
      ],
    );
  }

  Widget _radioButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: <Widget>[
          RadioListTile(
            value: false,
            groupValue: isIncludeMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を除外する",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          RadioListTile(
            value: true,
            groupValue: isIncludeMemorizedWords,
            onChanged: (value) => _onRadioSelected(value),
            title: Text(
              "暗記済みの単語を含む",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  //ラジオボタン
  _onRadioSelected(value) {
    setState(() {
      isIncludeMemorizedWords = value;
      print("$valueが選ばれたで～");
    });
  }

  //トグルボタン
  Widget _switch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SwitchListTile(
        title: Text("暗記済みの単語を含む"),
        value: isIncludeMemorizedWords,
        onChanged: (value) {
          setState(() {
            isIncludeMemorizedWords = value;
          });
        },
        secondary: Icon(Icons.sort),
      ),
    );
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }

  _startTestScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(
                  isIncludeMemorizedWords: isIncludeMemorizedWords,
                )));
  }
}
