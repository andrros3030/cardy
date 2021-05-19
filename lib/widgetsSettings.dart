import 'dart:ui';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Color primaryDark = Colors.green; //из фигмы
Color primaryLight = Colors.lightGreen; //из фигмы
Color primaryBlack = Color(0xFF2E3034); //из фигмы
Color successColor = Color(0xFF53D769); //из фигмы
Color errorColor = Color(0xFFFF4E4E); //из фигмы

Color backgroundColor = primaryDark; //основной цвет проги
Color backForFields = primaryLight;
Gradient bottomGradient = LinearGradient(
    colors: [backForFields, backgroundColor],
    begin: Alignment.centerLeft,
    end: Alignment.topRight
);

//дополнительные цвета, которые можно использовать для тайлов или других цветных штук
List<Color> secondaryColors = <Color>[
  Color(0xFF3CBAF0),
  Color(0xFF19C793),
  Color(0xFFF7BCBC),
  Color(0xFF19BDC7),
  Color(0xFFD7B9F3),
  Color(0xFFFAE9B7),
  Color(0xFFA3E4E9),
  Color(0xFF93D9C4),
  Color.fromRGBO(43, 172, 252, 0.2)
];
//получение цвета для заданного индекса внутри массива дополнительных цветов приложения
Color getColorForTile(int index){
  return secondaryColors[index % secondaryColors.length];
}

ThemeData mainTheme = ThemeData(
  platform: TargetPlatform.android,
  primaryColor: backgroundColor,
  accentColor: backgroundColor,
  indicatorColor: backgroundColor,
  bottomAppBarColor: backgroundColor,
  bottomAppBarTheme: BottomAppBarTheme(color: backgroundColor),
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: backgroundColor),
);

//набор текстовых стилей, все основные стили прописаны здесь. Либо использовать напрямую, либо копировать с изменением параметров
TextStyle white20 = TextStyle(fontSize: 20, color: Colors.white);
//TODO

BuildContext contextForLogic;

bool tabBarisUp = false; //из мвп вынесли, настройка для отображения иконок меня сверху, удалить хвосты?
bool authorized = false; //глобальная переменная для проверки, выполнен ли вход в аккаунт? Эквивалентна accountGuid == null
bool needAutoRegistration = true; //глобальная переменная для проверки, требуется ли авторегистрация? По факту - дублирует переменную в hive для более быстрой работы

//функция возвращает хэш строки (используется при хэшировании пароля)
String getHash(String str){
  return md5.convert(utf8.encode(str)).toString();
}

String accountGuid; //тут хранится fk_id аккаунта, заполняется при авторизации и очищается при логине. Проставляется как fv_user и в подобных случаях.

bool isWeb = false; //дубликат переменной kIsWeb, который используется в приложении

final String app_name = "Cardy: your wallet"; //глобальное название приложения TODO

//запускает приложение с заданным экраном и локализатором
appRuner(Widget home){
  if(!kIsWeb)
    runApp(new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: mainTheme,
        title: app_name,
        color:backgroundColor,
        home: home
    ));
  else
    webRunner(home);
}

//TODO что будет если открываем в браузере
webRunner(Widget home){
  if(kIsWeb)
    runApp(new MaterialApp(
        theme: mainTheme,
        title: app_name,
        color: backgroundColor,
        home: home
    ));
  else
    appRuner(home);
}

//открывает ссылку на отправку
openSupportEmail(BuildContext context, {bool noLocalization = false})async{
  var url = 'mailto:';
  //TODO: url += our_adress
  await launch(url);
}