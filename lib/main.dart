import 'package:card_app_bsk/mainPage.dart';
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
  TextEditingController _emailController = TextEditingController(); //для заполнения поля значением из hive
  String log, message, _pass;
  bool secretPass = true;
  bool _loading = true;


  _AuthorizationScreen({this.log, this.message});


  Future<void> tryAuth() async{
    String _tmp = await localDB.db.accountExistsLocal(email: log, hashPass: getHash(_pass));
    if (_tmp.length > 0){
      accountGuid = _tmp;
      saveCreditionalsIfNeeded(email: log, password: getHash(_pass));
      if (await localDB.db.hasSecret(acc_id: accountGuid)){
        appRuner(pinScreen());
      }
      else{
        openMain();
      }
    }
    else{
      //TODO: show "incorrect email+password" message
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading){
      if(mounted)
        setState(() {
          _emailController.text = log;
          _loading = false;
        });
    }
    debugPrint('acc: '+log.toString()+' '+_pass.toString());
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
            //Expanded(child: SizedBox(), flex: 1),
            Expanded(child: SizedBox(), flex: 1,),
            Center(child: Text(app_name, style: white20,)),
            Expanded(child: SizedBox(), flex: 1,),
            Expanded(
              flex: 10,
              child: Container(
                width: _width-50,
                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(27), topRight: Radius.circular(27)), color: Colors.white),
                padding: EdgeInsets.only(left: 10, right: 10, top: 25),
                child: ColoredBox(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24
                        ),
                        child: TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Введите email',
                          ),
                          onChanged: (String loginStr){log = loginStr;},
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24
                        ),
                        child:
                          passwordField(
                            onSuffixTap: (){
                              setState(() {
                                secretPass = !secretPass;
                              });
                            },
                            obscure: secretPass,
                            onChanged: (val){
                              _pass = val;
                            },
                        ),
                      ),
                      SizedBox(height: 15,),
                      MaterialButton(
                        color: primaryDark,
                        child: Text("Войти"),
                        onPressed:(){
                          tryAuth();
                        },
                      ),
                      SizedBox(height: 25,),
                      OutlineButton(
                        child: Text("Зарегистрироваться"),
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {return regScreen();}));
                        },
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openMain() async{ //этот метод запускает главный экран, когда пользователь авторизовался, ввел пин-код или зарегистрировался.
  appRuner(mainPage());
}

void start() async{
  authorized = false;
  accountGuid = '';
  accountEmail = '';
  pass = '';
  await localDB.db.InitDatabase();
  await initHive();
  if (needAutoRegistration)
    appRuner(onBoarding());
  else if (! authorized)
    if (accountEmail != null)
      appRuner(AuthorizationScreen(log: accountEmail));
    else
      appRuner(AuthorizationScreen());
  else{
    String _tmp = await localDB.db.accountExistsLocal(email: accountEmail, hashPass: pass);
    if (_tmp.length > 0){
      accountGuid = _tmp;
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