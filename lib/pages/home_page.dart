import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soofty/model/model.dart';
import 'package:soofty/services/firebase_service.dart' as firebaseService;
import 'package:soofty/shared/shared_code.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  void loadInterstitialAd() {
    _interstitialAd = createInterstitialAd()..load();
  }

  void showInterstitialAd() {
    if (_canShowAds) {
      _interstitialAd..show();
      loadInterstitialAd();
    }
  }

  void showRewardAd() {
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

  // play() async {
  // int result = await audioPlayer
  //     .play('https://a.uguu.se/vsjcNclQhKbj_SoundHelix-Song-1.mp3');
  // if (result == 1) {
  // } else {}
  // }

  // String path;
  // int progress;
  // _localPath() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   setState(() {
  //     path = directory.path;
  //   });
  // }

  @override
  void initState() {
    initialize();
    getProducts();
    // _bannerAd = createBannerAd()
    //   ..load()
    //   ..show();
    // loadInterstitialAd();

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

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTime', false);
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 134,
        child: products.length > 0
            ? products != null
                ? LiquidPullToRefresh(
                    onRefresh: () async {},
                    child: StaggeredGridView.countBuilder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(8.0),
                      crossAxisCount: 4,
                      itemCount: products.length,
                      itemBuilder: (ctx, idx) => musicTile(idx),
                      staggeredTileBuilder: (i) =>
                          StaggeredTile.count(2, i.isEven ? 2 : 3),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                  )
                : Center(child: CircularProgressIndicator())
            : Center(
                child: Text(
                  'No Data \n Try again later.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
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
        onTap: () => showInterstitialAd(),
        child: CachedNetworkImage(
          imageUrl: products[i].img,
          placeholder: (context, url) =>
              Image.asset('assets/images/wallfy.webp'),
          errorWidget: (context, url, error) =>
              Image.asset('assets/images/wallfy.webp'),
        ),
      ),
    );
  }
}
