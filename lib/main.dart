import 'package:flutter/material.dart';
import 'backend/database.dart';
import 'widgetsSettings.dart';
import 'dart:async';

class AuthorizationScreen extends StatefulWidget {
  //TODO: add params to fast auth (log:pass from Hive)
  @override
  _AuthorizationScreen createState() => _AuthorizationScreen();
}

class _AuthorizationScreen extends State<AuthorizationScreen> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(gradient: bottomGradient),
        padding: EdgeInsets.only(left: 25, right: 25, top: 40),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: SizedBox(), flex: 1,),
            Center(child: Text(app_name, style: white20,)),
            Expanded(child: SizedBox(), flex: 1,),
            Expanded(
              flex: 10,
              child: Container(
                width: _width-50,
                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(27), topRight: Radius.circular(27)), color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: ColoredBox(color: Colors.red,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void start() async{
  await localDB.db.InitDatabase();
  appRuner(AuthorizationScreen());
}
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  start();
}