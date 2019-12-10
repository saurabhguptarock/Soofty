import 'package:flutter/material.dart';
import 'package:soofty/pages/home_page.dart';
import 'package:soofty/services/firebase_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soofty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    demo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenPage();
  }
}
