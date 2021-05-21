import 'package:flutter/material.dart';
import 'backend/database.dart';
import 'backend/hiveStorage.dart';
import 'widgetsSettings.dart';
import 'registration.dart';
import 'pinPage.dart';
import 'dart:async';

class AuthorizationScreen extends StatefulWidget {
  String log, message;
  AuthorizationScreen({this.log, this.message});
  @override
  _AuthorizationScreen createState() => _AuthorizationScreen(log: this.log, message: this.message);
}

class _AuthorizationScreen extends State<AuthorizationScreen> {
  String log, message;
  _AuthorizationScreen({this.log, this.message});
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

void openMain() async{ //этот метод запускает главный экран, когда пользователь авторизовался, ввел пин-код или зарегистрировался.

}

void start() async{
  await localDB.db.InitDatabase();
  await initHive();
  if (needAutoRegistration)
    appRuner(onBoarding());
  else if (! authorized)
    appRuner(AuthorizationScreen(log: accountEmail));
  else{
    if (await localDB.db.accountExistsLocal(email: accountEmail, hashPass: pass)){
      if (await localDB.db.hasSecret(acc_id: accountGuid)){
        appRuner(pinScreen());
      }
      else{
        openMain();
      }
    }
    else{
      appRuner(AuthorizationScreen(log: accountEmail, message: "Данные для входа в аккаунт устарели, пожалуйста введите пароль заново",));
    }
  }

}
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  start();
}