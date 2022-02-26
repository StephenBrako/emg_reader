import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:typed_data';
import 'package:fsa/reserve/widget/choose_date.dart';
import 'package:fsa/widget/my_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;
import 'SizeConfig.dart';
import 'constant.dart';
import 'dart:io';
import 'package:csv/csv.dart';



class RecordPage extends StatefulWidget {
  final BluetoothDevice server;

  const RecordPage({this.server});

  @override
  _RecordPage createState() => new _RecordPage();
}

class _Message {
  int whom;
  String text;


  _Message(this.whom, this.text);
}


class _RecordPage extends State<RecordPage> {
  String newdata="0";
  List<LiveData> chartData;
  dynamic recordlist;
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
  List<List<dynamic>> employeeData;

  @override
  void initState() {
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
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

  getCsv(list) async {

    if (await Permission.storage.request().isGranted) {

//store file in documents folder

      String dir = (await getExternalStorageDirectory()).path + "/sensorreadings.csv";
      String file = "$dir";

      File f = new File(file);

// convert rows to String and write as csv file

      String csv = const ListToCsvConverter().convert(list);
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
    final List<Text> list3 = messages.map((_message) {
      return  Text(
              (text) {
            return newdata=text;
          }(_message.text.trim()),
          style: TextStyle(color: mTitleTextColor,fontSize: 16));
    }).toList();

    final List<Text> list2 = messages.map((_message) {
      return  Text(
              (text) {
            return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
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
                            'Bawa Anthony',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeConfig.safeBlockVertical*2,),
                          Text('NHS: XXXXXXXXXXXXX',style: TextStyle(fontSize: 15, color: Colors.white),),

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
                                'Send Readings',
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
                     onTap: (){
                      // startrecording();
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
                      onTap: (){
                        getCsv(list2);
                        //stoprecording(recordlist);
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
                        backgroundColor: mSecondBackgroundColor,
                        series: <LineSeries<LiveData, int>>[
                          LineSeries<LiveData, int>(
                            onRendererCreated: (ChartSeriesController controller) {
                              _chartSeriesController = controller;
                            },
                            dataSource: chartData,
                            color: const Color.fromRGBO(192, 108, 132, 1),
                            xValueMapper: (LiveData sales, _) => sales.time,
                            yValueMapper: (LiveData sales, _) => sales.speed,
                          )
                        ],
                        primaryXAxis: NumericAxis(
                            majorGridLines:  MajorGridLines(width: 0.2,color: mTitleTextColor,),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            interval: 0.2,
                            title: AxisTitle(text: 'Time (seconds)'),
                            axisLine: AxisLine(
                              color: Colors.deepOrange,
                              width: 1,
                            )),

                        primaryYAxis: NumericAxis(
                            majorGridLines:  MajorGridLines(width: 0.2,color: mTitleTextColor,),
                            axisLine:  AxisLine(width: 1,color: Colors.deepOrange,),
                            majorTickLines:  MajorTickLines(size: 0),
                            title: AxisTitle(text: 'Sensor Values (mV)'))))),

          ),





        ],
      ),
    );
  }
  startrecording(){
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                    (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();
    setState(() {
      recordlist=list;
    });
  }
  void stoprecording(list){
    getCsv(list);
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
  int time = 2;
  void updateDataSource(Timer timer) {
    chartData.add(LiveData(time++, (double.parse(newdata))));
    print(_messageBuffer);
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }
}
List<LiveData> getChartData() {
  return <LiveData>[
    LiveData(0, 0),


  ];
}

class LiveData {
  LiveData(this.time, this.speed);
  final int time;
  final num speed;
}
