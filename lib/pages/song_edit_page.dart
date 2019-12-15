import 'package:flutter/material.dart';
import '../main.dart';

class SongEditPage extends StatefulWidget {
  @override
  _SongEditPageState createState() => _SongEditPageState();
}

class _SongEditPageState extends State<SongEditPage> {
  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Song Edit Page');
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
