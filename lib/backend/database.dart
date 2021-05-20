import 'dart:io';
import 'dart:async';

import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class localDB {
  //region DB initial functions
  localDB._();

  static final localDB db = localDB._();
  Database _database;

  //конфигурация базы данных (включение foreign keys)
  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  //интерфейс базы данных. Все запросы надо делать именно через newDBI
  Future <Database> get newDB async {
    if (_database != null) return _database;
    _database = await InitDatabase();
    return _database;
  }

  //метод инициализации бд, открытия или создания - опционально
  InitDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "profiles.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          String _script = await rootBundle.loadString(
              "assets/createTable.sql"); // загружаем скрипт из файла
          List<String> _slashedScript = [];
          while (_script.indexOf(';') > 0) {
            int _index = _script.indexOf(';');
            _slashedScript.add(_script.substring(0, _index + 1));
            _script = _script.substring(_index + 1);
          } // делим скрипт на несколько разных запросов по знаку :
          for (String el in _slashedScript) {
            await db.execute(el); //создаем таблицу по заданному скрипту
          }
          debugPrint("Tables created successfully");
        },
        onConfigure: _onConfigure
    );
  }
  //endregion
  //функция для получения метки времени, в UTC. Используется везде, где нужен timestamp (ft_change, ft_canceled, ft_done и т.д.)
  String timeStamp() {
    return DateTime.now().toUtc().toString();
  }

  Future<bool> accountExists({email, hashPass}) async{
    Database db = await newDB;
    List data = await db.rawQuery("SELECT PK_ID FROM T_ACCOUNT WHERE PV_EMAIL = ? AND PV_PSWD = ?", [email, hashPass]);
    if (data.length != 0){
      accountGuid = data[0]["PK_ID"];
      return true;
    }
    return false;
  }
  Future<bool> hasSecret({acc_id})async{
    Database db = await newDB;
    List data = await db.rawQuery("SELECT V_SECRET FROM T_ACCOUNT WHERE PK_ID = ?", [acc_id]);
    if (data.length != 0){
      if (data[0]["V_SECRET"].toString().length > 0 && data[0]["V_SECRET"].toString().toLowerCase() != 'null')
        return true;
      return false;
    }
    else{
      exit(1);
    }
  }
}