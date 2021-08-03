import 'dart:math';

import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:card_app_bsk/backend/database.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';


class createCategory extends StatefulWidget {
  @override
  _createCategoryPage createState() => _createCategoryPage();
}

class _createCategoryPage extends State<createCategory> {
  int _r = new Random().nextInt(100);
  int _stage = 0;
  double _width;
  String _categoryName = '';
  String _imageChoosen = '';
  FocusNode _nameFocus = new FocusNode();
  var _formKey = new GlobalKey<FormState>();
  bool _loading = true;
  List _imageData = [];

  _createCategory() async {
    await localDB.db.createCategory(cardName: _categoryName, creator_id: accountGuid, imageID: _imageChoosen.length>0?_imageChoosen:null);
    Future.delayed(Duration(seconds: 2)).then((value){Navigator.pop(context, true);});
  }

  Widget _nameField(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: disabledGrey, width: 1), borderRadius: BorderRadius.circular(4), color: Colors.white),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "Название категории",
          labelStyle: grey16,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
        maxLength: 30,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        maxLines: 1,
        focusNode: _nameFocus,
        initialValue: _categoryName,
        style: black16,
        onChanged: (val) {
          _categoryName = val;
          setState(() {});
        },
        validator: (val){
          if (val.length<5)
            return "Название категории не меньше 5 символов";
          if (val.length>30)
            return 'Название должно быть до 30 символов';
          return null;
        },
      ),
    );
  }

  Widget _content(){
    switch(_stage){
      case 0:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text('Выберите подходящее изображение для Вашей категории', style: black16, textAlign: TextAlign.center,),
              SizedBox(height: 6,),
              _imageData.length>0?Wrap(
                children: List.generate(_imageData.length, (index) => GestureDetector(
                  child: Container(child: Image.memory(_imageData[index]['image']), width: 150, height: 100,),
                  onTap: (){
                    _imageChoosen = _imageData[index]['id'];
                    _categoryName = _imageData[index]['name'];
                    setState(() {
                      _stage+=1;
                    });
                  },
                ),),
              ):Text('Нам не удалось отобразить заготовленные изображения :(', style: red16,),
              SizedBox(height: 12,),
              Text('Или пропустите этот шаг :)', style: grey16, textAlign: TextAlign.center,),
              defButton(onPressed: (){
                _categoryName = '';
                _imageChoosen = '';
                setState(() {
                _stage +=1;
              });}, child: Text('Пропустить', style: white20,)),
            ],
          ),
        );
        break;
      case 1:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
            children: [
              Container(child: _nameField(), padding: EdgeInsets.symmetric(horizontal:12, vertical: 6),),
              SizedBox(height: 12,),
              defButton(
                onPressed: _categoryName.length>0&&_formKey.currentState.validate()?(){
                  _createCategory();
                  setState(() {
                    _stage+=1;
                  });
                }:null,
                child: Text('Далее', style: white20,),
              ),
            ],
          ),
        );
        break;
    }
    return Container();
  }

  _loadData()async{
    _imageData = await localDB.db.categoriesPresets();
    setState(() {
      _loading = false;
    });
  }

  onBack()async{
    if (_stage == 0){
      bool _res = true; // TODO: add simpledialog here
      if (_res==null) _res=false;
      if (_res) Navigator.pop(context);
    }
    else
      setState(() {
        _stage-=1;
      });
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    if(_loading){
      _loadData();
      return Scaffold(
        appBar: appBarUsual(context, _width, child: Text('Новая категория', style: white24,)),
        body:GestureDetector(
          onTap: (){
            _nameFocus.unfocus();
          },
          child: Form(
            autovalidateMode: AutovalidateMode.always, key: _formKey,
            child: Container(
              width: _width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              color: getColorForTile(_r+_stage),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }
    if(_stage == 2)
      return WillPopScope(
        onWillPop: () async {return false;},
        child: Scaffold(
          body: Container(
            width: _width,
            padding: EdgeInsets.all(24),
            height: MediaQuery
                .of(context)
                .size
                .height,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryLight, primaryDark],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done_all, color: Colors.white, size: 36,),
                SizedBox(height: 24,),
                Text(
                  'Категория успешно добавлена в Ваш кошелек!', style: white24,
                  textAlign: TextAlign.center,),
              ],
            ),
          ),
        ),
      );
    return WillPopScope(
      onWillPop: ()async{
        onBack();
        return false;
      },
      child: Scaffold(
        appBar: appBarUsual(context, _width, child: Text('Новая категория', style: white24,), onBack: onBack),
        body:GestureDetector(
          onTap: (){
            _nameFocus.unfocus();
          },
          child: Form(
            autovalidateMode: AutovalidateMode.always, key: _formKey,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 800),
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: _width,
              alignment: Alignment.center,
              color: getColorForTile(_r+_stage),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: ListView(
                  children: [_content()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}