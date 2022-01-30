import 'package:card_app_bsk/backend/database.dart';
import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

disconnect_telegram(int id){

}

telegram_start(BuildContext context, bool is_connected, int id_flutter, int id_telegram)async{
  String tele_pass = await localDB.db.generateTelegramKey();
  double height_context = MediaQuery.of(context).size.height;
  double width_context = MediaQuery.of(context).size.width;
  if (is_connected == false) {
    showDialog(context: context, builder: (context) {
          return SimpleDialog(shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  width: 0.8 * min(height_context, width_context),
                  height: 0.6 * max(height_context, width_context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Чтобы подключить аккаунт к telegram, напишите сообщение с данным кодом боту @TODO. Код будет действителен 15 минут.", overflow: TextOverflow.clip, textAlign: TextAlign.center,),
                      Expanded(child: SizedBox(), flex: 1,),
                      defButton(onPressed: () async
                      {
                        launch("https://t.me/"+tele_pass); //TODO: edit link to bot + start key
                      },
                        text:"Запустить бота",
                      ),
                      Expanded(child: SizedBox(), flex: 1,),
                      defButton(onPressed: () async
                        {
                          print(tele_pass); //TODO: start key
                          Clipboard.setData(new ClipboardData(text: tele_pass));
                          Fluttertoast.showToast(msg: "Код скопирован");
                        },
                        color: primaryLight,
                        child: Text("Скопировать", style: white16,)
                      ),
                      Expanded(child: SizedBox(), flex: 1,),
                      defButton(onPressed: () {Navigator.pop(context);},
                          color: primaryLight,
                          text: "Назад",
                      ),
                      Expanded(child: SizedBox(), flex: 1,),
                    ],
                  ),
                )
              ],);
        }
    );
  }
  if (is_connected){
    showDialog(context: context, builder: (context){
      return SimpleDialog(shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10.0))
      , children: [
        Container(width: 300,height: 300,child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Expanded(child: SizedBox(), flex: 1,),
            Expanded(child: Text("Вы уверены? Отменить это действие будет невозможно"), flex: 1,),
            Expanded(child: SizedBox(), flex: 1,),
            Expanded(child: Container(child: MaterialButton(onPressed: () async
            {
              await disconnect_telegram(id_flutter);
              Fluttertoast.showToast(msg: "Код скопирован");

            }
            ,child: Text("Отсоедениться"),)), flex: 1,),
              Expanded(child: SizedBox(), flex: 1,),
            Expanded(child: Container(child: MaterialButton(child: Text("Отмена"), onPressed: (){
              return;
            },),), flex: 1,),
            ]

        ),)
          ]);
    });
  }
}