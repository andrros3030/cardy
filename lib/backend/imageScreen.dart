import "dart:io";

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:photo_view/photo_view_gallery.dart';

class showFullImage extends StatefulWidget{
  File image;
  showFullImage(this.image);
  @override
  createState() => new _showImage(image,);
}

class _showImage extends State<showFullImage>{
  File image; //изображение открытое пользователем, возможно можно удалить
  _showImage(this.image);
  PageController _view; //отвечает за перелистывание изображения

  Widget build(BuildContext context){
    //эта штука исключена из мвп, но тут осталась кнопка "поделится" и ее плагин я не удалял
    Widget _buttonBar = Container(
      color: primaryLight.withOpacity(0.5),
      width: MediaQuery.of(context).size.width,
      child: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: (){Navigator.pop(context);},),
    );
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              child: PhotoView(imageProvider: FileImage(image),),
              height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,),
            Positioned(child: _buttonBar, bottom: 0,)
          ],
        ),
      ),
    );
  }
}