import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:soofty/pages/login_screen.dart';
import '../main.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<Slide> slides = [
    Slide(
      backgroundColor: Color(0xff1C3D4E),
      title: "EASY TO USE",
      styleTitle: GoogleFonts.lato(
        textStyle: TextStyle(
          color: Color(0xff3da4ab),
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: "Turn your images into amazing videos within seconds.",
      styleDescription: TextStyle(
        color: Color(0xfffe9c8f),
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
      pathImage: "assets/images/easy.webp",
    ),
    Slide(
      title: "MANY MUSIC",
      backgroundColor: Color.fromRGBO(89, 83, 134, 1),
      styleTitle: GoogleFonts.lato(
        textStyle: TextStyle(
          color: Color(0xff3da4ab),
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: "Latest music to choose from",
      styleDescription: GoogleFonts.lato(
        textStyle: TextStyle(
          color: Color(0xfffe9c8f),
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ),
      ),
      pathImage: "assets/images/music.webp",
    ),
    Slide(
      title: "FAST EXPORT",
      backgroundColor: Color(0xff9730CB),
      styleTitle: GoogleFonts.lato(
        textStyle: TextStyle(
          color: Color(0xff3da4ab),
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: "Preview and Export videos within seconds.",
      styleDescription: GoogleFonts.lato(
        textStyle: TextStyle(
          color: Color(0xfffe9c8f),
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ),
      ),
      pathImage: "assets/images/fast.webp",
    ),
  ];

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Intro Page');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => IntroSlider(
        slides: slides,
        renderSkipBtn: Icon(
          Icons.skip_next,
          color: Color(0xffffcc5c),
        ),
        colorSkipBtn: Color(0x33ffcc5c),
        highlightColorSkipBtn: Color(0xffffcc5c),
        renderNextBtn: Icon(
          Icons.navigate_next,
          color: Color(0xffffcc5c),
          size: 35.0,
        ),
        renderDoneBtn: Icon(
          Icons.done,
          color: Color(0xffffcc5c),
        ),
        onDonePress: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => LoginPage()));
        },
        colorDoneBtn: Color(0x33ffcc5c),
        highlightColorDoneBtn: Color(0xffffcc5c),
        colorDot: Color(0xffffcc5c),
        sizeDot: 13.0,
        typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,
        backgroundColorAllSlides: Colors.white,
        shouldHideStatusBar: true,
      ),
    );
  }
}
