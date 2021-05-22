import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';

class mainPage extends StatefulWidget {
  @override
  _mainPage createState() => _mainPage();
}


class _mainPage extends State<mainPage> {


  @override
  Widget build(BuildContext context) {
    debugPrint("newBuild");
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          accountGuid + unchekedEmail.toString()
        ),
      ),
    );
  }
}