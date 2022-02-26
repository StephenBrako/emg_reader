import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fsa/SizeConfig.dart';
import 'package:fsa/record.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fsa/constant.dart';
import 'package:fsa/reserve/widget/choose_date.dart';
import 'package:fsa/tiles.dart';
import 'package:fsa/widget/my_header.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;

import 'connection.dart';
import 'package:fsa/values.dart';

class ReserveScreen extends StatefulWidget {

  @override
  _ReserveScreenState createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  List<LiveData> chartData;
  ChartSeriesController _chartSeriesController;
  bool vis1=true;
  bool vis2=false;

  @override
  void initState() {
    chartData = getChartData();
    // Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Scaffold(
      body: Column(

        children: <Widget>[
          MyHeader(

            imageUrl: 'assets/images/pix.jpg',
            child: Column(
              children: <Widget>[
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row( crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/avatar.png',
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(width: 10,),

                      SizedBox(height: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 8,),
                          Text(
                            'Bawa Anthony',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text('NHS: XXXXXXXXXXXXX',style: TextStyle(fontSize: 15, color: Colors.white),),

                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child:  Row( mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: GestureDetector(
                            onTap: (){
                              var route = PageRouteBuilder(pageBuilder: (context, animation1, animation2)=>tiles());
                              Navigator.of(context).push(route);
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: mButtonColor,
                                border: Border.all(
                                    color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),

                              child: Text(
                                'View Readings',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          )
                      ),

                    ],
                  ),),


              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mBackgroundColor, mSecondBackgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[


                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ChooseDate(
                      week: 'Sensor Value',
                      date: 'none',
                    ),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),


                Text(
                  "select a device",
                  style: TextStyle(
                    color: mTitleTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),),

          Container(
            height: 301,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mBackgroundColor, mSecondBackgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),


            child:  SelectBondedDevicePage(
              onCahtPage: (device1) {
                BluetoothDevice device = device1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ValuePage(server: device);

                    },
                  ),
                );
              },
            ),

          ),





        ],
      ),
    );
  }
  void sendvalues(list){
    DateTime date = DateTime.now();
    FirebaseFirestore.instance.collection("${date.year}-${date.month}-${date.day}").doc("${date.hour}:${date.minute}:${date.second}").set({
      "Sensor value": "$list",
      "time": "${date.hour}:${date.minute}:${date.second}"

    });
    print("$list");
  }
  int time = 19;
  void updateDataSource(Timer timer) {
    chartData.add(LiveData(time++, (math.Random().nextInt(60) + 30)));
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }
}
List<LiveData> getChartData() {
  return <LiveData>[
    LiveData(0, 42),
    LiveData(1, 47),
    LiveData(2, 43),
    LiveData(3, 49),
    LiveData(4, 54),
    LiveData(5, 41),
    LiveData(6, 58),
    LiveData(7, 51),
    LiveData(8, 98),
    LiveData(9, 41),
    LiveData(10, 53),
    LiveData(11, 72),
    LiveData(12, 86),
    LiveData(13, 52),
    LiveData(14, 94),
    LiveData(15, 92),
    LiveData(16, 86),
    LiveData(17, 72),
    LiveData(18, 94)
  ];
}

class LiveData {
  LiveData(this.time, this.speed);
  final int time;
  final num speed;
}