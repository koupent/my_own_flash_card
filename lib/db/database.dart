import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Words extends Table {
  TextColumn get strQuestion => text()();

  TextColumn get strAnswer => text()();

  BoolColumn get isMemorized =>
      boolean().withDefault(Constant(false))(); //初期値設定

  @override
  // implement primaryKey
  Set<Column> get primaryKey => {strQuestion};
}

//Moorの公式リファレンスからコピペ
LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'words.db')); //データベース名に書き換え
    return VmDatabase(file);
  });
}

@UseMoor(tables: [Words])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; //スキーマバージョン設定

  //統合処理
  MigrationStrategy get migration =>
      MigrationStrategy(//「migration」プロパティにアクセス ⇒ 「MigrationStrategy」コンストラクタを作成
          onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          //スキーマバージョンが変更したときの処理
          await m.addColumn(words, words.isMemorized);
        }
      });

  //登録
  Future addWord(Word word) => into(words).insert(word);

  //抽出
  Future<List<Word>> get allWords => select(words).get();

  //抽出(暗記済みの単語除外)
  Future<List<Word>> get allWordsExcludedMemorized =>
      (select(words)..where((tbl) => tbl.isMemorized.equals(false))).get();

  // 抽出(暗記済みが下になるようにソート)
  Future<List<Word>> get allWordsSorted => (select(words)
        ..orderBy([
          (table) => OrderingTerm(
              //「OrderingMode」で昇順(asc)か降順(dsc)を選択。初期値は、[asc]
              expression: table.isMemorized,
              mode: OrderingMode.asc)
        ]))
      .get();

  //更新
  Future updateWord(Word word) => update(words).replace(word);

  //削除
  Future deleteWord(Word word) =>
      (delete(words)..where((tbl) => tbl.strQuestion.equals(word.strQuestion)))
          .go();
}
