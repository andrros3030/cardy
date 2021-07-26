import 'package:card_app_bsk/cardPage.dart';
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
  double _width;
  String _currentState = '';

  Widget counter(String key){
    return Container(
      alignment: Alignment.center,
      child: Text(cards.containsKey(key)?cards[key].length.toString():'0', style: white20,),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: backgroundColor),
      padding: EdgeInsets.all(4),
      width: 40,
      height: 40,
    );
  }
  Widget categoryTile(Map _data){
    return GestureDetector(
      child: Card(
        elevation: 8.0,
        child: Container(
          height: 160,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Stack(
            children: [
              Center(child: Text(_data['name'], style: green24,),),
              Align(
                alignment: Alignment.topRight,
                child: counter(_data['id']),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(Icons.delete, color: Colors.red, size: 30,),
                    //decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.all(4),
                    width: 40,
                    height: 40,
                  ),
                  onTap: ()async {
                    bool res = await showDialog(context: context, builder: (context){return SimpleDialog(
                      title: Text('Если Вы удалите категорию все карты из нее вернуться в список неотсортированных'),
                      children: [
                        TextButton(onPressed: (){Navigator.pop(context, true);}, child: Text('Удалить категорию', style: red16,)),
                        TextButton(onPressed: (){Navigator.pop(context, false);}, child: Text('Отмена', style: grey16,))
                      ],
                    );});
                    if (res == null) res = false;
                    if (res){
                      await localDB.db.removeCategory(_data['id']);
                      setState(() {
                        _loading = true;
                      });
                    }

                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        setState(() {
          _currentState = _data['id'];
        });
      },
    );
  }
  Widget cardTile(Map _data){
    String _id = _data['id'];
    Widget _item = Hero(
      tag: _data['id'],
      child: GestureDetector(
        child: Container(
          height: 160,
          width: _width*0.9,
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
        ),
        onTap: ()async{
          bool res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>cardPage(_data)));
          if (res == null) res = false;
          if (res)
            setState(() {
              _loading = true;
            });
        },
      ),
    );
    if (_currentState.length < 1)
      return _item;
    /*Draggable<String>(
        feedback: _item,
        data: _id,
        childWhenDragging: Container(
          decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(30)),
          height: 160,
          width: _width*0.9,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text('Перетените карту в категорию и отпустите. Чтобы сменить очередность, удерживайте карту чуть-чуть дольше)'),
        ),
        child: _item,
      );*/
    else
      return Dismissible(
        key: ValueKey(_data['id']),
        child: _item,
        onDismissed: (DismissDirection direction)async{
          await localDB.db.moveCardToCategory(card_id: _data['id'], category_id: null, user: accountGuid);
          setState(() {_loading = true;}); //TODO: проработать систему обновления данных, которая не будет затрагивать визуализацию
        },
      );
  }
  Widget categoriesColumn(){
    List _cats = List.from(categories);
    _cats.sort((a, b){
      return a['order']<b['order']?-1:1; //TODO: протестировать на корректном наборе данных, возможно поменять местами? может напрямую вычитать?
    });
    List<Widget> tiles = List.generate(_cats.length, (index) {
      return ReorderableWidget(
        key: ValueKey(_cats[index]['id']),
        reorderable: true,
        child: categoryTile(_cats[index]),
      );
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableColumn(
          onReorder: (int oldI, int newI) async{
            var tile = _cats.removeAt(oldI);
            await localDB.db.reorderItems(categoriesToUpdate: List.generate(_cats.length+1, (index) {
              if (index<newI)
                return {'order': index, 'id': _cats[index]['id']};
              else if (index==newI)
                return {'order': index, 'id': tile['id']};
              else
                return {'order': index, 'id': _cats[index-1]['id']};
            }));
            setState((){_loading = true;});
          },
          children: tiles,
        ),
        GestureDetector(
          onTap: ()async{
            await localDB.db.createCategory(cardName: 'super name', creator_id: accountGuid);
            setState(() {
              _loading = true;
            });
          },
          child: Container(
            height: 160,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Card(
              color: primaryDark,
              elevation: 8.0,
              child: Center(child: Text("Добавить категорию", style: white24,)),
            ),
          ),
        ),
      ],
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
        child: cardTile(_cards[index]),
      );
    });
    return Container(
      child: ReorderableColumn(
        scrollController: ScrollController(),
        mainAxisSize: MainAxisSize.min,
        onReorder: (int oldI, int newI) async{
          var tile = _cards.removeAt(oldI);
          await localDB.db.reorderItems(cardsToUpdate: List.generate(_cards.length+1, (index) {
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
      ),
    );
  }
  Widget searcher(String _state){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      width: _width - 96,
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
    _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    if (_loading){
      loadData();
    }
    if (_currentState.length < 1)
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
                    counter(null),
                  ],
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
    else{
      return WillPopScope(
        onWillPop: ()async{
          setState(() {
            _currentState = '';
          });
          return false;
        },
        child: Scaffold(
          appBar: appBarUsual(context, _width, child: searcher(_currentState), onBack: (){setState(() {
            _currentState = '';
          });}),
          body: _loading?Center(child: CircularProgressIndicator()):Container(
            width: _width,
            height: _height - appBarHeight,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: cardsColumn(_currentState),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: ()async{
              await localDB.db.createCard(creator_id: accountGuid, cardName: 'testCard', category: _currentState);
              setState(() {
                _loading = true;
              });
            },
          ),
        ),
      );
    }
  }
}