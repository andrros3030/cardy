import "dart:io";

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:card_app_bsk/widgetsSettings.dart';

Future<File> cropImage(File _cur)async{
  File croppedFile = await ImageCropper.cropImage(
    sourcePath: _cur.path,
    androidUiSettings: AndroidUiSettings(
      lockAspectRatio: false,
      toolbarTitle: '',
      toolbarColor: primaryDark,
      toolbarWidgetColor: Colors.white,
      hideBottomControls: true,
    ),
    iosUiSettings: IOSUiSettings(
      aspectRatioLockEnabled: false,
      title: '',
      resetButtonHidden: true,
      aspectRatioPickerButtonHidden: true,
      rotateButtonsHidden: true,
      rotateClockwiseButtonHidden: true,
    ),
  );
  return croppedFile;
}

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
      child: IconButton(
        icon: Icon(Icons.delete, color: Colors.red, size: 30,),
        onPressed: (){Navigator.pop(context, null);},
      ),
    );
    return WillPopScope(
      onWillPop: () async {Navigator.pop(context, image); return false;},
      child: Scaffold(
        appBar:appBarUsual(context, MediaQuery.of(context).size.width, trailing: GestureDetector(
          child: Container(
            width: 40,
            height: 40,
            child: Icon(Icons.crop, color: Colors.white, size: 30,),
          ),
          onTap: ()async{
            File croppedFile = await cropImage(image);
            if (croppedFile!=null){
              image = croppedFile;
              setState(() {});
            }
          },
        ), onBack: (){Navigator.pop(context, image);}),
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
      ),
    );
  }
}