import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fsa/constant.dart';
import 'package:fsa/readings.dart';

import 'SizeConfig.dart';
class tiles extends StatefulWidget {
  @override
  _tilesState createState() => _tilesState();
}

class _tilesState extends State<tiles> {

  Timer debouncer;


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
          'Select Date',
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
            stream: FirebaseFirestore.instance.collection("dates").snapshots(),
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
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  SizedBox(width: 5,),
                                  Column(
                                      children: [
                                        Text("${doc["day"]}",style: TextStyle(fontSize: 17, fontWeight:FontWeight.w600),),


                                      ]),
                                  SizedBox(width: 5,),
                                  ElevatedButton(onPressed:(){
                                    setState(() {
                                      var userid = "${doc["day"]}";


                                      var route = PageRouteBuilder(pageBuilder: (context, animation1, animation2)=>readings(userid));
                                      Navigator.of(context).push(route);



                                    });


                                  }, child: Text("view")),
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
