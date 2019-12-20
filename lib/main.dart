import 'dart:async';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soofty/pages/home_page.dart';
import 'package:soofty/pages/intro_page.dart';
import 'package:soofty/pages/login_screen.dart';
import 'package:soofty/shared/shared_code.dart';
import 'model/model.dart';
import 'package:soofty/services/firebase_service.dart' as firebaseService;

void main() {
  Crashlytics.instance.enableInDevMode = false;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runZoned(() {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

FirebaseAnalytics analytics = FirebaseAnalytics();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFirstTime = true;
  @override
  void initState() {
    analytics.logAppOpen();
    initialize();
    FirebaseAdMob.instance.initialize(appId: appId);
    super.initState();
  }

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool("isFirstTime") ?? true;
    setState(() {
      isFirstTime = firstTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        ),
      ],
      child: MaterialApp(
        title: 'Soofty',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: isFirstTime ? IntroPage() : MyHomePage(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    if (user != null)
      return StreamProvider<User>.value(
        value: firebaseService.streamUser(user.uid),
        initialData: User.fromMap({}),
        child: HomePage(),
      );
    else
      return LoginPage();
  }
}
