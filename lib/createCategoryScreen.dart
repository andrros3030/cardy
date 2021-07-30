import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:card_app_bsk/backend/database.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/iconic_icons.dart';


class createCategory extends StatefulWidget {
  @override
  _createCategoryPage createState() => _createCategoryPage();
}

class _createCategoryPage extends State<createCategory> {
  double _width;
  String _categoryName = '';
  String _iconChoosen = 'mark';
  String _colorChoosen = '0xff4caf50';
  String _bgChoosen = '0xffffffff';
  TextEditingController _name = TextEditingController();
  FocusNode _nameFocus = new FocusNode();
  var _formKey = new GlobalKey<FormState>();

  _createCategory() async {
    await localDB.db.createCategory(cardName: 'super name', creator_id: accountGuid);
  }

  Widget _nameField(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: disabledGrey, width: 1), borderRadius: BorderRadius.circular(4)),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "Название",
          labelStyle: grey16,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
        maxLength: 30,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        maxLines: 1,
        focusNode: _nameFocus,
        controller: _name,
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

  Widget _preView(){
    List _icons = List.from(preLoadedIcons.keys);
    List _colors = List.from(preLoadedColors.keys);
    return Container(
      width: _width,
      child: Column(
        children: [
          Text('Подберите подходящее оформление для категории', style: def16, textAlign: TextAlign.center,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonHideUnderline(child: DropdownButton<String>(
                items: List.generate(_colors.length, (index){
                  return DropdownMenuItem(child: Container(width: 24, height: 24, color: preLoadedColors[_colors[index]],), value: _colors[index],);
                }),
                value: _colorChoosen,
                onChanged: (s){
                  setState(() {
                    _colorChoosen = s;
                  });
                },
              )),
              Card(
                color: preLoadedColors[_bgChoosen],
                elevation: 4.0 ,
                child: Container(
                  alignment: Alignment.center,
                  width:  150,
                  height: cardExtended/2,
                  child: DropdownButton<String>(
                    items: List.generate(_icons.length, (index){
                      return DropdownMenuItem(child: Icon(preLoadedIcons[_icons[index]], color: preLoadedColors[_colorChoosen],size: 36,), value: _icons[index],);
                    }),
                    value: _iconChoosen,
                    onChanged: (s){
                      setState(() {
                        _iconChoosen = s;
                      });
                    },
                  ),
                ),
              ),
              DropdownButton<String>(
                items: List.generate(_colors.length, (index){
                  return DropdownMenuItem(child: Container(width: 24, height: 24, color: preLoadedColors[_colors[index]],), value: _colors[index],);
                }),
                value: _bgChoosen,
                onChanged: (s){
                  setState(() {
                    _bgChoosen = s;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
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
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
              children: [
                Container(child: _nameField(), padding: EdgeInsets.symmetric(horizontal:12, vertical: 6),),
                Container(child: _preView(), width: _width, alignment: Alignment.center,),
                defButton(onPressed: _categoryName.length>0&&_formKey.currentState.validate()?(){}:null),
              ],
            ),
          ),
        ),
      ),
    );
  }
}