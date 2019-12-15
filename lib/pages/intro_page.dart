import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:soofty/pages/login_screen.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final pages = [
    PageViewModel(
        pageColor: const Color(0xFF607D8B),
        iconImageAssetPath: 'assets/images/taxi-driver.png.webp',
        iconColor: null,
        bubbleBackgroundColor: Colors.white,
        body: Text(
          'Easy  cab  booking  at  your  doorstep  with  cashless  payment  system',
        ),
        title: Text('Cabs'),
        mainImage: Image.asset(
          'assets/images/taxi.png.webp',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: GoogleFonts.lato(),
        bodyTextStyle: GoogleFonts.lato()),
    PageViewModel(
        pageColor: const Color(0xFF607D8B),
        iconImageAssetPath: 'assets/images/air-hostess.png.webp',
        iconColor: null,
        bubbleBackgroundColor: Colors.white,
        body: Text(
          'Easy  cab  booking  at  your  doorstep  with  cashless  payment  system',
        ),
        title: Text('Cabs'),
        mainImage: Image.asset(
          'assets/images/airplane.png.webp',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: GoogleFonts.lato(),
        bodyTextStyle: GoogleFonts.lato()),
    PageViewModel(
        pageColor: const Color(0xFF607D8B),
        iconImageAssetPath: 'assets/images/bus-driver.png.webp',
        iconColor: null,
        bubbleBackgroundColor: Colors.white,
        body: Text(
          'Easy  cab  booking  at  your  doorstep  with  cashless  payment  system',
        ),
        title: Text('Cabs'),
        mainImage: Image.asset(
          'assets/images/bus.png.webp',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: GoogleFonts.lato(),
        bodyTextStyle: GoogleFonts.lato()),
    PageViewModel(
        pageColor: const Color(0xFF607D8B),
        iconImageAssetPath: 'assets/images/waiter.png.webp',
        iconColor: null,
        bubbleBackgroundColor: Colors.white,
        body: Text(
          'Easy  cab  booking  at  your  doorstep  with  cashless  payment  system',
        ),
        title: Text('Cabs'),
        mainImage: Image.asset(
          'assets/images/hotel.png.webp',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: GoogleFonts.lato(),
        bodyTextStyle: GoogleFonts.lato()),
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => IntroViewsFlutter(
        pages,
        showNextButton: true,
        showBackButton: true,
        onTapSkipButton: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ), //MaterialPageRoute
          );
        },
        onTapDoneButton: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ), //MaterialPageRoute
          );
        },
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
