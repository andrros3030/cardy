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
      body: Center(child: Text("onboarding"),),
    );
  }
}

class regScreen extends StatefulWidget {
  @override
  _regScreen createState() => _regScreen();
}

class _regScreen extends State<regScreen> {
  @override
  Widget build(BuildContext context) {
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
      body: Center(
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
              TextField(),
              Expanded(child: SizedBox(),),
              Opacity(
                opacity: 1.0,
                child: MaterialButton(
                  color: primaryDark,
                  onPressed: () {
                    debugPrint("button next");
                  },
                ),
              ),
              Expanded(child: SizedBox(),),
            ],
          ),
        )
      ),
    );
  }
}