import 'package:card_app_bsk/userPage.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:card_app_bsk/backend/hiveStorage.dart';
import 'package:card_app_bsk/backend/database.dart';
import 'package:reorderables/reorderables.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';


import 'main.dart';

class mainPage extends StatefulWidget {
  @override
  _mainPage createState() => _mainPage();
}


class _mainPage extends State<mainPage> {
  List categories = [];
  Map cards = {};
  bool _loading = true;


  Widget cardTile(Map _data){
    String _id = _data['id'];
    return GestureDetector(
      onTap: (){

      },
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
                    child: Text("Card: " + _id, style: green24,),
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

  Widget categoriesColumn(){
    List<Widget> tiles = List.generate(categories.length, (index) {
      return Container(
        //TODO: implement list building
      );
    });
    tiles.add(GestureDetector(
      onTap: (){
        localDB.db.createCategory(accountGuid);
      },
      child: Container(
        height: 160,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Card(
          elevation: 8.0,
          child: Center(child: Text("Добавить категорию", style: green24,)),
        ),
      ),
    ));
    return Column(
      children: tiles,
    );
  }

  Widget cardsColumn(String key){ //Category Key here
    if (!cards.containsKey(key))
      return Container();
    List _cards = List.from(cards[key]);
    _cards.sort((a, b){
      return a['order']<b['order']?-1:1; //TODO: протестировать на корректном наборе данных, возможно поменять местами? может напрямую вычитать?
    });
    List<Widget> tiles = List.generate(_cards.length, (index) {
      String _id = _cards[index]['id'];
      return ReorderableWidget(
        key: ValueKey(_id),
        reorderable: true,
        child: Container(
          height: 160,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12),
          child: cardTile(_cards[index]),
        ),
      );
    });
    return ReorderableColumn(
      onReorder: (int oldI, int newI) async{
        int realNew = newI<oldI?newI-1:newI;
        debugPrint('oldI: ' + oldI.toString() + ' newI: ' + newI.toString());
        debugPrint("realNew: "+realNew.toString());
        var tile = _cards.removeAt(oldI);
        debugPrint('tile: '+tile.toString());
        debugPrint('pre: '+_cards.toString());
        await localDB.db.reorderCards(cardsToUpdate: List.generate(_cards.length+1, (index) {
          if (index<newI)
            return {'order': index, 'id': _cards[index]['id']};
          else if (index==newI)
            return {'order': index, 'id': tile['id']};
          else
            return {'order': index, 'id': _cards[index-1]['id']};
        }));
        setState((){_loading = true;});
      },
      children: tiles,
    );
  }

  loadData()async{
    Map _tmp = await localDB.db.getUserCardsNCategories(acc_id: accountGuid);
    cards = _tmp["cards"];
    categories = _tmp['categories'];
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    if (_loading){
      loadData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          width: _width*0.8,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: TextFormField(
            maxLines: 1,
            decoration: InputDecoration(
              suffixIcon: Container(
                child: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading?Center(child: CircularProgressIndicator()):Container(
        width: _width,
        height: _height - appBarHeight,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: ListView(
          children: [
            categoriesColumn(),
            SizedBox(height: 6,),
            Divider(thickness: 4.0, height: 6.5,),
            Container(
              width: _width,
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Неотсортированные карты: '),
                  Container(
                    alignment: Alignment.center,
                    child: Text(cards.containsKey(null)?cards[null].length.toString():'0', style: white20,),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: backgroundColor),
                    padding: EdgeInsets.all(4),
                    width: 40,
                    height: 40,
                ),],
              ),
            ),
            SizedBox(height: 6,),
            cardsColumn(null),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryDark,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('User settings'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => userPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Exit'),
              onTap: (){
                closeAccount();
                start();
                while (Navigator.of(context).canPop())
                  Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: ()async{
          await localDB.db.createCard(creator_id: accountGuid, cardName: 'testCard');
          setState(() {
            _loading = true;
          });
        },
      ),
    );
  }
}