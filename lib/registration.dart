import 'package:card_app_bsk/backend/database.dart';
import 'package:card_app_bsk/backend/hiveStorage.dart';
import 'package:card_app_bsk/main.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';

class onBoarding extends StatefulWidget {
  @override
  _onBoarding createState() => _onBoarding();
}

class _onBoarding extends State<onBoarding> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text("onboarding"),),
          MaterialButton(
            color: primaryDark,
            child: Text("зарегистрироваться"),
            onPressed: (){appRuner(regScreen());},
          ),
          SizedBox(height: 25,),
          OutlineButton(
            color: primaryDark,
            child: Text("Войти"),
            onPressed: (){
              setOnboardingSkipped();
              appRuner(AuthorizationScreen());
            },
          ),
        ],
      ),
    );
  }
}

class regScreen extends StatefulWidget {
  @override
  _regScreen createState() => _regScreen();
}

class _regScreen extends State<regScreen> {
  final _formKey = GlobalKey<FormState>();
  bool canContinue = false;
  bool validEmail = false;
  bool _loading = false;
  bool _showingBad = false;
  String _email = '';
  String isEmail(String s){
    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(s))
      return null;
    return "введите настоящую почту";
  }
  Future availableEmail(String s) async{
    setState(() {
      _loading = true;
    });
    debugPrint('process started');
    bool res = await localDB.db.accountExistsLocal(email: _email);
    if (!res){
      res = await localDB.db.emailIsTakenGlobal(email: _email);
    }
    setState(() {
      _showingBad = res;
      canContinue = !res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingBad){
      Future.delayed(Duration(seconds: 1)).then((value) {
        setState(() {
          _showingBad = false;
        });
      });
    }
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: appBarUsual(context, _width),
      body: Stack(
        children: [
          Form(
            autovalidateMode: AutovalidateMode.always, key: _formKey,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                width: _width,
                height: _height-appBarHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: SizedBox()),
                    Text("Введите ваш адрес электронной почты, пожалуйста используйте вашу настоящую почту"),
                    SizedBox(height: 10,),
                    TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
                      onFieldSubmitted: (val){
                        if (validEmail && !_loading){
                          canContinue = false;
                          availableEmail(_email);
                        }
                      },
                      decoration: InputDecoration(
                          suffix: AnimatedOpacity(
                            opacity: validEmail?1.0:0.0,
                            duration: Duration(seconds: 1),
                            child: GestureDetector(
                              child: Container(width: 20, height: 20, child: _loading?CircularProgressIndicator():Icon(_showingBad?Icons.block:canContinue?Icons.done:Icons.adjust, color: _showingBad?Colors.red:canContinue?Colors.green:null,)),
                              onTap: (){
                                if (validEmail && !_loading){
                                  canContinue = false;
                                  availableEmail(_email);
                                }
                              },
                            ),)),
                      validator: (val){
                        return isEmail(val);
                      },
                      onChanged: (val){
                        _email = val.toLowerCase();
                        canContinue = false;
                        if (_formKey.currentState.validate())
                          setState(() {
                            validEmail = true;
                          });
                        else if (validEmail)
                          setState(() {
                            validEmail = false;
                          });
                      },
                    ),
                    Expanded(child: SizedBox(),),
                    AnimatedOpacity(
                      opacity: canContinue?1.0:0.0,
                      duration: Duration(seconds: 1),
                      child: MaterialButton(
                        color: primaryDark,
                        onPressed: () {
                          if (canContinue && !_loading){
                            Navigator.of(context).push(_createRoute(_email));
                          }
                        },
                      ),
                    ),
                    Expanded(child: SizedBox(),),
                  ],
                ),
              )
          ),)
        ],
      )
    );
  }
}


Route _createRoute(String _email) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => regScreenPage2(_email),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}


class regScreenPage2 extends StatefulWidget {
  String _email;
  regScreenPage2(this._email);
  @override
  _regScreenPage2 createState() => _regScreenPage2(_email);
}


class _regScreenPage2 extends State<regScreenPage2> {
  String _email, passw0rd;
  bool canRegister = false;
  bool secretPass = true;
  _regScreenPage2(this._email);
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future _register() async{
    accountGuid = await localDB.db.createNewUser(email: _email, hash_pass: passw0rd);
    openMain();
    while (Navigator.of(context).canPop())
      Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    if (_loading)
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(_width, appBarHeight),
          child: Container(
            color: primaryDark,
            child: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Navigator.canPop(context)?GestureDetector(
                        child: Container(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onTap: (){
                          debugPrint(_email);
                          Navigator.of(context).pop();
                        },
                      ):Container(
                        width: 40,
                        height: 40,
                        color: Colors.transparent,
                      ),
                      GestureDetector(
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ),
        ),
      body: Stack(
        children: [
          Form(
            autovalidateMode: AutovalidateMode.always, key: _formKey,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                width: _width,
                height: _height-appBarHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: SizedBox(),),
                    Text("Введите пароль для аккаунта. Придумайте надежный пароль, он поможет защитить ваши данные от злоумышленников. Вы будете использовать его при входе в аккаунт на новом устройстве."),
                    SizedBox(height: 10,),
                    passwordField(
                      validator: (val){
                        return val.length>=8?null:"Длина пароля должна составлять не менее 8 символов";
                      },
                      onChanged: (val){
                        passw0rd = val.toLowerCase();
                        if (_formKey.currentState.validate())
                          setState(() {
                            canRegister = true;
                          });
                      },
                      onSuffixTap: (){
                        setState(() {
                          secretPass = !secretPass;
                        });
                      },
                      obscure: secretPass,
                    ),
                    Expanded(child: SizedBox(),),
                    AnimatedOpacity(
                      opacity: canRegister?1.0:0.0,
                      duration: Duration(seconds: 1),
                      child: MaterialButton(
                        color: primaryDark,
                        onPressed: () {
                          if (canRegister && !_loading){
                            setState(() {
                              _loading = true;
                            });
                            passw0rd = getHash(passw0rd);
                            _register();
                          }
                        },
                      ),
                    ),
                    Expanded(child: SizedBox(),),
                  ],
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}