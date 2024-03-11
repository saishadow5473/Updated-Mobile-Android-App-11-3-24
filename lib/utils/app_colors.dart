import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primaryColor = Color(0xFF19a9e5);
  static const primaryAccentColor = Color(0xFF19a9e5);
  static const backgroundScreenColor = Color(0XFFefefef);

  static const textLiteColor = Color(0xff585859);
  static HexColor calExtra = HexColor('#731F11');
  static  HexColor calNeed = HexColor('#1B5D2D');
  static  HexColor calNeedOpc = HexColor('#429739');
  static HexColor calExtraOpc = HexColor('#F23838');
  static HexColor calNeed3=HexColor('#C2DEC5');
  static const greenColor = Color.fromRGBO(112, 166, 73, 1);
  static const orangeAccent = Color.fromRGBO(245, 173, 59, 1);
  static const appTextColor = Color.fromRGBO(63, 61, 86, 1);
  static const lightTextColor = Color(0xff6d6e71);
  static const appBackgroundColor = Color.fromRGBO(252, 252, 252, 1);
  static const customButtonTextColor = Color(0xFF19a9e5);
  static const pageViewSubtitleColor = Color.fromRGBO(148, 146, 170, 1);
  static const progressBarIndicatorColor = Color(0xFF19a9e5);
  static const appItemTitleTextColor = Color.fromRGBO(129, 129, 129, 1);
  static const appItemShadowColor = Color.fromRGBO(194, 216, 255, 0.4);
  static const partOneColor = Color.fromRGBO(248, 199, 144, 1);
  static const partTwoColor = Color.fromRGBO(255, 135, 135, 1);
  static const partThreeColor = Color.fromRGBO(229, 249, 123, 1);
  static const dividerColor = Color.fromRGBO(129, 129, 129, 1);
  static const lowIntakeCircleColor = Color.fromRGBO(255, 246, 119, 1);
  static const averageIntakeCircleColor = Color.fromRGBO(159, 243, 159, 1);
  static const highIntakeCircleColor = Color.fromRGBO(255, 91, 91, 1);
  static const textitemTitleColor = Color.fromRGBO(46, 46, 46, 1);
  static const textItemAmountColor = Color.fromRGBO(146, 146, 146, 1);
  static const textBorderColor = Color.fromRGBO(112, 112, 112, 1);
  static const buttonBackgroundColor = Color.fromRGBO(194, 216, 255, 1);
  static const bmiProgressBarLowColor = Color.fromRGBO(255, 246, 119, 1);
  static const bmiProgressBarNormalColor = Color.fromRGBO(159, 243, 159, 1);
  static const failure = Color.fromRGBO(255, 91, 91, 1);
  static final bgColorTab = Colors.grey[200];
  // static final cardColor = CardColors.bgColor;
  static final cardColor = Color(0xFFFFFFFF); //white
  static final morderateCardColor = Color(0xfff7e0a4);

  ///graph colors
  static final List<Color> graphGradient1 = [
    const Color(0xFF19a9e5),
    const Color(0xff02d39a),
  ];
  static final List<Color> graphGradient2 = [
    const Color(0xffe3322e),
    const Color(0xffe2e30a),
  ];
  //dashboard items
  static final startConsult = Color.fromRGBO(247, 130, 172, 1);
  static final medicalFiles = Color.fromRGBO(247, 130, 172, 1);
  static final myConsultant = Color(0xFF19a9e5);
  static final bookApp = Color(0xff77B35D);
  static final myApp = Color(0xFF19a9e5);
  static final myConsult = Color(0xffD46BD2);
  static final subscription = Color(0xffA5A23F);
  static final followUp = Color.fromRGBO(254, 119, 1, 1);
  static final history = Color.fromRGBO(155, 51, 51, 1);
  static const onlineClass = Color.fromRGBO(228, 144, 117, 1);

  //dietJournal colors

  static final dietJournalPrimary = primaryColor;
  // static final dietJournalPrimary = Color(0xfffec5a8);
  static final dietJournalOrange = primaryColor;
  static final dietJournalFill = Color(0xffe5cac2);
}

class FitnessAppTheme {
  FitnessAppTheme._();
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);

  static const Color nearlyBlue = Color(0xFF19a9e5);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Poppins';

  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText2: body2,
    bodyText1: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );
  static const TextStyle challengeKeyText = TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1, color: Colors.blueGrey);
  static const TextStyle challengeValueText = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      color: AppColors.primaryAccentColor);

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );

  static const TextStyle iconText = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: nearlyBlue,
  );
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
