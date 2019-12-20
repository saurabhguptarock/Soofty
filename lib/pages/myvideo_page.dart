import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyVideoPage extends StatefulWidget {
  @override
  _MyVideoPageState createState() => _MyVideoPageState();
}

class _MyVideoPageState extends State<MyVideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Under Development',
            style: GoogleFonts.lato(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
