import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:soofty/model/model.dart';
import 'package:soofty/services/firebase_service.dart' as firebaseService;
import 'package:soofty/shared/shared_code.dart';
import 'package:path_provider/path_provider.dart';
// import 'permiss';
import 'package:connectivity/connectivity.dart' as csa;
import 'package:permission_handler/permission_handler.dart';

// import 'ro';
class HomeScreenPage extends StatefulWidget {
  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  static final MobileAdTargetingInfo mobileAdTargetingInfo =
      MobileAdTargetingInfo(
    keywords: ['camera', 'music', 'image', 'status', 'video', 'whatsapp'],
    testDevices: <String>[
      '36451F1875A8B63DE36BF6E55DFDEC43',
      'A9A49FCD4F98BA5214A35A277221824D'
    ],
    childDirected: false,
  );
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool _canShowAds = true;
  AudioPlayer audioPlayer = AudioPlayer();
  List<MusicFiles> products = [];

  bool isLoading = false;

  bool hasMore = true;

  DocumentSnapshot lastDocument;

  ScrollController _scrollController = ScrollController();

  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: bannerAdId,
        size: AdSize.banner,
        targetingInfo: mobileAdTargetingInfo);
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

  void showInterstitialAd() async {
    _interstitialAd..show();
  }

  void loadInterstitialAd() {
    _interstitialAd = createInterstitialAd()..load();
  }

  void showRewardAd() async {
    RewardedVideoAd.instance.load(
      adUnitId: rewardedAdId,
      targetingInfo: mobileAdTargetingInfo,
    );
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {});
      }
      if (event == RewardedVideoAdEvent.loaded) {
        RewardedVideoAd.instance.show();
      }
    };
  }

  play() async {
    int result = await audioPlayer
        .play('https://a.uguu.se/vsjcNclQhKbj_SoundHelix-Song-1.mp3');
    if (result == 1) {
    } else {}
  }

  String path;
  int progress;
  _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      path = directory.path;
    });
  }

  handlePermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    // await FlutterDownloader.initialize();
  }

  @override
  void initState() async {
    csa.ConnectivityResult status =
        await csa.Connectivity().checkConnectivity();
    // status.
    // _bannerAd = createBannerAd()
    //   ..load()
    //   ..show();
    // getProducts();
    handlePermission();
    _localPath();
    // FlutterDownloader.registerCallback((a, b, c) {
    //   progress = c;
    //   // (double.parse((i / j).toStringAsFixed(2)) * 100).toInt();
    // });
    loadInterstitialAd();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getProducts();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  getProducts() async {
    QuerySnapshot querySnapshot;
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (lastDocument == null)
      querySnapshot =
          await firebaseService.streamMusicTile(lastDocument, false);
    else
      querySnapshot = await firebaseService.streamMusicTile(lastDocument, true);

    if (querySnapshot.documents.length < 10) {
      hasMore = false;
    }

    lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    products.addAll(querySnapshot.documents
        .map((data) => MusicFiles.fromFirestore(data))
        .toList());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height - 134,
        child: Center(
          child: RaisedButton(
            onPressed: () async {
              // final taskId = await FlutterDownloader.enqueue(
              //   url: 'https://a.uguu.se/vsjcNclQhKbj_SoundHelix-Song-1.mp3',
              //   savedDir: path,
              //   showNotification:
              //       true, // show download progress in status bar (for Android)
              //   openFileFromNotification:
              //       true, // click on notification to open downloaded file (for Android)
              // );
            },
            child: Text('$progress'),
          ),
        ),
        // child: products != null
        //     ? StaggeredGridView.countBuilder(
        //         controller: _scrollController,
        //         padding: EdgeInsets.all(8.0),
        //         crossAxisCount: 4,
        //         itemCount: products.length,
        //         itemBuilder: (ctx, idx) => musicTile(idx),
        //         staggeredTileBuilder: (i) =>
        //             StaggeredTile.count(2, i.isEven ? 2 : 3),
        //         mainAxisSpacing: 8,
        //         crossAxisSpacing: 8,
        //       )
        //     : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget musicTile(int i) {
    return Material(
      color: Colors.white,
      elevation: 8.0,
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          audioPlayer.stop();

          // _canShowAds ? showInterstitialAd() : loadInterstitialAd();
        },
        child: FadeInImage(
          placeholder: AssetImage('assets/images/wallfy.webp'),
          image: NetworkImage(products[i].img),
        ),
      ),
    );
  }
}
