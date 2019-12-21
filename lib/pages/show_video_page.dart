import 'dart:io';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';

class ShowVideoPage extends StatefulWidget {
  final File file;
  final String thumbPath;
  final String name;

  const ShowVideoPage({Key key, this.file, this.thumbPath, this.name})
      : super(key: key);
  @override
  _ShowVideoPageState createState() => _ShowVideoPageState();
}

class _ShowVideoPageState extends State<ShowVideoPage> {
  bool _isPlaying = true;
  bool _hideInitialy = true;
  VideoPlayerController _controller;
  bool _shouldPlay = false;
  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Show Video Page');
    _controller = VideoPlayerController.file(widget.file)
      ..initialize()
      ..setLooping(true)
      ..play().then((t) {
        setState(() {
          _shouldPlay = true;
        });
      });
    super.initState();
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
                        widget.name + '.mp4',
                        widget.file.readAsBytesSync().buffer.asUint8List(),
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
          ],
        ),
      ),
    );
  }
}
