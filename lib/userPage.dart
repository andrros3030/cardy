import 'package:card_app_bsk/telegram_dart.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class userPage extends StatefulWidget {
  @override
  _userPage createState() => _userPage();
}

class _userPage extends State<userPage> {


  @override
  Widget build(context){
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBarUsual(context, _width),
      body: Center(
        child: MaterialButton(
          elevation: 8.0,
          color: primaryDark,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          onPressed: (){telegram_start(context, false,-1, -1);},
          child: Text("[Telegram]", style: white20,),
        ),
      ),
    );
  }
}