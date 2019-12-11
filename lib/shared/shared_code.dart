import 'package:firebase_admob/firebase_admob.dart';

String _bannerAdId;
String _interstitialAdId;
String _rewardedAdId;
String _appId;

String bannerAdId = _bannerAdId != null ? _bannerAdId : BannerAd.testAdUnitId;
String appId = _appId != null ? _appId : FirebaseAdMob.testAppId;
String rewardedAdId =
    _rewardedAdId != null ? _rewardedAdId : RewardedVideoAd.testAdUnitId;
String interstitialAdId =
    _interstitialAdId != null ? _interstitialAdId : InterstitialAd.testAdUnitId;
