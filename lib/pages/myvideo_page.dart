import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:soofty/model/model.dart';
import 'package:soofty/pages/show_video_page.dart';
import 'package:soofty/shared/shared_code.dart';
import 'package:thumbnails/thumbnails.dart';
import '../main.dart';

class MyVideoPage extends StatefulWidget {
  @override
  _MyVideoPageState createState() => _MyVideoPageState();
}

class _MyVideoPageState extends State<MyVideoPage> {
  List<File> _files = [];
  List<String> _thumb = [];
  InterstitialAd _interstitialAd;
  static final MobileAdTargetingInfo mobileAdTargetingInfo =
      MobileAdTargetingInfo(
    keywords: ['camera', 'music', 'image', 'status', 'video', 'whatsapp'],
    testDevices: <String>[
      '36451F1875A8B63DE36BF6E55DFDEC43',
      'A9A49FCD4F98BA5214A35A277221824D'
    ],
    childDirected: false,
  );

  @override
  void initState() {
    initialize();
    analytics.setCurrentScreen(screenName: 'Song Edit Page');
    loadInterstitialAd();
    super.initState();
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: interstitialAdId, targetingInfo: mobileAdTargetingInfo);
  }

  void loadInterstitialAd() {
    _interstitialAd = createInterstitialAd()..load();
  }

  void showInterstitialAd() {
    _interstitialAd..show();
    loadInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initialize() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    try {
      if (!(await Directory('$tempPath/Thumbnails').exists())) {
        Directory directory =
            await Directory('$tempPath/Thumbnails').create(recursive: true);
        print(directory.path);
      } else {
        print(Directory('$tempPath/Thumbnails').path);
      }
      if (!(await Directory('$tempPath/Export').exists())) {
        Directory directory =
            await Directory('$tempPath/Export').create(recursive: true);
        print(directory.path);
      } else {
        print(Directory('$tempPath/Export').path);
      }
      var file = Directory('$tempPath/Export').listSync();
      for (var i = 0; i < file.length; i++) {
        if (file[i].path.split('_')[3].split('.')[0] == '2') {
          String path = await Thumbnails.getThumbnail(
              thumbnailFolder: '$tempPath/Thumbnails',
              videoFile: file[i].path,
              imageType: ThumbFormat.PNG,
              quality: 30);
          setState(() {
            _files.add(File(file[i].path));
            _thumb.add(path);
          });
        }
      }
    } catch (e) {
      showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context); // TODO: use
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Videos',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _files.length > 0
            ? StaggeredGridView.countBuilder(
                padding: EdgeInsets.all(8.0),
                crossAxisCount: 4,
                itemCount: _files.length,
                itemBuilder: (ctx, idx) => musicTile(idx, _files[idx]),
                staggeredTileBuilder: (i) =>
                    StaggeredTile.count(2, i.isEven ? 2 : 3),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              )
            : Column(
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Icon(
                    FontAwesomeIcons.solidFolderOpen,
                    size: 200,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'No Videos Exported!',
                    style: GoogleFonts.lato(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget musicTile(int i, File file) {
    return Material(
      color: Colors.white,
      elevation: 8.0,
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
      child: InkWell(
        onTap: () async {
          bool _bool = await handlePermission();
          if (_bool) {
            showInterstitialAd();
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (ctx) => ShowVideoPage(
                        file: _files[i],
                        thumbPath: _thumb[i],
                        name: 'Exported video from Soofty',
                      )),
            );
          } else {
            showToast('Please Grant Permission');
          }
        },
        child: Image.file(
          File(_thumb[i]),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
