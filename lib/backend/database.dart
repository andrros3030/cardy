import 'dart:io';
import 'dart:async';


import 'package:card_app_bsk/backend/hiveStorage.dart';
import 'package:uuid/uuid.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class localDB {
  Uuid uuid = Uuid();
  String guid(){
    return uuid.v1();
  }
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

  Future<bool> accountExistsLocal({@required email, hashPass}) async{
    Database db = await newDB;
    List _data;
    if (hashPass == null) {
      _data = await db.rawQuery(
          "SELECT PK_ID FROM T_ACCOUNT WHERE PV_EMAIL = ?", [email]);
      if (_data.length != 0){
        return true;
      }
      return false;
    }
    else
      _data = await db.rawQuery("SELECT PK_ID FROM T_ACCOUNT WHERE PV_EMAIL = ? AND PV_PSWD = ?", [email, hashPass]);
    if (_data.length != 0){
      accountGuid = _data[0]["PK_ID"];
      return true;
    }
    return false;
  }
  Future<bool> emailIsTakenGlobal({@required email})async{
    await Future.delayed(const Duration(seconds: 2), (){});  //TODO: здесь вызываем глобальную базу для проверки, есть ли аккаунт с такой почтой
    if (false){
      uncheckedEmailWhileRegister = false;
    }
    return false;
  }
  Future<bool> hasSecret({@required acc_id})async{
    Database db = await newDB;
    List _data = await db.rawQuery("SELECT V_SECRET FROM T_ACCOUNT WHERE PK_ID = ?", [acc_id]);
    if (_data.length != 0){
      if (_data[0]["V_SECRET"].toString().length > 0 && _data[0]["V_SECRET"].toString().toLowerCase() != 'null')
        return true;
      return false;
    }
    else{
      exit(1);
    }
  }
  Future<List> getUserCardsNCategories({@required acc_id})async{ //на выходе д.б. [{ctgID: "", ctgName: "", ctgOrder: "", ctgImage: "", ctgCards: [{cad:"cardID", lnkID: "", cname: "". corder: "", ...}, ... ]}, ..., {ctgID: "unsorted", ctgCards: [...]}]
    Database db = await newDB;
    List _data = await db.rawQuery('SELECT '
        'access.PI_PRIORITY as PRIORITY, '
        'ctg.PK_ID as ctgID, '
        'ctg.PV_NAME as ctgName, '
        'ctg.PI_ORDER as ctgORDER, '
        'ctg.V_PICTURE as ctgImage'
        'lnk.PK_ID as lnkID, '
        'crd.PK_ID as CAD, '
        'crd.PV_NAME as CNAME, '
        'crd.PI_ORDER as CORDER '    //TODO: остальные данные карты
        'from T_CARD crd LEFT join '
        'T_LINK lnk on crd.PK_ID = lnk.FK_CARD LEFT JOIN '
        'T_CATEGORY ctg on lnk.FK_CATEGORY = ctg.pk_id JOIN '
        'T_ACCESS access on crd.PK_ID = access.FK_CARD JOIN '
        'T_ACCOUNT acc ON access.FK_ACCOUNT = acc.PK_ID '
        "WHERE acc.PK_ID = ? AND acc.IL_DEL = 0 AND crd.IL_DEL = 0 AND (lnk.IL_DEL = 0 or lnk.IL_DEL is NULL)AND (ctg.IL_DEL = 0 or ctg.il_del is NULL) AND access.IL_DEL = 0 "
        "order BY ctg.pi_order asc", [acc_id]);
    //TODO: привести данные к виду, который должна возвращать функция
  }
  Future<String> createNewUser({@required String email, @required String hash_pass}) async {
    Database db = await newDB;
    String _id = guid();
    await db.rawInsert("INSERT INTO T_ACCOUNT(PK_ID, PV_EMAIL, PV_PSWD, PT_REG, IV_USER, IT_CHANGE) VALUES(?, ?, ?, ?, ?, ?)", [_id.toLowerCase(), email.toLowerCase(), hash_pass.toLowerCase(), timeStamp(), 'application', timeStamp()]);
    if (uncheckedEmailWhileRegister)
      saveBadEmail(email);
    else{
      //TODO: send new account to global database
    }
    saveCreditionals(email: email, password: hash_pass);
    return _id;
  }
}