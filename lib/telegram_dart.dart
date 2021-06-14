
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
bool check_bd_method(String s){
  return true;//временно

}

disconnect_telegram(int id){

}


String create_new_tele_code(String alphabet){
  Random r = new Random();
  int q= r.nextInt(5);
  String s = "";
  for (int i = 0; i < (15 + q);++i){
    q = r.nextInt(6);
    s += alphabet[q];
  }
  bool check_bd = check_bd_method(s);
  if(check_bd)
    return s;
  if (!check_bd)
    return( create_new_tele_code(alphabet));
}


telegram_start(BuildContext context, bool is_connected, int id_flutter, int id_telegram){
  double height_context = MediaQuery.of(context).size.height;
  double width_context = MediaQuery.of(context).size.width;
  if (is_connected == false) {
    showDialog(
        context: context,
        builder: (context) {
          String tele_pass = create_new_tele_code("abcdefj");

          return SimpleDialog(shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))
              , children: [
                Container(width: 0.8 * min(height_context, width_context),
                  height: 0.6 * max(height_context, width_context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: SizedBox(), flex: 1,),
                      Expanded(flex: 1,child: Text("Чтобы подключить аккаунт к telegram, напишите сообщение с данным кодом боту @partanski. Код будет действителен 15 минут.", overflow: TextOverflow.clip,)),
                      Expanded(child: SizedBox(), flex: 1,),
                      Expanded(flex: 1,child: Text(tele_pass, overflow: TextOverflow.clip,)),
                      Expanded(child: SizedBox(), flex: 1,),
                      Expanded(child: Container(width: 150,height: 40, child: MaterialButton(child: Text("Скопировать"),onPressed: () async
                      {
                        print(tele_pass);
                        Clipboard.setData(new ClipboardData(text: tele_pass));
                        Fluttertoast.showToast(msg: "Код скопирован");
                      }
                      ,),), flex: 1,),
                      Expanded(child: SizedBox(), flex: 1,),
                      Expanded(child: Container(width: 150,height: 40, child: MaterialButton(child: Text("Написать %partanski"),onPressed: () async
                      {
                        launch("https://t.me");
                      }


                      ,),), flex: 1,),
                      Expanded(child: SizedBox(), flex: 1,),
                      Expanded(child: Container(width: 150,height: 40, child: MaterialButton(child: Text("Назад"),onPressed: ()
                      {
                        Navigator.pop(context);

                      } ,),), flex: 1,),


                    ],
                  ),
                )
              ]);
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
            Expanded(child: Container(child: MaterialButton(child: Text("Отмена"),)), flex: 1,),

            ]

        ),)
          ]);
    });
  }
}