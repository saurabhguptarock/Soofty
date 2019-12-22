import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:soofty/pages/myvideo_page.dart';
import 'package:video_player/video_player.dart';
import 'package:soofty/model/model.dart';
import 'package:soofty/pages/home_page.dart';
import '../main.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:soofty/services/firebase_service.dart' as firebaseService;

class ExportPage extends StatefulWidget {
  final MusicFiles musicFiles;
  final String fileName;
  const ExportPage({Key key, this.musicFiles, this.fileName}) : super(key: key);

  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _isPlaying = true;
  bool _hideInitialy = true;
  File _file;
  VideoPlayerController _controller;
  bool _shouldPlay = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  User _user;

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Export Page');
    _controller = VideoPlayerController.file(File(widget.fileName))
      ..initialize()
      ..setLooping(true)
      ..play().then((t) {
        setState(() {
          _shouldPlay = true;
        });
      });
    play();
    initialize();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    super.initState();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => StreamProvider<User>.value(
          value: firebaseService.streamUser(_user.uid),
          initialData: User.fromMap({}),
          child: MyVideoPage(),
        ),
      ),
    );
  }

  void initialize() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.saverl.soofty', 'Soofty', 'WhatsApp Video Status Maker',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Export Complete',
        '${widget.musicFiles.name}', platformChannelSpecifics,
        payload: '${widget.musicFiles.name}');
  }

  void play() {
    File file = File(widget.fileName);
    setState(() {
      _file = file;
    });
    try {} catch (e) {
      print(e);
    }
  }

  void pause() async {
    await _controller.pause();
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void resume() async {
    await _controller.play();
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    _user = user;
    return Scaffold(
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 60,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                Share.file(
                        'title',
                        widget.musicFiles.name + '.mp4',
                        _file.readAsBytesSync().buffer.asUint8List(),
                        'video/mp4')
                    .then((v) {
                  if (_controller.value.isPlaying) pause();
                });
              },
              child: Icon(FontAwesomeIcons.share),
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 100,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (mounted)
                  setState(() {
                    _hideInitialy = false;
                    _isPlaying ? pause() : resume();
                  });
                Future.delayed(Duration(seconds: 3), () {
                  if (mounted)
                    setState(() {
                      _hideInitialy = true;
                    });
                });
              },
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 70,
                    left: 30,
                    child: Card(
                      elevation: 5,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: _shouldPlay
                            ? Container(
                                height: MediaQuery.of(context).size.height - 50,
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10)), //TODO: round the border
                                child: VideoPlayer(_controller),
                              )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height - 250,
                                width: MediaQuery.of(context).size.width - 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    'Please try again later',
                                    style: GoogleFonts.lato(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (!_hideInitialy)
                    _isPlaying
                        ? Positioned(
                            bottom:
                                MediaQuery.of(context).size.height / 2 - 100,
                            left: MediaQuery.of(context).size.width / 2 - 40,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Color.fromRGBO(0, 0, 0, 0.54),
                              child: Icon(
                                FontAwesomeIcons.play,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Positioned(
                            bottom:
                                MediaQuery.of(context).size.height / 2 - 100,
                            left: MediaQuery.of(context).size.width / 2 - 40,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Color.fromRGBO(0, 0, 0, 0.54),
                              child: Icon(
                                FontAwesomeIcons.pause,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 10,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) => StreamProvider<User>.value(
                            value: firebaseService.streamUser(user.uid),
                            initialData: User.fromMap({}),
                            child: HomePage()),
                      ),
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 110,
                    decoration: BoxDecoration(
                        color: Color(0xff7160FF),
                        borderRadius: BorderRadius.circular(50)),
                    child: Center(
                        child: Text(
                      'Back To Home',
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(color: Colors.white)),
                    )),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
