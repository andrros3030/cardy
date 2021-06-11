import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:card_app_bsk/backend/hiveStorage.dart';
import 'package:card_app_bsk/backend/database.dart';
import 'package:reorderables/reorderables.dart';


import 'main.dart';

class mainPage extends StatefulWidget {
  @override
  _mainPage createState() => _mainPage();
}


class _mainPage extends State<mainPage> {
  List categories = [];
  Map cards = {};
  bool _loading = true;

  Widget categoriesColumn(){
    List<Widget> tiles = List.generate(categories.length, (index) {
      return Container(
        //TODO: implement list building
      );
    });
    tiles.add(Container(
      height: 160,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Card(
        elevation: 8.0,
        child: Center(child: Text("Добавить категорию", style: green24,)),
      ),
    ));
    return Column(
      children: tiles,
    );
  }

  Widget cardsColumn(){
    List<Widget> tiles = List.generate(cards[null], (index) {
      return Container(
        height: 160,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Card(
          elevation: 8.0,
          child: Center(child: Text("Добавить категорию", style: green24,)),
        ),
      );
    });
    return Column();
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
      appBar: AppBar(),
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
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
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