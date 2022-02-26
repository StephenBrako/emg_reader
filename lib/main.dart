import 'package:flutter/material.dart';
import 'package:fsa/base_screen.dart';
import 'package:fsa/SizeConfig.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,



      home: wrapper(),


    );
  }


}
class wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          return ReserveScreen();
        });

  }}
