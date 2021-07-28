import 'package:card_app_bsk/telegram_dart.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:card_app_bsk/backend/database.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import 'main.dart';

class userPage extends StatefulWidget {
  @override
  _userPage createState() => _userPage();
}

class _userPage extends State<userPage> {


  final _formKey = GlobalKey<FormState>();
  bool canContinue = false;
  bool _loading = false;
  bool _showingBad = false;
  String _email = accountEmail;
  String _note = '';
  bool validEmail = true; // по определению, почта сохраненная в базе - является почтой, т.к. была проверена при регистрации

  String isEmail(String s){
    if (_note.length > 1)
      return _note;
    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(s))
      return null;
    return "введите настоящую почту";
  }
  Future availableEmail(String s) async{
    setState(() {
      _loading = true;
    });
    debugPrint('process started');
    bool res = false; //await localDB.db.accountExistsLocal(email: _email); // не проверяем с локальным т.к. либо 1) второго локального с такой почтой не существует или 2) он не синхронизирован и занимают почты в формате живой очереди
    if (!res){
      res = await localDB.db.emailIsTakenGlobal(email: _email, strict: true, onRegister: false);
    }
    if (res == null){
      res = true;
      _note = "Мы не можем связаться с серверами, пожалуйста проверьте Ваше интернет-соединение или попробуйте позже, наши сервера могут отдыхать)";
    }
    setState(() {
      _showingBad = res;
      canContinue = !res;
      _loading = false;
    });
  }
  Widget emailField(){
    if (unchekedEmail)
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Нам не удалось проверить Ваш email. Пожалуйста, при необходимости, скоректируйте адрес и нажмите на кнопку для повторной проверки.'),
            //SizedBox(height: 8,),
            TextFormField(
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              onFieldSubmitted: (val){
                if (_note.length < 1 && validEmail && !_loading){
                  canContinue = false;
                  availableEmail(_email);
                }
              },
              decoration: InputDecoration(
                suffix: AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(seconds: 1),
                    child: GestureDetector(
                      child: Container(width: 20, height: 20, child: _loading?CircularProgressIndicator():Icon(_showingBad?Icons.block:canContinue?Icons.done:Icons.adjust, color: _showingBad?Colors.red:canContinue?Colors.green:null,)),
                      onTap: (){
                        if (_note.length < 1 && validEmail && !_loading){
                          canContinue = false;
                          availableEmail(_email);
                        }
                      },
                    ),),
                errorMaxLines: 10,
              ),
              validator: isEmail,
              initialValue: accountEmail,
              onChanged: (val){
                if (_note.length < 1){
                  _email = val.toLowerCase();
                  canContinue = false;
                  _showingBad = false;
                  if (_formKey.currentState.validate())
                    setState(() {
                      validEmail = true;
                    });
                  else if (validEmail)
                    setState(() {
                      validEmail = false;
                    });
                }
              },
            ),
          ],
        ),
      );
    return Container(

    );
  }


  Widget telephoneField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Защитите свой кардхолдер - добавьте номер телефона. Мы будем использовать его в крайнем случае, когда понадобится подтверждение важного действия. Никакого спама!'),
        ],
      ),
    );
  }
  //TODO: для каждого тайла добавить микрокнопку на верхнем уровне стэка - знак вопроса с прозрачностью, по нажатию на который будет открываться полноценное описание функции
  @override
  Widget build(context){
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: appBarUsual(context, _width),
      body: Form(
        autovalidateMode: AutovalidateMode.always, key: _formKey,
        child: Container(
          width: _width,
          height: _height,
          child: ListView(
            children: [
              Container(
                width: _width,
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                child: Center(child: Text('Личные данные', style: green24,),),
              ),
              Container(child: Divider(thickness: 4.0,), padding: EdgeInsets.symmetric(horizontal: 12),),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    emailField(),
                    SizedBox(height: 16,),
                    telephoneField(),
                    SizedBox(height: 16,),
                    MaterialButton(
                      elevation: 8.0,
                      color: primaryDark,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      onPressed: (){telegram_start(context, false,-1, -1);},
                      child: Text("[Telegram]", style: white20,),
                    ),
                  ],
                ),
              ),
              Container(child: supportEmailLabel(context), alignment: Alignment.topCenter,),
            ],
          ),
        ),
      ),
    );
  }
}