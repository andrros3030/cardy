import 'package:card_app_bsk/backend/database.dart';
import 'package:card_app_bsk/backend/hiveStorage.dart';
import 'package:card_app_bsk/main.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:card_app_bsk/backend/storiesModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class onBoarding extends StatefulWidget {
  @override
  _onBoarding createState() => _onBoarding();
}

class _onBoarding extends State<onBoarding> {
  double _width, _height;
  List<Widget> _onBoardingPictures = [
    Container(
      color:Colors.transparent,
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RichText(
            text: TextSpan(
              text: "Все карты у Вас в телефоне\n\n",
              style: def20bold,
              children: <TextSpan>[
                TextSpan(text: "Избавьтесь от кардхолдера и сохраните все карты в удобную струтуру - по папкам", style: def16)
              ],
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: disabledGrey,
          ),
        ],
      ),
    ),
    Container(
      color:Colors.transparent,
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RichText(
            text: TextSpan(
              text: "Делитесь с близкими\n\n",
              style: def20bold,
              children: <TextSpan>[
                TextSpan(text: "Поделитесь картой с другом или предоставьте доступ к аккаунту всей семье", style: def16)
              ],
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: disabledGrey,
          ),
        ],
      ),
    ),
    Container(
      color:Colors.transparent,
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RichText(
            text: TextSpan(
              text: "Это безопасно\n\n",
              style: def20bold,
              children: <TextSpan>[
                TextSpan(text: "Данные в приложении надежно шифруются и передаются только по защищенным протоколам", style: def16)
              ],
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: disabledGrey,
          ),
        ],
      ),
    )
  ];

  Widget _picturer(){
    return Container(
      width: _width-24,
      height: _height-160,
      child: Story(
        autoPlay: true,
        //fullscreen: false,
        //showBottomBar: true,
        momentCount: _onBoardingPictures.length,
        momentDurationGetter: (index)=>Duration(seconds: 5),
        momentBuilder: (context, index){
          return Hero(
              tag: "story${index+1}",
              child: Container(
                //color: Colors.transparent,
                alignment: Alignment.center,
                width: _width - 24,
                height: _height - 160,
                child: _onBoardingPictures[index],
              )
          );
        },
        startAt: 0,
        onStoryEnded: (index){
          return;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _picturer(),
            Container(
              width: _width,
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  defButton(
                    minWidth: 100,
                    color: Colors.white, //Theme.of(context).secondaryHeaderColor
                    child: Text("Войти", style: def16,),
                    onPressed: (){
                      setOnboardingSkipped();
                      appRuner(AuthorizationScreen());
                    },
                  ),
                  defButton(
                    minWidth: 100,
                    color: primaryDark,
                    text: "Зарегистрироваться",
                    onPressed: (){appRuner(regScreen());},
                  ),
                ],
              ),
            ),
          ],
        ),
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
  FocusNode _focus = FocusNode();

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
    String _res = await localDB.db.accountExistsLocal(email: _email);
    bool res = true;
    if (_res.length < 1){
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
                      focusNode: _focus,
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
                              onTap: ()async{
                                _focus.unfocus();
                                if (validEmail && !_loading && !canContinue){
                                  canContinue = false;
                                  availableEmail(_email);
                                }
                              },
                            ),),),
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
                    Expanded(child: SizedBox(),),
                    Text("Введите пароль для аккаунта. Придумайте надежный пароль, он поможет защитить ваши данные от злоумышленников. Вы будете использовать его при входе в аккаунт на новом устройстве."),
                    SizedBox(height: 10,),
                    passwordField(
                      validator: (val){
                        return val.length>=8?null:"Длина пароля должна составлять не менее 8 символов";
                      },
                      onChanged: (val){
                        passw0rd = val;
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