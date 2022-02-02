import 'dart:ui';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

/// Main color in the application
Color primaryDark = Colors.green; //из фигмы
/// Second color used for gradient and backfields
Color primaryLight = Colors.lightGreen; //из фигмы
/// Color for disabled fields
Color disabledGrey = Colors.grey;
//Color successColor = Color(0xFF53D769); //из фигмы
//Color errorColor = Color(0xFFFF4E4E); //из фигмы
//Color primaryBlack = Color(0xFF2E3034); //из фигмы

/// Default gradient shader
Gradient bottomGradient = LinearGradient(
    colors: [primaryLight, primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.topRight
);

/// Secondary colors to use for tiles and dynamic background
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

/// Returns color from secondaryColors by [index]
Color getColorForTile(int index){
  // получение цвета для заданного индекса внутри массива дополнительных цветов приложения
  return secondaryColors[index % secondaryColors.length];
}

/// ThemeData to use as default
ThemeData mainTheme = ThemeData(
  platform: TargetPlatform.android,
  primaryColor: primaryDark,
  secondaryHeaderColor: Colors.white,
  accentColor: primaryDark,
  indicatorColor: primaryDark,
  bottomAppBarColor: primaryDark,
  bottomAppBarTheme: BottomAppBarTheme(color: primaryDark),
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: primaryDark),
); // в будущем эту переменную будет изменять смена темы в приложении/системе, все цвета будут автоматически браться из темы

//набор текстовых стилей, все основные стили прописаны здесь. Либо использовать напрямую, либо копировать с изменением параметров
TextStyle white20 = TextStyle(fontSize: 20, color: Colors.white);
TextStyle white24 = TextStyle(fontSize: 24, color: Colors.white);
TextStyle def24 = TextStyle(fontSize: 24, color: primaryDark);
TextStyle def20bold = TextStyle(fontSize: 20, color: primaryDark, fontWeight: FontWeight.bold);
TextStyle link16 = TextStyle(color: Color(0xFF3CBAF0), fontSize: 16); //для виджета текста почты тех поддержки
TextStyle red16 = TextStyle(color: Colors.red, fontSize: 16);
TextStyle grey16 = TextStyle(color: Colors.grey, fontSize: 16);
TextStyle white16 = TextStyle(color: Colors.white, fontSize: 16);
TextStyle black16 = TextStyle(color: Colors.black, fontSize: 16);
TextStyle def16 = TextStyle(fontSize: 16, color: primaryDark);
//TODO

BuildContext contextForLogic;

/// Current state of the user
bool authorized = false; //глобальная переменная для проверки, выполнен ли вход в аккаунт? Эквивалентна accountGuid == null
/// Flag of the first run to show onboarding
bool needAutoRegistration = true; //глобальная переменная для проверки, требуется ли авторегистрация? По факту - дублирует переменную в hive для более быстрой работы


/// Returns hash from [str]
String getHash(String str){
  //функция возвращает хэш строки (используется при хэшировании пароля)
  return md5.convert(utf8.encode(str)).toString();
}

/// Global variables for user data
String accountGuid, accountEmail, pass;

/// Public application name
final String app_name = "Cardy: your wallet"; //глобальное название приложения TODO

/// Starts new [home] application with default theme/title/color
appRuner(Widget home){
  if(!kIsWeb)
    runApp(new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: mainTheme,
        title: app_name,
        color: primaryDark,
        home: home
    ));
  else
    throw Exception("Веб-версия не реализована");
    //webRunner(home);
}

/*
//bool isWeb = false; //дубликат переменной kIsWeb, который используется в приложении
/// Web version of application
webRunner(Widget home){
  if(kIsWeb)
    runApp(new MaterialApp(
        theme: mainTheme,
        title: app_name,
        color: primaryDark,
        home: home
    ));
  else
    appRuner(home);
}
 */

/// Flag if registration was offline and email isn't checked
bool uncheckedEmailWhileRegister = true;
/// Flag if email is still unchecked
bool uncheckedEmail = true;
/// Default appBar height
double appBarHeight = 60;


/// Password field to use as default
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

/// AppBar widget to use as default
Widget appBarUsual(BuildContext context, double _width, {Widget leading, Widget child, Function onBack, Widget trailing}){
  return PreferredSize(
    preferredSize: Size(_width, appBarHeight),
    child: Container(
      color: primaryDark,
      child: SafeArea(
          child: Container(
            width: _width,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Builder(builder: (context){
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  leading!=null?leading:(Navigator.canPop(context) || onBack != null)?GestureDetector(
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
                  ):Scaffold.of(context).hasDrawer?GestureDetector(
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                    onTap: (){
                      Scaffold.of(context).openDrawer();
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
              );
            }),
          )
      ),
    ),
  );
}

/// Button widget to use as default
Widget defButton({@required Function onPressed, Widget child, Color color, String text, double minWidth}){
  return AnimatedContainer(
    duration: Duration(milliseconds: 800),
    decoration: BoxDecoration(
      color: onPressed==null?disabledGrey:color==null?primaryDark:color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: disabledGrey, offset: Offset(1, 1), blurRadius: 1.0, spreadRadius: 1.0)],
    ),
    child: MaterialButton(
      minWidth: minWidth==null?240:minWidth,
      onPressed: onPressed,
      child: child==null?Text(text!=null?text:'empty', style: white16,):child,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      disabledColor: Colors.transparent,
      elevation: 0.0,
      disabledElevation: 0.0,
    ),
  );
}

/// Default access int value
int mainAccessInt = 100;
/// Height of card tile
double cardHeight = 160;
/// Height of category tile
double cardExtended = 200;
/// Max length of note string
int noteLength = 1000;

/// Support email address (right now - unavailable)
String supportEmail = 'cardy_bsk_app@mail.ru';

/// Opens support email for current locale (right now - RU) with url_launcher.dart:launch()
openSupportEmail(BuildContext context, {bool noLocalization = false})async{
  var url = 'mailto:';
  url += supportEmail;
  await launch(url);
}

/// Support label, on tap starts openSupportEmail
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