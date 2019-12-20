import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soofty/model/model.dart';
import 'package:soofty/pages/show_audio_page.dart';
import 'package:soofty/services/firebase_service.dart' as firebaseService;
import 'package:soofty/shared/shared_code.dart';
import 'package:url_launcher/url_launcher.dart';
import 'myvideo_page.dart';
import '../main.dart';

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
  final Trace myTrace = FirebasePerformance.instance.newTrace("get_music_data");
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool _canShowAds = true;
  List<MusicFiles> products = [];
  bool isLoading = false;
  bool hasMore = true;
  bool isOffline = false;
  DocumentSnapshot lastDocument;
  ScrollController _scrollController = ScrollController();
  int _sortSelected = 0;
  PackageInfo _packageInfo;
  StreamSubscription _subscription;
  final FirebaseMessaging _messaging = FirebaseMessaging();

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

  // TODO: add things for rewarded add
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

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Home Screen');
    initialize();
    getProducts();
    // TODO: fix loading when started offline
    print('object');
    _bannerAd = createBannerAd()
      ..load()
      ..show();
    loadInterstitialAd();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getProducts();
      }
    });
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none)
        setState(() {
          isOffline = true;
        });
      else
        setState(() {
          isOffline = false;
        });
    });

    _messaging.configure(onMessage: (Map<String, dynamic> message) async {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (ctx) => MyHomePage()));
    }, onLaunch: (Map<String, dynamic> message) async {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (ctx) => MyHomePage()));
    }, onResume: (Map<String, dynamic> message) async {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (ctx) => MyHomePage()));
    });
    super.initState();
    _messaging.subscribeToTopic('collectibles');
  }

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo pacInfo = await PackageInfo.fromPlatform();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isOffline = true;
      });
    }
    setState(() {
      _packageInfo = pacInfo;
    });
    prefs.setBool('isFirstTime', false);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _scrollController?.dispose();
    _subscription?.cancel();
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
    myTrace.start();
    if (lastDocument == null)
      querySnapshot =
          await firebaseService.streamMusicTile(lastDocument, false);
    else
      querySnapshot = await firebaseService.streamMusicTile(lastDocument, true);
    myTrace.stop();
    if (querySnapshot.documents.length < 20) {
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
    User user = Provider.of<User>(context);
    return Scaffold(
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 60,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => Container(
                    color: Color(0xff737373),
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(left: 15)),
                                  Icon(FontAwesomeIcons.slidersH),
                                  Padding(padding: EdgeInsets.only(left: 20)),
                                  Text(
                                    'Sort Videos By   (IN DEVELOPMENT)',
                                    style: GoogleFonts.lato(
                                        fontSize: 16, // TODO: change to 20
                                        fontWeight: FontWeight.bold,
                                        textStyle:
                                            TextStyle(color: Colors.grey)),
                                  )
                                ],
                              ),
                              Divider(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _sortSelected = 0;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: CircleAvatar(
                                        backgroundColor: _sortSelected == 0
                                            ? Color(0xff7160FF)
                                            : Colors.white,
                                        radius: 27,
                                        child: Icon(
                                          FontAwesomeIcons.random,
                                          size: 30,
                                          color: _sortSelected == 0
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 4)),
                                    Text(
                                      'Random',
                                      style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          textStyle: TextStyle(
                                            color: _sortSelected == 0
                                                ? Color(0xff7160FF)
                                                : Colors.black,
                                          )),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 20)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _sortSelected = 1;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: CircleAvatar(
                                        backgroundColor: _sortSelected == 1
                                            ? Color(0xff7160FF)
                                            : Colors.white,
                                        radius: 27,
                                        child: Icon(
                                          FontAwesomeIcons.fire,
                                          size: 30,
                                          color: _sortSelected == 1
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 4)),
                                    Text(
                                      'Popular',
                                      style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          textStyle: TextStyle(
                                            color: _sortSelected == 1
                                                ? Color(0xff7160FF)
                                                : Colors.black,
                                          )),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 20)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _sortSelected = 2;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: CircleAvatar(
                                        backgroundColor: _sortSelected == 2
                                            ? Color(0xff7160FF)
                                            : Colors.white,
                                        radius: 27,
                                        child: Icon(
                                          FontAwesomeIcons.calendarDay,
                                          size: 30,
                                          color: _sortSelected == 2
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 4)),
                                    Text(
                                      'Latest',
                                      style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          textStyle: TextStyle(
                                            color: _sortSelected == 2
                                                ? Color(0xff7160FF)
                                                : Colors.black,
                                          )),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 20)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _sortSelected = 3;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  children: <Widget>[
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: CircleAvatar(
                                        backgroundColor: _sortSelected == 3
                                            ? Color(0xff7160FF)
                                            : Colors.white,
                                        radius: 27,
                                        child: Icon(
                                          FontAwesomeIcons.calendarAlt,
                                          size: 30,
                                          color: _sortSelected == 3
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 4)),
                                    Text(
                                      'Oldest',
                                      style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          textStyle: TextStyle(
                                            color: _sortSelected == 3
                                                ? Color(0xff7160FF)
                                                : Colors.black,
                                          )),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 20)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Icon(FontAwesomeIcons.slidersH),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                  color: Color(0xff7160FF),
                  image: DecorationImage(
                      image: AssetImage('assets/images/wallfy.webp'))),
            ),
            drawerTile(FontAwesomeIcons.video, 'My Videos', () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => MyVideoPage()));
            }),
            drawerTile(FontAwesomeIcons.shareAlt, 'Invite People', () async {
              if (!isOffline) {
                final DynamicLinkParameters parameters = DynamicLinkParameters(
                  uriPrefix: 'https://soofty.page.link',
                  link: Uri.parse('https://saverl.com/offer'),
                  androidParameters: AndroidParameters(
                      packageName: 'com.saverl.soofty',
                      fallbackUrl: Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.saverl.soofty')),
                  iosParameters: IosParameters(
                      bundleId: 'com.saverl.soofty',
                      fallbackUrl: Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.saverl.soofty')),
                  socialMetaTagParameters: SocialMetaTagParameters(
                    title: 'Soofty',
                    description: 'WhatsApp Video Status Maker',
                  ),
                );
                final ShortDynamicLink dynamicUrl =
                    await parameters.buildShortLink();
                final Uri shortUrl = dynamicUrl.shortUrl;
                Share.text('Share', 'WhatsApp Video Status Maker.\n $shortUrl',
                    'text/plain');
              } else
                Share.text(
                    'Share',
                    'WhatsApp Video Status Maker.\n https://play.google.com/store/apps/details?id=com.saverl.soofty',
                    'text/plain');
            }),
            drawerTile(FontAwesomeIcons.solidStar, 'Rate App', () async {
              const url =
                  'https://play.google.com/store/apps/details?id=com.saverl.soofty';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                showToast('Could not launch $url');
              }
            }),
            drawerTile(FontAwesomeIcons.solidFileCode, 'Privacy Policy',
                () async {
              const url = 'https://soofty.flycricket.io/privacy.html';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                showToast('Could not launch $url');
              }
            }),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height - 500)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_packageInfo != null)
                  Text(
                    'Version : ${_packageInfo.version.substring(0, 3)}',
                    style: GoogleFonts.lato(),
                  ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Soofty',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: isOffline
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height - 134,
        child: isOffline
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 100,
                    ),
                    Icon(
                      Icons.signal_wifi_off,
                      size: 200,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      'No Internet Connection!',
                      style: GoogleFonts.lato(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              )
            : products != null
                ? products.length > 0
                    ? StaggeredGridView.countBuilder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(8.0),
                        crossAxisCount: 4,
                        itemCount: products.length,
                        itemBuilder: (ctx, idx) =>
                            musicTile(idx, products[idx], user),
                        staggeredTileBuilder: (i) =>
                            StaggeredTile.count(2, i.isEven ? 2 : 3),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
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

  Widget musicTile(int i, MusicFiles musicFiles, User user) {
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
                builder: (ctx) => StreamProvider<User>.value(
                  value: firebaseService.streamUser(user.uid),
                  initialData: User.fromMap({}),
                  child: ShowAudioPage(
                    musicFiles: musicFiles,
                  ),
                ),
              ),
            );
          } else {
            showToast('Please Grant Permission');
          }
        },
        child: CachedNetworkImage(
          fit: BoxFit.fill,
          imageUrl: products[i].img,
          placeholder: (context, url) =>
              Image.asset('assets/images/wallfy.webp'),
          errorWidget: (context, url, error) =>
              Image.asset('assets/images/wallfy.webp'),
        ),
      ),
    );
  }

  Widget drawerTile(IconData icon, String title, Function function) {
    return ListTile(
      onTap: function,
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
