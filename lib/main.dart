import 'package:flutter/material.dart';
import 'package:myownflashcard/db/database.dart';

import 'screens/home_screen.dart';

MyDatabase myDatabase;

void main() {
  myDatabase = MyDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "私だけの単語帳",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, fontFamily: "Lanobe"),
      home: HomeScreen(),
    );
  }
}
