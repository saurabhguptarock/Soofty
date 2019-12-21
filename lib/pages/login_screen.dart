import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soofty/services/firebase_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool buttonInProgress = false;

  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTime', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
          ),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/icons/icon.png'),
                Padding(padding: EdgeInsets.only(left: 10)),
                Text(
                  'Soofty',
                  style: GoogleFonts.lato(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    textStyle: TextStyle(
                      color: Color.fromRGBO(27, 35, 69, 1),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 30)),
          Text(
            ' WhatsApp Video Status Maker',
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(padding: EdgeInsets.only(top: 50)),
          SizedBox(
            height: 55,
            width: MediaQuery.of(context).size.width * .8,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              color: Colors.white,
              child: SizedBox.expand(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.white,
                  child: !buttonInProgress
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/icons/google.webp',
                              height: 35,
                            ),
                            Padding(padding: EdgeInsets.only(right: 10)),
                            Text(
                              "Continue with Google",
                              style: GoogleFonts.lato(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                textStyle: TextStyle(
                                  color: Color.fromRGBO(27, 35, 69, 1),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SpinKitCircle(
                          color: Color(0xff7160FF),
                        ),
                  onPressed: () {
                    setState(() {
                      login();
                      buttonInProgress = true;
                    });

                    Future.delayed(Duration(seconds: 7), () {
                      if (mounted)
                        setState(() {
                          buttonInProgress = false;
                        });
                    });
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
