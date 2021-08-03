import 'package:card_app_bsk/cardPage.dart';
import 'package:card_app_bsk/createCategoryScreen.dart';
import 'package:card_app_bsk/userPage.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:card_app_bsk/backend/hiveStorage.dart';
import 'package:card_app_bsk/backend/database.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';


import 'main.dart';

class mainPage extends StatefulWidget {
  @override
  _mainPage createState() => _mainPage();
}


class _mainPage extends State<mainPage> {
  List<Map> categories = [];
  Map cards = {};
  bool _loading = true;
  double _width;
  String _currentState = '';
  String _activeCategory = ''; // тут храним ID категории, которую мы перемещаем
  String _activeZone = ''; // тут храним ID категории или промежуточного пространства, куда будет перетягиваться карта, для того, чтобы подсветить это место
  String _activeCard = ''; // тут храним ID карты, которую мы в данный момент перетягиваем
  ScrollController _scrollController = new ScrollController();

  // TODO: провести тест под опись с перетягиванием карты, проверить, что за флаг на index == 4
  reorderCard({@required mas, @required data, @required index})async{
    mas.removeWhere((element) => element['id']==data);
    int newI = index~/2;
    if (newI >= mas.length)
      newI-=1;
    if (index == 4)
      newI-=1;
    await localDB.db.reorderItems(cardsToUpdate: List.generate(mas.length+1, (di) {
      if (di<newI)
        return {'order': di, 'id': mas.removeAt(0)['id']};
      else if (di==newI)
        return {'order': di, 'id':data};
      else
        return {'order': di, 'id': mas.removeAt(0)['id']};
    }));
    setState(() {
      _loading = true;
      _activeZone = '';
      _activeCard = '';
    });
  }
  reorderCategory({@required mas, @required data, @required index})async{
    mas.removeWhere((element) => element['id']==data);
    int newI = index~/2;
    if (newI >= mas.length)
      newI-=1;
    if (index == 4)
      newI-=1;
    await localDB.db.reorderItems(categoriesToUpdate: List.generate(mas.length+1, (di) {
      if (di<newI)
        return {'order': di, 'id': mas.removeAt(0)['id']};
      else if (di==newI)
        return {'order': di, 'id':data};
      else
        return {'order': di, 'id': mas.removeAt(0)['id']};
    }));
    setState(() {
      _loading = true;
      _activeZone = '';
      _activeCategory = '';
    });
  }

