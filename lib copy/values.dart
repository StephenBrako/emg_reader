import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:fsa/initialpage.dart';
import 'package:fsa/reserve/widget/choose_date.dart';
import 'package:fsa/tiles.dart';
import 'package:fsa/widget/my_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;
import 'SizeConfig.dart';
import 'constant.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column,Row,Border,Alignment;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

class ValuePage extends StatefulWidget {
  final BluetoothDevice server;

  const ValuePage({this.server});

  @override
  _ValuePage createState() => new _ValuePage();
}

class _Message {
  int whom;
  String text;


  _Message(this.whom, this.text);
}

class _ValuePage extends State<ValuePage> {
  int a=11;
  int NU;
  List<List<dynamic>> employeeData;
  String newdata;
  List<LiveData> chartData;
  ChartSeriesController _chartSeriesController;
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  String filePath;

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.absolute.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    filePath = '$path/data.csv';
    return File('$path/data.csv').create();
  }
  ScrollController _controller2;





  @override
  void initState() {
    employeeData  = List<List<dynamic>>();
    NU=1;
    a=11;
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    Timer.periodic(const Duration(seconds: 10), updateDataSource1);


    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {

        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });


  }
  Future<void> createExcel() async {
    DateTime date = DateTime.now();

    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('Time');
    sheet.getRangeByName('B1').setText('Sensor Values');
    sheet.getRangeByName('A$NU').setText('${date.hour}:${date.minute}:${date.second}');
    sheet.getRangeByName('B$NU').setText(newdata);
    final List<int> bytes = workbook.saveAsStream();
   // workbook.dispose();
    NU+=1;

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/${date.day}:${date.month}:${date.year}_Output.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
  //  OpenFile.open(fileName);
  }

  getCsv11() async {
    DateTime date = DateTime.now();

    if (await Permission.storage.request().isGranted) {

//store file in documents folder

      String dir = (await getExternalStorageDirectory()).path + "/${date.day}:${date.month}:${date.year}-${date.second}_Output.xlsx.csv";
      String file = "$dir";

      File f = new File(file);

// convert rows to String and write as csv file

      String csv = const ListToCsvConverter().convert(employeeData);
      f.writeAsString(csv);
    }else{

      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  getCsv() async {

    List<List<dynamic>> rows = List<List<dynamic>>();
    rows.add([
      "Time",
      "Sensor Values",

    ]);
    DateTime date = DateTime.now();
    StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("2021-10-6").snapshots(),
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
                  List<dynamic> row = List<dynamic>();
                  row.add(doc["time"]);
                  row.add(doc["Sensor value"]);
                  rows.add(row);


                  return null;
                },


              ),
            ),
          );
        } else {
          return  null;
        }
      },
    );

      File f = await _localFile;

      String csv = const ListToCsvConverter().convert(rows);
      f.writeAsString(csv);
    }




  getCsv1() async {

    if (await Permission.storage.request().isGranted) {

//store file in documents folder

      String dir = (await getExternalStorageDirectory()).path + "/mycsv.csv";
      String file = "$dir";

      File f = new File(file);

// convert rows to String and write as csv file

      String csv = const ListToCsvConverter().convert(employeeData);
      f.writeAsString(csv);
    }else{

      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final List<Text> list2 = messages.map((_message) {
      return  Text(
              (text) {
            return text == '/shrug' ? '??\\_(???)_/??' : text;
          }(_message.text.trim()),
          style: TextStyle(color: mTitleTextColor,fontSize: 16));

    }).toList();
    final List<Text> list = messages.map((_message) {
      return  Text(
              (text) {
            return newdata=text;
          }(_message.text.trim()),
          style: TextStyle(color: mTitleTextColor,fontSize: 16));
    }).toList();




    SizeConfig().init(context);
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
                  height: SizeConfig.safeBlockVertical*7,
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
                      SizedBox(width: SizeConfig.safeBlockHorizontal*3,),

                      SizedBox(height:SizeConfig.safeBlockVertical*2,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: SizeConfig.safeBlockVertical*1,),
                          Text(
                            'Kofi Mensah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeConfig.safeBlockVertical*2,),
                          Text('NHS: 0229281111',style: TextStyle(fontSize: 15, color: Colors.white),),

                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical*6,
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal*4, vertical: SizeConfig.safeBlockVertical*1.2),
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
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal*3, vertical: SizeConfig.safeBlockVertical*0.5,),
            width: SizeConfig.safeBlockHorizontal*100,
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
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap:(){
                        setState(() {

                          a=11;
                          DateTime date = DateTime.now();
                          FirebaseFirestore.instance.collection("dates").doc("${date.year}-${date.month}-${date.day}").set({
                            "day": "${date.year}-${date.month}-${date.day}",
                          });
                        });
                      },
                      child:  Container(
                        width: SizeConfig.safeBlockHorizontal*25,
                        height: SizeConfig.safeBlockVertical*6,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          border: Border.all(
                              color: mTitleTextColor, width: 0.5),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Text(
                          "Start",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[

                        Text(
                          "Sensor values",
                          style: TextStyle(
                            color: mTitleTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(

                          height: SizeConfig.safeBlockVertical*1,
                        ),
                        Container(
                            width: SizeConfig.safeBlockHorizontal*40,
                            height: SizeConfig.safeBlockVertical*6,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:  Colors.transparent,
                              border: Border.all(
                                  color:  mTitleTextColor, width: 0.5),
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: list2.last
                        ),
                      ],
                    ),
                    GestureDetector(

                      onTap:(){
                        setState(() {
                          a=11111;
                        });
                        getCsv11();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return InitialPage(server: widget.server);

                            },
                          ),
                        );

                      },
                      child:Container(
                        width: SizeConfig.safeBlockHorizontal*25,
                        height: SizeConfig.safeBlockVertical*6,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(
                              color: mTitleTextColor, width: 0.5),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Text(
                          "Stop",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),),
                  ],
                ),

                SizedBox(
                  height: SizeConfig.safeBlockVertical*2,
                ),


                Text(
                  "graphs",
                  style: TextStyle(
                    color: mTitleTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),),

          Container(
            height: SizeConfig.safeBlockVertical*36,
            width: SizeConfig.safeBlockHorizontal*100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mBackgroundColor, mSecondBackgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),


            child: Container(
                width: SizeConfig.safeBlockHorizontal*95,

                child:
                Scaffold(
                    body: SfCartesianChart(
                        primaryXAxis: NumericAxis(
                            majorGridLines:  MajorGridLines(width: 0.2,color: mTitleTextColor,),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            interval: 0.2,
                            title: AxisTitle(text: 'Time(seconds)'),
                            axisLine: AxisLine(
                              color: Colors.deepOrange,
                              width: 1,
                            )),
                        primaryYAxis: NumericAxis(
                            majorGridLines:  MajorGridLines(width: 0.2,color: mTitleTextColor,),
                            axisLine:  AxisLine(width: 1,color: Colors.deepOrange,),
                            majorTickLines:  MajorTickLines(size: 0),
                            title: AxisTitle(text: 'Sensor Values (mV)')),
                        series: <ChartSeries>[
                          // Renders spline chart
                          SplineSeries<LiveData, int>(
                              onRendererCreated: (ChartSeriesController controller) {
                                _chartSeriesController = controller;
                              },
                              dataSource: chartData,
                              color: const Color.fromRGBO(192, 108, 132, 1),
                              xValueMapper: (LiveData sales, _) => sales.time,
                              yValueMapper: (LiveData sales, _) => sales.speed
                          )
                        ]
                    ))),

          ),





        ],
      ),
    );
  }



  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
          setState(() {
            //newdata= data.last;
            print(data.last);
          });

        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
  int time = 6;
  void updateDataSource(Timer timer) {

    if (a==11){
      setState(() {

        chartData.add(LiveData(time++, (double.parse(newdata))));
        print(_messageBuffer);
        chartData.removeAt(0);
        _chartSeriesController.updateDataSource(
            addedDataIndex: chartData.length - 1, removedDataIndex: 0);
      });
      DateTime date = DateTime.now();

      List<dynamic> row = List();
      row.add("Time : ${date.hour}:${date.minute}:${date.second}");
      row.add("Sensor Values : $newdata");
      employeeData.add(row);


    }
    else{
      setState(() {
        newdata="0";
      });


    }

  }

  void updateDataSource1(Timer timer) {
    if (a==11){
      setState(() {
        DateTime date = DateTime.now();
        if (newdata != null){
          String newdatata = newdata;
          FirebaseFirestore.instance.collection("${date.year}-${date.month}-${date.day}").doc("${date.hour}:${date.minute}:${date.second}").set({
            "Sensor value": "$newdatata",
            "time": "${date.hour}:${date.minute}:${date.second}"

          });



//row refer to each column of a row in csv file and rows refer to each row in a file




        }
        else{
          print("ddd");
        }


      });

    }
    else{
      setState(() {
        newdata="0";

      });
      print("ddd");

    }


  }




}
List<LiveData> getChartData() {
  return <LiveData>[
    LiveData(0, 42),
    LiveData(1, 47),
    LiveData(2, 43),
    LiveData(3, 49),
    LiveData(4, 54),

  ];
}

class LiveData {
  LiveData(this.time, this.speed);
  final int time;
  final num speed;
}
