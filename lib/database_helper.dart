import 'dart:async';
import 'dart:io';
import 'song.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static Database? _database;
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database?> get database async {
    _database ??= await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "hira_fiderana.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "hira_fiderana.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    return await openDatabase(path, readOnly: true);
  }

  Future<List<Song>> songs() async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db!.query('songs');

    return List.generate(maps.length, (i) {
      var indexRow = maps[i];
      return Song(
        id: int.tryParse(indexRow["id"]) ?? 0,
        number: int.tryParse(indexRow["number"]) ?? 0,
        title: indexRow['title'],
        content: indexRow['content'],
        verses: int.tryParse(indexRow['verses']) ?? 0,
        key: indexRow['key'] ?? "",
      );
    });
  }
}
