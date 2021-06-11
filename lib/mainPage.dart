import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';
import 'package:card_app_bsk/backend/hiveStorage.dart';
import 'package:card_app_bsk/backend/database.dart';

import 'main.dart';

class mainPage extends StatefulWidget {
  @override
  _mainPage createState() => _mainPage();
}


class _mainPage extends State<mainPage> {
  @override
  Widget build(BuildContext context) {
    debugPrint("newBuild");
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          accountGuid + unchekedEmail.toString()
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
        onPressed: (){
          localDB.db.createCard(creator_id: accountGuid, cardName: 'testCard');
        },
      ),
    );
  }
}