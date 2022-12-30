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
      routes: {'login' :(context) => const Login()},
      initialRoute: 'login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home:  MyHomePage(title: 'RetailX License'),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
// throw UnimplementedError();
//   }
// }
