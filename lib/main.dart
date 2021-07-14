import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:market_map/screens/login.dart';
import 'package:market_map/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Market Map',
      theme: ThemeData(
        errorColor: Colors.red[600],
        primarySwatch: Colors.lime,
        //buttonColor:Colors.cyan[600] ,
        primaryColor: Colors.lime,
        brightness: Brightness.light,
        splashColor: Colors.tealAccent[700],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Wrapper(),
      routes: {
        '/login': (context) => LoginPage(),
      },
    );
  }
}
