import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fsa/constant.dart';

import 'SizeConfig.dart';

class readings extends StatefulWidget {
  final String date;
  readings(this.date);
  @override
  State<StatefulWidget> createState() {

    return _readingsState(this.date);
  }
}
class _readingsState extends State<readings> {
  Timer debouncer;
  String date;
  _readingsState(this.date);

  void debounce(
      VoidCallback callback, {
        Duration duration = const Duration(milliseconds: 100),
      }) {
    if (debouncer != null) {
      debouncer.cancel();
    }

    debouncer = Timer(duration, callback);
  }
  ScrollController _controller2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Records for ${widget.date}',
          style: TextStyle(color: mTitleTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,


        centerTitle: true,
      ),
      body:  Container(
        color:Colors.blueGrey.withOpacity(0.3) ,
        width: SizeConfig.safeBlockHorizontal*99,

          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(widget.date).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new Padding(padding: EdgeInsets.only(right:5,left: 5, bottom: 5,top: 5),
                  child: SizedBox(
                    height: SizeConfig.safeBlockVertical*90,
                    child:  new ListView.builder(
                      controller: _controller2,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data.docs[index];


                        return new Card(

                            child:Padding(padding: EdgeInsets.all(5),
                              child:

                                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [

                                      Text("Time: ${doc["time"]}",style: TextStyle(fontSize: 16),),
                                      Text("Sensor Value: ${doc["Sensor value"]}",style: TextStyle(fontSize: 16),),


                                ],
                              ),)
                        );
                      },


                    ),
                  ),
                );
              } else {
                return Center(
                  child: Text("No data"),
                );
              }
            },
          ),
        ),

    );
  }
}
