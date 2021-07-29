import 'dart:convert';
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

bool loadingCardsCategories = true;

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

  Future<String> accountExistsLocal({@required email, hashPass}) async{
    Database db = await newDB;
    List _data;
    if (hashPass == null) {
      _data = await db.rawQuery(
          "SELECT PK_ID FROM T_ACCOUNT WHERE PV_EMAIL = ? AND IL_DEL = 0", [email]);
      if (_data.length != 0){
        return 'exists';
      }
      return '';
    }
    else
      _data = await db.rawQuery("SELECT PK_ID FROM T_ACCOUNT WHERE PV_EMAIL = ? AND PV_PSWD = ? AND IL_DEL = 0", [email, hashPass]);
    if (_data.length != 0){
      debugPrint('accounts: '+_data.toString());
      return _data[0]["PK_ID"];
    }
    return '';
  }
  Future<bool> emailIsTakenGlobal({@required email, bool strict = false, bool onRegister = true})async{
    await Future.delayed(const Duration(seconds: 2), (){});  //TODO: здесь вызываем глобальную базу для проверки, есть ли аккаунт с такой почтой
    bool internet = false; //
    if (strict){ //если проверка жесткая (например из банера синхронизации почты или если есть интернет)
      if (!internet)
        return null;
      return true;
    }
    //if (onRegister)
    //  uncheckedEmailWhileRegister = false; // этот флаг делаем false только при отрицательном ответе сервера (почта не зарегистрирована, инфа сотка, сразу после проверки занимаем место)
    return false; // иначе, если проверка мягкая (нет интернета во время регистрации -> регаем пользователя, но ставим ему флаг
  }
  Future<bool> hasSecret({@required acc_id})async{
    Database db = await newDB;
    List _data = await db.rawQuery("SELECT V_SECRET FROM T_ACCOUNT WHERE PK_ID = ? AND IL_DEL = 0", [acc_id]);
    if (_data.length != 0){
      if (_data[0]["V_SECRET"].toString().length > 0 && _data[0]["V_SECRET"].toString().toLowerCase() != 'null')
        return true;
      return false;
    }
    else{
      exit(1);
    }
  }
  Future<Map> getUserCardsNCategories({@required acc_id})async{ //на выходе д.б. {cards: {cat1: [{card1}, {card2}...], cat2: [{card3}, {card4} ...]}, categories: [{cat1}, {cat2}]}
    Database db = await newDB;
    List _data = await db.rawQuery('SELECT '
        'access.PI_PRIORITY as PRIORITY, '
        'ctg.PK_ID as ctgID, '
        'ctg.PV_NAME as ctgName, '
        'ctg.PI_ORDER as ctgORDER, '
        'ctg.V_ICON as ctgIcon, '
        'ctg.V_ICON_COLOR as ctgIconColor, '
        'ctg.V_BACKGROUND_COLOR as ctgBG, '
        'crd.PK_ID as CAD, '
        'crd.PV_NAME as CNAME, '
        'crd.PI_ORDER as CORDER, '
        'crd.B_IMAGE_FRONT as frontImage, '
        'crd.B_IMAGE_BACK as backImage '    //TODO: остальные данные карты
        'from T_CARD crd JOIN '
        'T_ACCESS access on crd.PK_ID = access.FK_CARD LEFT JOIN '
        'T_CATEGORY ctg on access.FK_CATEGORY = ctg.pk_id JOIN '
        'T_ACCOUNT acc ON access.FK_ACCOUNT = acc.PK_ID '
        "WHERE acc.PK_ID = ? AND acc.IL_DEL = 0 AND crd.IL_DEL = 0 AND (ctg.IL_DEL = 0 or ctg.il_del is NULL) AND access.IL_DEL = 0 "
        "order BY ctg.pi_order asc", [acc_id]);
    List _emptyCategories = await db.rawQuery('SELECT '
        'ctg.PK_ID as ctgID, '
        'ctg.PV_NAME as ctgName, '
        'ctg.PI_ORDER as ctgORDER, '
        'ctg.V_ICON as ctgIcon, '
        'ctg.V_ICON_COLOR as ctgIconColor, '
        'ctg.V_BACKGROUND_COLOR as ctgBG '
        'from T_CATEGORY ctg '
        'where ctg.FK_ACCOUNT = ? '
        'and (SELECT count(crd.PK_ID) FROM T_CARD crd JOIN T_ACCESS access on crd.PK_ID = access.FK_CARD WHERE FK_CATEGORY = ctg.PK_ID and crd.IL_DEL = 0 AND access.IL_DEL = 0 AND access.FK_ACCOUNT = ?) = 0 '
        'and ctg.IL_DEL = 0', [acc_id, acc_id]); //такие категории, которые принадлежат этому пользователю, но у которых ещё нету ни одной карты (не попали в выборку сверху)
    Map<String, List> _cards = {};
    List<Map> _categories = [];
    for (int i = 0; i<_data.length; i++){
      String _key = _data[i]['ctgID'];
      Map _crd = {
        'id': _data[i]['CAD'],
        'access': _data[i]['PRIORITY'],
        'name': _data[i]['CNAME'],
        'frontImage':_data[i]['frontImage'].toString().length>4?base64Decode(_data[i]['frontImage']):null,
        'backImage':_data[i]['backImage'].toString().length>4?base64Decode(_data[i]['backImage']):null,
        'order': _data[i]['CORDER'],
      };
      if (_cards.containsKey(_key))
        _cards[_key] = _cards[_key] + [_crd];
      else {
        if (_key != null && _key != 'null')
          _categories.add({
            'id': _data[i]['ctgID'],
            'name': _data[i]['ctgName'],
            'order': _data[i]['ctgORDER'],
            'icon': _data[i]['ctgIcon'],
            'iconColor': _data[i]['ctgIconColor'],
            'backgroundColor': _data[i]['ctgBG'],
          });
        _cards[_key] = [_crd];
      }
    }
    for (int i = 0; i<_emptyCategories.length; i++){
      _categories.add({
        'id': _emptyCategories[i]['ctgID'],
        'name': _emptyCategories[i]['ctgName'],
        'order': _emptyCategories[i]['ctgORDER'],
        'icon': _emptyCategories[i]['ctgIcon'],
        'iconColor': _emptyCategories[i]['ctgIconColor'],
        'backgroundColor': _emptyCategories[i]['ctgBG'],
      });
    }
    return {'cards':_cards, 'categories':_categories};
  }
  Future<String> createNewUser({@required String email, @required String hash_pass}) async {
    Database db = await newDB;
    String _id = guid();
    await db.rawInsert("INSERT INTO T_ACCOUNT(PK_ID, PV_EMAIL, PV_PSWD, PT_REG, IV_USER, IT_CHANGE) VALUES(?, ?, ?, ?, ?, ?)", [_id, email.toLowerCase(), hash_pass, timeStamp(), 'application', timeStamp()]);
    if (uncheckedEmailWhileRegister)
      saveBadEmail(email);
    else{
      //TODO: send new account to global database
    }
    saveCreditionals(email: email, password: hash_pass);
    return _id;
  }
  createCard({@required String creator_id, String cardName, String cardComment, String category, String blob1, String blob2})async{
    Database db = await newDB;
    String card_id = guid();
    await db.rawInsert('INSERT INTO T_CARD(PK_ID, PV_NAME, V_COMMENT, B_IMAGE_FRONT, B_IMAGE_BACK, IV_USER, IT_CHANGE) '
        'VALUES(?, ?, ?, ?, ?, ?, ?)', [card_id, cardName==null?'Без названия':cardName, cardComment,
      blob1, blob2,
      creator_id, timeStamp()]);
    if (category == null)
      await db.rawInsert('INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES(?, ?, ?, ?, ?)', [guid(), creator_id, card_id, creator_id, timeStamp()]);
    else
      try{
        await db.rawInsert('INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, FK_CATEGORY, IV_USER, IT_CHANGE) VALUES(?, ?, ?, ?, ?, ?)', [guid(), creator_id, card_id, category, creator_id, timeStamp()]);
      }
    catch(e){}
  }
  createCategory({@required String creator_id, @required String cardName}) async {
    Database db = await newDB;
    await db.rawInsert('INSERT INTO T_CATEGORY(PK_ID, PV_NAME, FK_ACCOUNT, IV_USER, IT_CHANGE) VALUES(?, ?, ?, ?, ?)', [guid(), cardName, creator_id, creator_id, timeStamp()]);
    getUserCardsNCategories(acc_id: creator_id); //debug tool
}//TODO: дополнить функцию необходимыми параметрами
  moveCardToCategory({@required String card_id, @required String category_id, @required String user})async{
    Database db = await newDB;
    await db.rawUpdate("UPDATE T_ACCESS SET FK_CATEGORY = ?, IV_USER = ?, IT_CHANGE = ? WHERE FK_CARD = ? AND FK_ACCOUNT = ? AND IL_DEL = 0", [category_id, user, timeStamp(), card_id, user]);
    return;
  }

  //Метод который меняет очередность карт, на вход получает id карты и числовое значение order, на которое надо сменить ее значение
  reorderItems({List cardsToUpdate, List categoriesToUpdate})async{
    Database db = await newDB;
    if (cardsToUpdate != null)
      for (var el in cardsToUpdate){
        await db.rawUpdate('UPDATE T_CARD SET PI_ORDER = ? WHERE PK_ID = ? AND IL_DEL = 0', [el['order'], el['id']]);
      }
    else
      for (var el in categoriesToUpdate){
        await db.rawUpdate('UPDATE T_CATEGORY SET PI_ORDER = ? WHERE PK_ID = ? AND IL_DEL = 0', [el['order'], el['id']]);
      }
  }

  //Метод удаления карты
  removeCard(String cardID, {bool removeCard = false})async{
    Database db = await newDB;
    try{
      await db.rawUpdate('UPDATE T_ACCESS SET IL_DEL = 1, IT_CHANGE = ? WHERE FK_CARD = ? AND FK_ACCOUNT = ?', [timeStamp(), cardID, accountGuid]);
      if (removeCard)
        await db.rawUpdate('UPDATE T_CARD SET IL_DEL = 1, IT_CHANGE = ? WHERE PK_ID = ?', [timeStamp(), cardID]);
    }
    catch(e){}
  }
  
  //Проставляем логическое удаление категории и обнуляем зависимости в T_ACCESS
  removeCategory(String catID)async{
    Database db = await newDB;
    try{
      await db.rawUpdate('UPDATE T_CATEGORY SET IL_DEL = 1, IT_CHANGE = ? WHERE PK_ID = ?', [timeStamp(), catID]);
      await db.rawUpdate('UPDATE T_ACCESS SET FK_CATEGORY = NULL, IT_CHANGE = ? WHERE FK_CATEGORY = ?', [timeStamp(), catID]);
    }
    catch(e){}
  }
}
