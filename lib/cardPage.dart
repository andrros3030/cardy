import 'package:card_app_bsk/backend/database.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class cardPage extends StatefulWidget {
  Map cardData;
  cardPage(this.cardData);
  @override
  _cardPage createState() => _cardPage(this.cardData);
}

class _cardPage extends State<cardPage> {
  double _width;
  Map cardData;
  _cardPage(this.cardData);

  Widget cardBig(){
    return Container(
      height: 160/0.9,
      width: _width,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
            color:Colors.white,
            boxShadow: [BoxShadow(
              color: Color.fromRGBO(228, 228, 231, 0.8),
              blurRadius: 10.0,
              spreadRadius: 2.0,
              //offset: Offset(1,0)
            )
            ],
            borderRadius: BorderRadius.circular(8)
        ),
        child: Card(
          elevation: 0.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Stack(
                children: [
                  Center(
                    child: Text("Card: " + cardData['id'], style: def24,),
                  ),
                  Positioned(
                      right: 0.0,
                      top: 0.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(2, (index) => Column(
                                  children: List.generate(3, (index) => Container(
                                    width: 4.0,
                                    height: 4.0,
                                    margin: EdgeInsets.only(bottom: 2, right: 2),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromRGBO(46, 48, 52, 0.2)
                                    ),
                                  ))
                              ))
                          ),
                        ],
                      )
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }

  Widget actions(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cardData['name'].toString().length > 0?Container(width: _width, alignment: Alignment.center, child: Text(cardData['name'], style: def24,), padding: EdgeInsets.only(bottom: 12),):SizedBox(),
        cardData['access'] == mainAccessInt?SizedBox(height: 12,):Container(padding: EdgeInsets.only(top:12),child: Text(cardData['access'] > mainAccessInt?'Владелец карты разрешил Вам делиться этой картой':'Владелец карты запретил Вам делиться этой картой')),
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
    return Scaffold(
      appBar: appBarUsual(context, _width),
      body: Container(
        width: _width,
        child: ListView(
          children: [
            Hero(
              tag: cardData['id'],
              child: cardBig(),
            ),
            Divider(height: 4, thickness: 2,),
            actions(),
          ],
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
  String catID;
  String catName;

  _newCard(this.catID, this.catName);

  double _width;
  int images = 0;
  Map<String, List> _imageData = {
    'front': [],
    'back': []
  };

  Widget pictureTaker() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_imageData['front'].length == 0)
            _imageData['front'] = ['newImage'];
          else
            _imageData['back'] = ['newImage'];
          images += 1;
        });
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
    return Container(
      width: 64 * 2.0,
      height: 48 * 2.0,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: primaryDark, width: 3),
              color: primaryLight,
            ),
            padding: EdgeInsets.all(12),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(index == 0 ? 'Лицевая' : 'Оборотная', style: white16,),
          ),
          Align(),
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              child: Container(
                alignment: Alignment.center,
                child: Icon(Icons.delete, color: Colors.red, size: 30,),
                padding: EdgeInsets.all(4),
                width: 40,
                height: 40,
              ),
              onTap: () async {
                setState(() {
                  _imageData[index == 0 ? 'front' : 'back'] = [];
                  images -= 1;
                });
              },
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
    if (images == 1)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _imageData['front'].length > 0 ? pictureBuilder(0) : pictureTaker(),
          _imageData['front'].length > 0 ? pictureTaker() : pictureBuilder(1),
        ],
      );
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          pictureBuilder(0),
          pictureBuilder(1),
        ]
    );
  }


  @override
  Widget build(BuildContext context) {
    bool _unsorted = catID.length == 0;
    _width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: appBarUsual(context, _width,
          child: Text('Добавьте новую карту', style: white20,)),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(_unsorted
                  ? 'Карта появится в списке неотсортированных'
                  : ('Карта будет сразу добавлена в категорию ' + catName),
                style: black16, textAlign: TextAlign.center,),
              decoration: BoxDecoration(
                color: Color(0xFFFFFACC),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            SizedBox(height: 6,),
            Divider(height: 6, thickness: 2,),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                  "Добавьте изображение карты, если на ней есть штрихкод"),
            ),
            AnimatedContainer(
              width: _width,
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 6),
              child: imageRow(),
            ),
          ],
        ),
      ),
    );
  }
}