  Widget dragPlaceTarget({@required mas, @required index, @required id, Function onAccept}){
    bool _movingAround = _activeCard.length>0;
    bool _primary = _activeZone==id;
    bool _lastPlacement = id=='LastID';
    return DragTarget<String>(
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected,){
        return AnimatedContainer(
          duration: Duration(milliseconds: 400),
          height: !_movingAround?5:_lastPlacement?cardExtended:_primary?cardExtended:40,
          width: _width,
          color: _primary?getColorForTile(10):Colors.transparent,
        );},
      onAccept:onAccept==null? (String data) async{
        reorderCard(mas: mas, data: data, index: index);
      }:onAccept,
      onMove: (data){
        if (!_primary)
          setState(() {
            _activeZone =id;
          });
      },
      onLeave: (data)async{
        setState(() {
          _activeZone = '';
        });
      },
    );
  }
  Widget dragCategoryTarget({@required mas, @required index, @required id, Function onAccept}){
    bool _movingAround = _activeCategory.length>0;
    bool _primary = _activeZone==id;
    bool _lastPlacement = false; // id=='LastID';
    return DragTarget<String>(
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected,){
        return AnimatedContainer(
          duration: Duration(milliseconds: 400),
          height: !_movingAround?5:_lastPlacement?cardExtended:_primary?cardExtended:40,
          width: _width,
          color: _primary?getColorForTile(10):Colors.transparent,
        );},
      onAccept:onAccept==null? (String data) async{
        reorderCategory(mas: mas, data: data, index: index);
      }:onAccept,
      onMove: (data){
        if (!_primary)
          setState(() {
            _activeZone =id;
          });
      },
      onLeave: (data)async{
        setState(() {
          _activeZone = '';
        });
      },
    );
  }
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
    bool _primary = _activeZone == _data['id'];
    bool _dragged = _activeCategory == _data['id'];
    Widget _item = GestureDetector(
      child: Card(
        elevation: 4.0,
        child: Stack(
          children: [
            _data['image']==null?SizedBox():Container(
              width: 300,
              height: cardExtended,
              child: Image.memory(_data['image'],fit: BoxFit.cover),
            ),
            Container(
              width: _dragged?(_width-48):300,
              height: cardExtended,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                children: [
                  Center(child: Text(_data['name'], style: def24,),),
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
          ],
        ),
      ),
      onTap: (){
        setState(() {
          _currentState = _data['id'];
        });
      },);
    Widget _itemFull = _primary?GestureDetector(
      child: Card(
        elevation: 16.0,
        color: getColorForTile(10),
        child: Stack(
          children: [
            _data['image']==null?SizedBox():Opacity(opacity: 0.4, child: Container(
              width: 300,
              height: cardExtended,
              child: Image.memory(_data['image'],fit: BoxFit.cover),
            ),),
            Container(
              height: cardExtended,
              width: 300,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                children: [
                  Center(child: Text(_data['name'], style: def24,),),
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
          ],
        ),
      ),
      onTap: (){
        setState(() {
          _currentState = _data['id'];
        });
      },):GestureDetector(
      child: Card(
        elevation: 4.0,
        child: Stack(
          children: [
            _data['image']==null?SizedBox():Container(
              width: 300,
              height: cardExtended,
              child: Image.memory(_data['image'],fit: BoxFit.cover),
            ),
            Container(
              width: _dragged?(_width-48):300,
              height: cardExtended,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                children: [
                  Center(child: Text(_data['name'], style: def24,),),
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
          ],
        ),
      ),
      onTap: (){
        setState(() {
          _currentState = _data['id'];
        });
      },);
    if (_activeCategory.length>0 && !_dragged)  return _item;
    return Listener(
      child: LongPressDraggable(child: DragTarget<String>(
        builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected,){
          return _itemFull;
        },
        onAccept: (String data) async{
          await localDB.db.moveCardToCategory(card_id: data, category_id: _data['id'], user: accountGuid);
          setState(() {_loading = true;_activeZone = '';});
        },
        onMove: (data){
          if (_activeZone!=_data['id'])
            setState(() {
              _activeZone = _data['id'];
            });
        },
        onLeave: (data){
          setState(() {
            _activeZone = '';
          });
        },), feedback: _itemFull, onDragStarted: (){
        setState(() {
          _activeCategory = _data['id'];
          _activeZone = 'activeCategory';
        });
      },
        onDraggableCanceled: (v, o){
          setState(() {
            _activeCategory = '';
            _activeZone = '';
          });
        },
        onDragCompleted: (){
          setState(() {
            _activeCategory = '';
            _activeZone = '';
          });
        },
        data: _data['id'],),
      onPointerMove: (PointerMoveEvent event) {
        if(_activeCategory == _data['id']){
          if (event.position.dy > MediaQuery.of(context).size.height) {
            _scrollController.animateTo(_scrollController.offset + cardHeight, duration: Duration(milliseconds: 200), curve: Curves.ease);
          }
          else if (event.position.dy < 40){
            _scrollController.animateTo(_scrollController.offset - cardHeight, duration: Duration(milliseconds: 200), curve: Curves.ease);
          }
        }
      },
    );
  }
  Widget cardTile(Map _data){
    String _id = _data['id'];
    Widget _item = Hero(
      tag: _data['id'],
      child: GestureDetector(
        child: Container(
          height: cardHeight,
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
                      _data['frontImage']==null?SizedBox():Container(
                        height: cardHeight,
                        width: _width*0.9,
                        child: Image.memory(_data['frontImage'],fit: BoxFit.cover),
                      ),
                      Center(
                        child: Text("Card: " + _id, style: def24,),
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
    Widget _full = Listener(
      child: LongPressDraggable<String>(
        feedback: _item,
        onDragStarted: (){
          setState(() {
            _activeCard = _data['id'];
            _activeZone = 'activeCard';
          });
        },
        onDraggableCanceled: (v, o){
          setState(() {
            _activeCard = '';
            _activeZone = '';
          });
        },
        onDragCompleted: (){
          setState(() {
            _activeCard = '';
            _activeZone = '';
          });
        },
        data: _id,
        childWhenDragging: Container(color: Colors.red, height: 120, width: _width,),
        child: _item,
      ),
      onPointerMove: (PointerMoveEvent event) {
        if(_activeCard == _id){
          if (event.position.dy > MediaQuery.of(context).size.height) {
            _scrollController.animateTo(_scrollController.offset + cardHeight, duration: Duration(milliseconds: 200), curve: Curves.ease);
          }
          else if (event.position.dy < 40){
            _scrollController.animateTo(_scrollController.offset - cardHeight, duration: Duration(milliseconds: 200), curve: Curves.ease);
          }
        }
      },
    );
    if (_currentState.length < 1)
      return _full;
    else
      return Dismissible(
        key: ValueKey(_data['id']),
        child: _full,
        onDismissed: (DismissDirection direction)async{
          await localDB.db.moveCardToCategory(card_id: _data['id'], category_id: null, user: accountGuid);
          setState(() {_loading = true;}); //TODO: проработать систему обновления данных, которая не будет затрагивать визуализацию
        },
      );
  }
  Widget categoriesColumn(){
    List _cats = List.from(categories);
    _cats.sort((a, b){
      return a['order']<b['order']?-1:1;
    });
    int _cur = _activeCategory.length>0?(_cats.indexWhere((element) => element['id']==_activeCategory)*2 + 1):-1;
    List<Widget> tiles = List.generate(_cats.length*2+1, (index) {
      String _id;
      if (index%2 == 1) {
        _id = _activeCategory == _cats[index ~/ 2]['id']? 'activeCategory':_cats[index ~/ 2]['id'];
        return _activeCategory == _cats[index ~/ 2]['id'] ? dragCategoryTarget(mas: _cats, index: index, id: index==_cats.length*2-1?'LastID':_id,onAccept: (data){return 0;}): categoryTile(_cats[index~/2]); // это виджет с картой, его можно будет перетянуть
      }
      else{
        if (index == _cur - 1 || index == _cur + 1)
          return SizedBox();
        _id = index==0?'firstID':index==_cats.length*2?'LastID':(_cats[index~/2]['id']+_cats[index~/2 - 1]['id']);
        return dragCategoryTarget(mas: _cats, index: index, id: _id);
      }
    });
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: tiles,
          ),
          GestureDetector(
            onTap: ()async{
              bool res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>createCategory()));
              if (res == null) res=false;
              if (res) setState(() {_loading = true;});
            },
            child: Container(
              height: cardHeight,
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
      ),
    );
  }
  Widget cardsColumn(String key){ //Category Key here
    if (!cards.containsKey(key))
      return Container();
    List _cards = List.from(cards[key]);
    _cards.sort((a, b){
      return a['order']<b['order']?-1:1;
    });
    int _cur = _activeCard.length>0?(_cards.indexWhere((element) => element['id']==_activeCard)*2 + 1):-1;
    List<Widget> tiles = List.generate(_cards.length*2 + 1, (index) {
      String _id;
      if (index%2 == 1) {
        _id = _activeCard == _cards[index ~/ 2]['id']? 'activeCard':_cards[index ~/ 2]['id'];
        return _activeCard == _cards[index ~/ 2]['id'] ? dragPlaceTarget(mas: _cards, index: index, id: index==_cards.length*2-1?'LastID':_id,onAccept: (data){return 0;}): cardTile(_cards[index ~/ 2]); // это виджет с картой, его можно будет перетянуть
      }
      else{
        if (index == _cur - 1 || index == _cur + 1)
          return SizedBox();
        _id = index==0?'firstID':index==_cards.length*2?'LastID':(_cards[index~/2]['id']+_cards[index~/2 - 1]['id']);
        return dragPlaceTarget(mas: _cards, index: index, id: _id);
      } // это виджет который является "площадью" между двумя картами или сверху и снизу от карт
    });
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
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

  creatNewCard()async{
    //await localDB.db.createCard(creator_id: accountGuid, cardName: 'testCard');
    String _curName = _currentState.length>0?categories[categories.indexWhere((element) => element['id']==_currentState)]['name']:'';
    bool res = await Navigator.push(context, MaterialPageRoute(builder: (context)=>newCard(_currentState, _curName)));
    if (res == null) res = false;
    if (res)
      setState(() {_loading = true;});
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
          child: ListView(
            controller: _scrollController,
            children: [
              categoriesColumn(),
              SizedBox(height: 6,),
              Divider(thickness: 2, height: 6,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12,),
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
          onPressed: creatNewCard,
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
            child: ListView(
              controller: _scrollController,
              children: [
                Container(
                  width: _width,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('В категории "' + categories[categories.indexWhere((element) => element['id']==_currentState)]['name'] + '" карт:'),
                      counter(_currentState),
                    ],
                  ),
                ),
                Divider(height: 6, thickness: 2,),
                cardsColumn(_currentState),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: creatNewCard,
          ),
        ),
      );
    }
  }
}