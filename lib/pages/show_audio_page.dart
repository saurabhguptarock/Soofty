import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:soofty/model/model.dart';
import 'package:soofty/pages/song_edit_page.dart';
import '../main.dart';

class ShowAudioPage extends StatefulWidget {
  final MusicFiles musicFiles;

  const ShowAudioPage({Key key, this.musicFiles}) : super(key: key);
  @override
  _ShowAudioPageState createState() => _ShowAudioPageState();
}

class _ShowAudioPageState extends State<ShowAudioPage> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool _isPlaying = true;
  bool _hideInitialy = true;
  double rating = 0;

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Show Audio Page');
    play(widget.musicFiles.audioUrl);
    super.initState();
  }

  @override
  void dispose() {
    stop();
    audioPlayer?.dispose();
    super.dispose();
  }

  void play(String url) async {
    int result1 = await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    int result2 = await audioPlayer.play(url);
    if (result1 == 1 && result2 == 1) {
    } else {}
  }

  void pause() async {
    int result = await audioPlayer.pause();
    if (result == 1) {
    } else {}
  }

  void resume() async {
    int result = await audioPlayer.resume();
    if (result == 1) {
    } else {}
  }

  void stop() async {
    int result = await audioPlayer.stop();
    if (result == 1) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.yellow,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (mounted)
                  setState(() {
                    _hideInitialy = false;
                    _isPlaying ? pause() : resume();
                    _isPlaying = !_isPlaying;
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
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.musicFiles.img,
                      placeholder: (context, url) =>
                          Image.asset('assets/images/wallfy.webp'),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/wallfy.webp'),
                    ),
                  ),
                  if (!_hideInitialy)
                    _isPlaying
                        ? Positioned(
                            bottom: MediaQuery.of(context).size.height / 2 - 40,
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
                            bottom: MediaQuery.of(context).size.height / 2 - 40,
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
              bottom: 120,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: SizedBox(
                width: 100,
                height: 40,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => SongEditPage(
                        musicFiles: widget.musicFiles,
                      ),
                    ));
                  },
                  child: Text(
                    'Create',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: MediaQuery.of(context).padding.top + 30,
              child: SmoothStarRating(
                  allowHalfRating: false,
                  onRatingChanged: (v) {
                    setState(() {
                      rating = v;
                    });
                  },
                  starCount: 5,
                  rating: rating,
                  size: 30.0,
                  color: Colors.white,
                  borderColor: Colors.white,
                  spacing: 0.0),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
