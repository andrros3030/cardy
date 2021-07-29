import 'dart:ui';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

Color primaryDark = Colors.green; //из фигмы
Color primaryLight = Colors.lightGreen; //из фигмы
Color primaryBlack = Color(0xFF2E3034); //из фигмы
Color disabledGrey = Colors.grey;
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
  Color(0xFFFFFACC),
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
TextStyle white24 = TextStyle(fontSize: 24, color: Colors.white);
TextStyle def24 = TextStyle(fontSize: 24, color: backgroundColor);
TextStyle link16 = TextStyle(color: Color(0xFF3CBAF0), fontSize: 16); //для виджета текста почты тех поддержки
TextStyle red16 = TextStyle(color: Colors.red, fontSize: 16);
TextStyle grey16 = TextStyle(color: Colors.grey, fontSize: 16);
TextStyle white16 = TextStyle(color: Colors.white, fontSize: 16);
TextStyle black16 = TextStyle(color: Colors.black, fontSize: 16);
TextStyle def16 = TextStyle(fontSize: 16, color: backgroundColor);
//TODO

BuildContext contextForLogic;

bool authorized = false; //глобальная переменная для проверки, выполнен ли вход в аккаунт? Эквивалентна accountGuid == null
bool needAutoRegistration = true; //глобальная переменная для проверки, требуется ли авторегистрация? По факту - дублирует переменную в hive для более быстрой работы

//функция возвращает хэш строки (используется при хэшировании пароля)
String getHash(String str){
  return md5.convert(utf8.encode(str)).toString();
}

String accountGuid, accountEmail, pass;

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

bool uncheckedEmailWhileRegister = true;
bool unchekedEmail = true;
double appBarHeight = 60;

Widget passwordField({Function validator, Function onChanged, @required bool obscure, @required onSuffixTap}){
  return TextFormField(
    maxLines: 1,
    validator: validator,
    onChanged: onChanged,
    obscureText: obscure,
    decoration: InputDecoration(
      errorMaxLines: 3,
      suffixIcon: GestureDetector(
        child: Container(
          height: 20,
          width: 20,
          child: Icon(
            obscure?FontAwesome5.eye:FontAwesome5.eye_slash, size:16
          ),
        ),
        onTap: onSuffixTap,
      ),
    ),
  );
}

Widget appBarUsual(BuildContext context, double _width, {Widget child, Function onBack, Widget trailing}){
  return PreferredSize(
    preferredSize: Size(_width, appBarHeight),
    child: Container(
      color: primaryDark,
      child: SafeArea(
          child: Container(
            width: _width,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                (Navigator.canPop(context) || onBack != null)?GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onTap: onBack != null? onBack: (){
                    Navigator.of(context).pop();
                  },
                ):Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                ),
                child == null?SizedBox():child,
                trailing == null?GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.transparent,
                  ),
                ):trailing,
              ],
            ),
          )
      ),
    ),
  );
}

Widget defButton({@required Function onPressed, Widget child, Color color, shape}){
  return MaterialButton(
    minWidth: 240,
    onPressed: onPressed,
    child: child,
    color: color==null?primaryDark:color,
    shape: shape==null?RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)):shape,
    elevation: 8.0,
    disabledElevation: 8.0,
    disabledColor: disabledGrey,
  );
}

int mainAccessInt = 100;
double cardHeight = 160;
double cardExtended = 200;
int noteLength = 1000;
String supportEmail = 'support@cardy.com'; //TODO: fill our_adress
//открывает ссылку на отправку
openSupportEmail(BuildContext context, {bool noLocalization = false})async{
  var url = 'mailto:';
  url += supportEmail;
  await launch(url);
}
Widget supportEmailLabel(BuildContext context){
  return GestureDetector(
    child: Container(
      child: Text(supportEmail, style: link16,),
    ),
    onTap: (){
      openSupportEmail(context);
    },
  );
}
