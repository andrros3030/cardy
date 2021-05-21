import 'package:card_app_bsk/backend/database.dart';
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
            onPressed: (){appRuner(regScreen());},
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
  int i = 0;
  bool canContinue = false;
  bool validEmail = false;
  bool _loading = false;
  bool _showingBad = false;
  String _email = '';
  @override
  String isEmail(String s){
    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(s))
      return null;
    return "введите настоящую почту";
  }
  Future<bool> availableEmail(String s) async{
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
                      debugPrint("tap on arrow_back");
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
                    Expanded(child: SizedBox()),
                    Text("Введите ваш адрес электронной почты, пожалуйста используйте вашу настоящую почту"),
                    SizedBox(height: 10,),
                    TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
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
                            debugPrint("button next");
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