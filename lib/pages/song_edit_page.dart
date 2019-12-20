import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:soofty/shared/shared_code.dart';
import 'package:soofty/uuid/uuid.dart';
import '../main.dart';
import 'package:soofty/model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

import 'export_page.dart';

class SongEditPage extends StatefulWidget {
  final MusicFiles musicFiles;

  const SongEditPage({Key key, this.musicFiles}) : super(key: key);

  @override
  _SongEditPageState createState() => _SongEditPageState();
}

class _SongEditPageState extends State<SongEditPage> {
  static final MobileAdTargetingInfo mobileAdTargetingInfo =
      MobileAdTargetingInfo(
    keywords: ['camera', 'music', 'image', 'status', 'video', 'whatsapp'],
    testDevices: <String>[
      '36451F1875A8B63DE36BF6E55DFDEC43',
      'A9A49FCD4F98BA5214A35A277221824D'
    ],
    childDirected: false,
  );
  AudioPlayer audioPlayer = AudioPlayer();
  bool _isPlaying = true;
  bool _hideInitialy = true;
  int _noOfImages = 1;
  List<File> _images = List(10);
  InterstitialAd _interstitialAd;
  bool _canShowAds = true;
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  ProgressDialog pr;

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Song Edit Page');
    // play(widget.musicFiles.audioUrl);
    // loadInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    stop();
    audioPlayer?.dispose();
    _interstitialAd?.dispose();
    _flutterFFmpeg?.cancel();
    super.dispose();
  }

  void play(String url) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    try {
      int result1 = await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
      int result2 = await audioPlayer.play(
          '$tempPath/Downloads/${widget.musicFiles.name}.m4a',
          isLocal: true);
      if (result1 == 1 && result2 == 1) {
      } else {}
    } catch (e) {
      print(e);
    }
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

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: interstitialAdId,
        targetingInfo: mobileAdTargetingInfo,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.opened) {
            setState(() {
              _canShowAds = false;
            });
            Future.delayed(Duration(seconds: 30), () {
              setState(() {
                _canShowAds = true;
              });
            });
          }
        });
  }

  void loadInterstitialAd() {
    _interstitialAd = createInterstitialAd()..load();
  }

  void showInterstitialAd() {
    if (_canShowAds) {
      _interstitialAd..show();
      loadInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 50,
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
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 70,
                    left: 40,
                    child: Card(
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: widget.musicFiles.img,
                        placeholder: (context, url) =>
                            Image.asset('assets/images/wallfy.webp'),
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/images/wallfy.webp'),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.fill)),
                          height: MediaQuery.of(context).size.height - 250,
                          width: MediaQuery.of(context).size.width - 80,
                        ),
                      ),
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
              bottom: 5,
              left: 10,
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width - 20,
                child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for (var i = 0; i < _noOfImages; i++)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: GestureDetector(
                              onTap: () async {
                                var image = await ImagePicker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() {
                                  if (image != null) _images[i] = image;
                                });
                                if (image != null) {
                                  var croppedImage =
                                      await ImageCropper.cropImage(
                                    sourcePath: _images[i].path,
                                    aspectRatioPresets: [
                                      CropAspectRatioPreset.square,
                                      CropAspectRatioPreset.ratio3x2,
                                      CropAspectRatioPreset.original,
                                      CropAspectRatioPreset.ratio4x3,
                                      CropAspectRatioPreset.ratio16x9
                                    ],
                                    androidUiSettings: AndroidUiSettings(
                                      toolbarColor: Colors.blue,
                                      toolbarWidgetColor: Colors.white,
                                      initAspectRatio:
                                          CropAspectRatioPreset.original,
                                      lockAspectRatio: false,
                                    ),
                                  );
                                  setState(() {
                                    _images[i] = croppedImage;
                                  });
                                }
                              },
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: _images[i] == null
                                          ? AssetImage(
                                              'assets/images/wallfy.webp')
                                          : FileImage(_images[i]),
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(FontAwesomeIcons.plusCircle),
                              ),
                            ),
                          ),
                        if (_noOfImages < 10)
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _noOfImages++;
                                });
                              },
                              child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(Icons.add_a_photo)),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
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
                  onTap: () async {
                    pr = ProgressDialog(context,
                        isDismissible: false,
                        type: ProgressDialogType.Download);
                    pr.style(
                      message: 'Downloading...',
                      borderRadius: 10.0,
                      backgroundColor: Colors.white,
                      progressWidget: SpinKitCubeGrid(
                        color: Colors.blue,
                        size: 50,
                      ),
                      elevation: 10.0,
                      insetAnimCurve: Curves.easeInOut,
                      progress: 0.0,
                      maxProgress: 100.0,
                      progressTextStyle: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold),
                      ),
                      messageTextStyle: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 19.0,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                    pr.show();
                    var uuid = Uuid();
                    Directory tempDir =
                        await getApplicationDocumentsDirectory();
                    String tempPath = tempDir.path;
                    String fileContent = '';
                    _images.forEach((f) {
                      try {
                        fileContent += 'file ' + '${f.path}\n';
                      } catch (e) {}
                    });
                    File('$tempPath/Downloads/args.txt')
                        .openWrite()
                        .write(fileContent);
                    String txt = await File('$tempPath/Downloads/args.txt')
                        .readAsString();
                    print(txt);

                    _flutterFFmpeg
                        .getMediaInformation(
                            '$tempPath/Downloads/${widget.musicFiles.name}.m4a')
                        .then((info) {
                      print("Media Information");
                      print("Path: ${info['path']}");
                      print("Format: ${info['format']}");
                      print("Duration: ${info['duration']}");
                      print("Start time: ${info['startTime']}");
                      print("Bitrate: ${info['bitrate']}");
                    });
                    double frameRate = _noOfImages / 30;
                    String uniqueId = uuid.v1();
                    int ans1 = await _flutterFFmpeg.executeWithArguments([
                      '-r',
                      '$frameRate',
                      '-f',
                      'image2',
                      '-f',
                      'concat',
                      '-safe',
                      '0',
                      '-i',
                      '$tempPath/Downloads/args.txt',
                      '-vcodec',
                      'mpeg4',
                      '-s',
                      '720x1280',
                      '-q',
                      '5',
                      '-pix_fmt',
                      'yuv420p',
                      '$tempPath/Downloads/${user.uid}_${uniqueId}_1.mp4'
                    ]);
                    int ans2 = await _flutterFFmpeg.executeWithArguments([
                      '-i',
                      '$tempPath/Downloads/${user.uid}_${uniqueId}_1.mp4',
                      '-i',
                      '$tempPath/Downloads/${widget.musicFiles.name}.m4a',
                      '-c',
                      'copy',
                      '-map',
                      '0:v:0',
                      '-map',
                      '1:a:0',
                      '$tempPath/Downloads/${user.uid}_${uniqueId}_2.mp4'
                    ]);
                    if (ans1 == 0 && ans2 == 0) {
                      // showInterstitialAd();
                      // stop();
                      pr.dismiss();
                      Share.file(
                          'title',
                          widget.musicFiles.name + '.mp4',
                          File('$tempPath/Downloads/${user.uid}_${uniqueId}_2.mp4')
                              .readAsBytesSync()
                              .buffer
                              .asUint8List(),
                          'video/mp4');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ExportPage(
                            musicFiles: widget.musicFiles,
                            fileName:
                                '$tempPath/Downloads/${user.uid}_${uniqueId}_2.mp4',
                          ),
                        ),
                      );
                    }
                    pr.dismiss();
                  },
                  child: Container(
                    height: 30,
                    width: 75,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(50)),
                    child: Center(
                        child: Text(
                      'Export',
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
