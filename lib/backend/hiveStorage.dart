import 'dart:io';

import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
Box appData;

void firstRun(){
  needAutoRegistration = true;
}
String _keyBadEmails = "badEmail";

Future initHive() async {
  await Hive.initFlutter();
  appData = await Hive.openBox("appData");
  List keys = List.from(appData.keys);
  if (keys.length == 0){
    firstRun();
  }
  else{
    needAutoRegistration = false;
    if (keys.contains("email")) {
      accountEmail = appData.get("email");
      if (!List.from(appData.get(_keyBadEmails)).contains(accountEmail))
        unchekedEmail = false;
    }
    if (keys.contains("pass") && appData.get("pass").toString().length >= 8){ //TODO: если человек ставит флажок "не сохрянать пароль" то записываем сюда слово до 8 символов
      pass = appData.get("pass");
      authorized = true;
    }
  }
}

void saveBadEmail(String email){
  List data;
  if (List.from(appData.keys).contains(_keyBadEmails)){
    data = List.from(appData.get(_keyBadEmails));
  }
  else{
    data  = [];
  }
  data.add(email);
  appData.put(_keyBadEmails, data);
}

void saveCreditionals({@required email, password}){
  appData.put("email", email);
  appData.put("pass", password);
}

void saveCreditionalsIfNeeded({@required email, @required password}){
  if (!List.from(appData.keys).contains("email") || appData.get("email") == email){
    if (!List.from(appData.keys).contains("pass") || appData.get("pass").toString().length >= 8) {
      appData.put("email", email);
      appData.put("pass", password);
    }
  }
  else{
    appData.put("email", email);
    appData.put("pass", password);
  }
}

void closeAccount(){
  appData.delete("pass");
}

void setOnboardingSkipped(){
  appData.put("onBoardingSkipped", true);
}