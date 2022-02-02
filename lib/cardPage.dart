import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:card_app_bsk/backend/database.dart';
import 'package:card_app_bsk/backend/imageScreen.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';



class cardPage extends StatefulWidget {
  Map cardData;
  cardPage(this.cardData);
  @override
  _cardPage createState() => _cardPage(this.cardData);
}

class _cardPage extends State<cardPage> {
  double _width;
  PageController _controller = PageController();
  int _imageNumber = 0;
  Map cardData;
  _cardPage(this.cardData);

  Widget cardBig(){
    List<Widget> _images = [Hero(
      tag: cardData['id'],
      child: GestureDetector(
          onTap: cardData['frontImage']==null?null:(){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>showFullImage(null, imageData: cardData['frontImage'],)));
          },
          child: Container(
            decoration: BoxDecoration(
              color:Colors.white,
              boxShadow: [BoxShadow(
                color: Color.fromRGBO(228, 228, 231, 0.8),
                blurRadius: 10.0,
                spreadRadius: 2.0,)],
              borderRadius: BorderRadius.circular(8)
          ),
            child: Card(
            elevation: 8.0,
            child: cardData['frontImage']==null?Center(child: Text("Карта без изображения"),):Container(
              width: _width,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              height: cardExtended,
              child: Image.memory(cardData['frontImage'], fit: BoxFit.scaleDown,),
            ),
          ),
      ),
        ),
    )];
    if (cardData['backImage']!=null){
      _images.add(
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>showFullImage(null, imageData: cardData['backImage'],)));
            },
            child: Container(
              decoration: BoxDecoration(
                  color:Colors.white,
                  boxShadow: [BoxShadow(
                    color: Color.fromRGBO(228, 228, 231, 0.8),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,)],
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Card(
                elevation: 8.0,
                child: Container(
                  width: _width,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  height: cardExtended,
                  child: Image.memory(cardData['backImage'], fit: BoxFit.scaleDown,),
                ),
              ),
            ),
          )
      );
    }
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: cardExtended+40,
      child: Column(
        children: [
          Container(
            height: cardExtended,
            width: _width,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: PageView.builder(
              controller: _controller,
              physics: _images.length==1?NeverScrollableScrollPhysics():null,
              itemBuilder: (cntxt, index){
                return _images[index%_images.length];
              },
              onPageChanged: (i) {
                setState(() {
                  _imageNumber = i % _images.length;
                });
              },
              itemCount: _images.length,
            ),
          ),
          Container(
            width: _width,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (index) => GestureDetector(
                child: GestureDetector(
                  onTap: (){
                    _controller.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.ease);
                  },
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.only(bottom: 10, right: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _imageNumber == index
                          ? Color.fromRGBO(0, 0, 0, 0.9)
                          : Color.fromRGBO(0, 0, 0, 0.2),
                    ),
                  ),
                ),
              ),),
            ),
          ),
        ],
      ),
    );
  }

  FocusNode _noteFocus = new FocusNode();
  TextEditingController _note = new TextEditingController();
  bool textChange = false;
  saveText()async{
    _noteFocus.unfocus();
    await localDB.db.saveNote(cardID: cardData['id'], noteText: cardData['note']);
    textChange = false;
    if(mounted)
      setState(() {});
  }
  Widget _noteField(){
    //if (cardData['note']==null)
    //  cardData['note'] = '';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: disabledGrey, width: 1), borderRadius: BorderRadius.circular(4)),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "Заметка",
          labelStyle: grey16,
          contentPadding: EdgeInsets.zero,
          counterText: '',
          hintText: 'Добавьте сюда ключевые слова, они могут пригодиться при поиске карты :)',
          hintMaxLines: 4,
        ),
        //initialValue: cardData['note'],
        maxLength: noteLength,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        expands: false,
        maxLines: null,
        minLines: 1,
        focusNode: _noteFocus,
        controller: _note,
        style: black16,
        onChanged: (val) {
          cardData['note'] = val;
          textChange = true;
        },
      ),
    );
  }

  Widget actions(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cardData['name'].toString().length > 0?Container(width: _width, alignment: Alignment.center, child: Text(cardData['name'], style: def24,), padding: EdgeInsets.only(bottom: 12),):SizedBox(),
        cardData['access'] == mainAccessInt?SizedBox(height: 12,):Container(padding: EdgeInsets.only(top:12),child: Text(cardData['access'] > mainAccessInt?'Владелец карты разрешил Вам делиться этой картой':'Владелец карты запретил Вам делиться этой картой')),
        SizedBox(height: 12,),
        _noteField(),
        SizedBox(height: 12,),
        defButton(
          onPressed: cardData['access'] >= mainAccessInt? (){}:null, //TODO: предложить варианты, как поделиться картой
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.share, color: Colors.white,),
              SizedBox(width: 6,),
              Text('Поделиться', style: white20,),
            ],
          ),
        ),
        defButton(
          onPressed: ()async{
            bool res = await showDialog(context: context, builder: (context){
              return SimpleDialog(
                title: Text(cardData['access'] == mainAccessInt?'Карта будет удалена из Вашего кошелька и из кошельков тех людей, которым Вы предоставили доступ к этой карте!':'Вы потеряете доступ к этой карте и не сможете восстановить его самостоятельно'),
                children: [
                  TextButton(onPressed: (){Navigator.pop(context, true);}, child: Text('Удалить', style: red16,),),
                  TextButton(onPressed: (){Navigator.pop(context, false);}, child: Text('Отмена', style: grey16,))
                ],
              );},);
            if (res == null) res = false;
            if (res){
              await localDB.db.removeCard(cardData['id'], removeCard: cardData['access'] == mainAccessInt);
              Navigator.pop(context, true);
            }
          },
          color: Colors.red,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, color: Colors.white,),
              SizedBox(width: 6,),
              Text('Удалить карту', style: white20,),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    _note.text = cardData['note'];
    return WillPopScope(
      onWillPop: ()async{
        if(!textChange)
          return true;
        else{
          await saveText();
          return true;
        }
      },
      child: Scaffold(
        appBar: appBarUsual(context, _width),
        body: GestureDetector(
          onTap: (){
            saveText();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6),
            width: _width,
            child: ListView(
              children: [
                cardBig(),
                Divider(height: 4, thickness: 2,),
                actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class newCard extends StatefulWidget{
  String catID;
  String catName;
  newCard(this.catID, this.catName);
  @override
  _newCard createState() => _newCard(catID, catName);
}

class _newCard extends State<newCard> {
  final _picker = ImagePicker();
  String catID;
  String catName;

  _newCard(this.catID, this.catName);

  double _width;
  int _r = new Random().nextInt(100);
  int images = 0; // тут храним колличество изображений, если 0 - необходимо требовать nfc-метку (иначе карта - пустая)
  int _actionIndex = 0; // тут храним порядковый номер сцены (картинка -> название -> nfc-метка -> завершающая сцена)
  String _cardName = '';
  String _nfcData = '';
  bool _loadingNFC = false;

  _loadNFC()async{
    setState(() {
      _loadingNFC = true;
    });
    Future.delayed(Duration(seconds: 2)).then((value){
      setState(() {
        _nfcData = 'some text data here';
        _loadingNFC = false;
      });
    });
  }

  List<File> _imageData = [null, null]; // тут хранятся объекты File, которые при создании карты будут конвертированы в base64 string

  //собсна сам выбор изображения, вызывается по нажатию одной из двух кнопок и запускает плагин
  Future<File> _getImage(ImageSource source)async{
    try{
      final _picked = await _picker.pickImage(source: source, preferredCameraDevice: CameraDevice.rear);
      if (_picked!=null)
        return File(_picked.path);
      else
        return null;
    }
    catch(e){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Ошибка доступа к камере',); //TODO: привести к дизайну
      return null;
    }
  }

  _checkFile(var file, BuildContext context, bool needSave)async{
    if (file==null)
      debugPrint("incorrect");
    //await _ifImageNull(context);
    else{
      File imageFile = file;
      Navigator.pop(context, imageFile);
    }
  }

  _removeImage(int index)async{
    setState(() {
      _imageData[index] = null;
      images -= 1;
    });
  }

  loadImage() async{
    File res = await showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryDark,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: IconButton(
                      icon: Icon(Icons.photo_camera, color: Colors.white,),
                      onPressed: ()async{
                        var res = await _getImage(ImageSource.camera);
                        await _checkFile(res, context, false);
                      }
                  ),
                ),
                SizedBox(height: 5,),
                Text("Камера", style: grey16,),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryDark,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: IconButton(
                    icon: Icon(Icons.photo, color: Colors.white),
                    onPressed: ()async{
                      var res = await _getImage(ImageSource.gallery);
                      await _checkFile(res, context, false);
                    },
                  ),
                ),
                SizedBox(height: 5,),
                Text("Галерея", style: grey16,),
              ],
            )
          ],
        ),
      );
    },);
    if (res!=null){
      images+=1;
      if (_imageData[0]==null)
        _imageData[0] = res;
      else
        _imageData[1] = res;
      setState(() {});
    }
    //return res;
  }

  Widget pictureTaker() {
    return GestureDetector(
      onTap: () {
        loadImage();
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: primaryDark, width: 3)
        ),
        padding: EdgeInsets.all(12),
        child: Icon(Icons.camera_alt_outlined, color: primaryDark, size: 36,),
      ),
    );
  }

  Widget pictureBuilder(int index) {
    File _cur = _imageData[index];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Card(
            elevation: 8.0,
            child: Container(
              width: _width*0.9,
              height: cardExtended,
              child: Container(
                child: GestureDetector(
                  onTap: ()async{
                    File _res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>showFullImage(_cur, canEdit:true,)));
                    if (_res == null){
                      _removeImage(index);
                    }
                    else{
                      _imageData[index] = _res;
                      setState((){});
                    }
                  },
                  child: Container(
                    child: Image.file(
                      _cur,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: _width*0.9-8,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryDark, primaryLight], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
            ),
            child: Row(
              children: [
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(Icons.delete, color: Colors.red, size: 30,),
                    padding: EdgeInsets.all(4),
                    width: 40,
                    height: 40,
                  ),
                  onTap:(){ _removeImage(index);},
                ),
                Expanded(child: Text(index == 0 ? 'Лицевая' : 'Оборотная', style: white16, textAlign: TextAlign.center,),),
                GestureDetector(
                  onTap: ()async{
                    File croppedFile = await cropImage(_cur);
                    if (croppedFile!=null){
                      if (index==0)
                        _imageData[0] = croppedFile;
                      else
                        _imageData[1] = croppedFile;
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.crop, color: Colors.white, size: 30,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageRow() {
    if (images == 0)
      return Container(
        width: _width,
        alignment: Alignment.topCenter,
        child: pictureTaker(),
      );
    return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        runSpacing: 6.0,
        children: [
          _imageData[0]!=null ? pictureBuilder(0) : pictureTaker(),
          _imageData[1]!=null ? pictureBuilder(1): pictureTaker(),
        ]
    );
  }

  onBack()async{
    if (_actionIndex == 0){
      bool _res = true; // TODO: add simpledialog here
      if (_res==null) _res=false;
      if (_res) Navigator.pop(context);
    }
    else
      setState(() {
        _actionIndex-=1;
      });
  }

  Widget hintBox(String hint){
    return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        width: _width,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFD7B9F3).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Color(0xFFD7B9F3),),
              SizedBox(width: 8,),
              Flexible(
                child: Opacity(child: Text(hint, style: black16,), opacity: 0.6,),
              ),
            ],
          ),
        ),
      );
  }

  Widget contentBuilder(){
    switch (_actionIndex){
      case 0:
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                    "Добавьте изображение карты, если на ней есть штрихкод", style: black16, textAlign: TextAlign.center,),
              ),
              SizedBox(height: 15,),
              Container(
                width: _width,
                padding: EdgeInsets.symmetric(vertical: 6),
                child: imageRow(),
              ),
              hintBox('Сделайте качественное изображение карты, чтобы штрихкод или номер легко читался.\nПосле выбора изображения обрежьте его под формат карты.'),
            ],
          ),
        );
        break;
      case 1:
        return Container(
          height: MediaQuery.of(context).size.height-100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(
                      color: disabledGrey, width: 1
                  ), borderRadius: BorderRadius.circular(4)),
                  child: TextFormField(
                    validator: (val){
                      if (val.length>36)
                        return 'Название карты не должно превышать 36 символов';
                      return null;
                    },
                    initialValue: _cardName,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Название карты",
                      hintStyle: grey16,
                      errorMaxLines: 3,
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    style: black16,
                    onChanged: (val){
                      setState(() {
                        _cardName = val;
                      });
                    },
                  ),
                ),
              ),
              hintBox('Карты с NFC без изображения необходимо назвать, чтобы они не потерялись!'),
            ],
          ),
        );
        break;
      case 2:
        return hintBox('Тут будет процесс добавления nfc метки');
        break;
      case 3:
        return Container();
        break;
    }
    return Container();
  }

  //храним в этой переменной флаг - было ли начато завершение сеанса, чтобы второй раз не запустить его
  bool alreadyClosing = false;
  //метод преобразует данные в необходимые для sql и сохраняет карту, после чего закрывает окно
  closeTab()async{
    alreadyClosing = true;
    Uint8List b1, b2;
    if (_imageData[0] != null)
      b1 = await _imageData[0].readAsBytes();
    if (_imageData[1] != null)
      b2 = await _imageData[1].readAsBytes();

    if (b1 == null&& b2 != null){
      b1 = Uint8List.fromList(b2);
      b2 = null;
    }
    localDB.db.createCard(
      creator_id: accountGuid,
      category: catID.length>0?catID:null,
      cardName: _cardName.length>0?_cardName:null,
      blob1: b1!=null?base64Encode(b1):null, blob2: b2!=null?base64Encode(b2):null
    );
      Future.delayed(Duration(seconds: 2)).then((value){
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool _unsorted = catID.length == 0;
    _width = MediaQuery.of(context).size.width;
    if (_actionIndex == 3){
      if (!alreadyClosing)
        closeTab();
      return WillPopScope(
        onWillPop: ()async{return false;},
        child: Scaffold(
          body: Container(
            width: _width,
            padding: EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: bottomGradient.colors, begin: Alignment.bottomRight, end: Alignment.topLeft),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done_all, color: Colors.white, size: 36,),
                SizedBox(height: 24,),
                Text('Карта успешно добавлена в Ваш кошелек!', style: white24, textAlign: TextAlign.center,),
              ],
            ),
          ),
        ),
      );
    }
    return WillPopScope(
      onWillPop: ()async{
        await onBack();
        return false;
      },
      child: Scaffold(
        appBar: appBarUsual(context, _width, child: Text('Добавьте новую карту', style: white20,), onBack: onBack,),
        body: Stack(
          children: [
            AnimatedContainer(
              color: getColorForTile(_actionIndex+_r),
              duration: Duration(milliseconds: 800),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: [
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /*
                          SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(_unsorted ? 'Карта появится в списке неотсортированных' : ('Карта будет сразу добавлена в категорию ' + catName), style: black16, textAlign: TextAlign.center,),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFACC),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black, offset: Offset(0.5, 1), blurRadius: 2.0)]
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                           */
                          SizedBox(height: 6),
                          Form(
                            autovalidateMode: AutovalidateMode.always, child: contentBuilder(),
                          ),
                          SizedBox(height: 6),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              alignment: Alignment.bottomRight,
              child: _actionIndex==0?defButton(
                  text: images==0?'Пропустить':'Далее',
                  color: primaryDark,
                  onPressed: () {setState(() {
                    _actionIndex+=1;
                  });}):_actionIndex==1?defButton(
                  onPressed: (_cardName.length==0 && images==0)?null:(){
                    setState((){
                      _actionIndex+=1;
                    });
                  },
                  text: (_cardName.length==0 && images>0)?'Пропустить':'Далее',
                  color: primaryDark
              ):images!=0?defButton(onPressed: (){
                setState(() {
                  _actionIndex+=1;
                });
              }, color: primaryLight, text: 'Пропустить',):defButton(
                onPressed: _loadingNFC?null:(){
                  if (_nfcData.length==0){
                    _loadNFC();
                  }
                  else{
                    setState(() {
                      _actionIndex+=1;
                    });
                  }
                },
                child: _loadingNFC?CircularProgressIndicator():Text(_nfcData.length==0?'Скопировать NFC-метку':'Добавить карту', style: white16),
              ),
            ),
          ]
        ),
      ),
    );
  }
}