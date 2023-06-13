import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


class Task {
  final int? id;
  final String name;
  final String description;
  final DateTime startTime;
  final int priority;
  
  Task({
    this.id,
    required this.name, 
    required this.description,
    required this.startTime,
    required this.priority
  });

  factory Task.fromMap(Map<String,dynamic> json) => Task(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    startTime: DateTime.fromMicrosecondsSinceEpoch(json['start_time']),
    priority: json['priority']
  );

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_time': startTime.microsecondsSinceEpoch,
      'priority': priority
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        priority INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Task>> getTasks() async {
    Database db = await instance.database;
    var tasks = await db.query('tasks', orderBy: 'start_time');
    List<Task> taskList = tasks.isNotEmpty
      ? tasks.map((task) => Task.fromMap(task)).toList()
      : [];
    return taskList;
  }

  Future<int> add(Task task) async {
    Database db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> update(Task task) async {
    Database db = await instance.database;
    return await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}