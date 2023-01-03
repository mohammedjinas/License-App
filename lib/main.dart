import 'dart:async';

import 'package:flutter/material.dart';
import 'package:license/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RetailX License',
      debugShowCheckedModeBanner: false,
      // routes: {'login' :(context) => const Login()},
      // initialRoute: 'login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  MyHomePage(title: 'RetailX License'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),
    ()=>Navigator.pushReplacement(context,
      MaterialPageRoute(builder:
        (context) => 
        Login()
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset("assets/images/logo.png")),
          SizedBox(height: 20,),
          Row( crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor), 
              SizedBox(width: 10,),
              DefaultTextStyle(child: Text("Loading...",), style: TextStyle(fontSize: 15,color: Colors.black87),)
            ],
          ),
        ],
      )
    );
  }
}
