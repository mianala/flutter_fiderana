import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static late Database _database;
  static late DatabaseHelper _databaseHelper;
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper;
  }

  Future<Database> get database async {
    _database ??= await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    var db =
        await openDatabase(join(await getDatabasesPath(), 'fiderana_db.db'),
            onCreate: (db, version) {
      // todo: isn't needed anymore because songs already present
      return db.execute(
          'CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT, content TEXT, key TEXT, verses NUMBER, number NUMBER)');
    });
    return db;
  }

  Future<List<Song>> songs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('songs');

    return List.generate(maps.length, (i) {
      return Song(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        key: maps[i]['key'],
        verses: maps[i]['verses'],
        number: maps[i]['number'],
      );
    });
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    late List<Song> allSongs;
    DatabaseHelper._createInstance()
        .songs()
        .then((songs) => {allSongs = songs});
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: Center(
          child:
              ListView.builder(itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(allSongs[index].title),
              subtitle: Text(allSongs[index].key),
            );
          }),
        ),
      ),
    );
  }
}

class Song {
  final int id;
  final String number;
  final String content;
  final String title;
  final String key;
  final int verses;

  const Song({
    required this.id,
    required this.title,
    required this.content,
    required this.key,
    required this.verses,
    required this.number,
  });
}

Song findSong(int id, songList) => songList.firstWhere((song) => song.id == id);
