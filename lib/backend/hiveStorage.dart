import 'dart:io';

import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
Box appData;

void firstRun(){
  needAutoRegistration = true;
}


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
    }
    if (keys.contains("pass")){
      pass = appData.get("pass");
      authorized = true;
    }
  }
}