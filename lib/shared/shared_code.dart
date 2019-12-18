import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

Future<bool> handlePermission() async {
  await PermissionHandler()
      .requestPermissions([PermissionGroup.camera, PermissionGroup.storage]);
  PermissionStatus permissionStatus1 =
      await PermissionHandler().checkPermissionStatus(
    PermissionGroup.camera,
  );
  PermissionStatus permissionStatus2 =
      await PermissionHandler().checkPermissionStatus(
    PermissionGroup.storage,
  );
  if (permissionStatus1.value == 2 && permissionStatus2.value == 2)
    return Future.value(true);
  else
    return Future.value(false);
}

Future<void> showToast(String text) async {
  const platform = MethodChannel('com.saverl.baron/awake');
  try {
    final ans = await platform.invokeMethod('showToast', {"text": text});
    print('Succesfully shown a Toast ' + ans);
  } on PlatformException catch (e) {
    print('Some Error Occured' + e.message);
  }
}
