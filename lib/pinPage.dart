import 'package:flutter/material.dart';

class pinScreen extends StatefulWidget {
  @override
  _pinScreen createState() => _pinScreen();
}

class _pinScreen extends State<pinScreen> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Text("pinScreen"),
      ),
    );
  }
}