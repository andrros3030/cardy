import 'package:card_app_bsk/widgetsSettings.dart';
import 'package:flutter/material.dart';

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
                    child: Text("Card: " + cardData['id'], style: green24,),
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
            )
          ],
        ),
      ),
    );
  }
}