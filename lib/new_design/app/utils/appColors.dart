import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color bookApp = Color(0xff77B35D);
  static const lightPrimaryColor = Color(0xffBFE7F8);
  static const primaryColor = Color(0xFF19a9e5);
  static const ihlPrimaryColor = Color(0xFF19a9e5);
  static const primaryAccentColor = Color(0xFF19a9e5);
  static const blackText = Color(0xFF000000);
  static const textColor = Color(0xff585859);
  static const plainColor = Color.fromRGBO(255, 255, 255, 1);
  static const homeCardColor = Color.fromRGBO(222, 234, 238, 5);
  static const lowCardColor = Color.fromRGBO(241, 222, 211, 1);
  static const lowTextColor = Color.fromRGBO(250, 124, 53, 3);
  static const goodCardColor = Color.fromRGBO(204, 159, 84, 1.0);
  static const goodTextColor = Color.fromRGBO(216, 148, 40, 3);
  static const vgCardColor = Color.fromRGBO(213, 213, 173, 1.0);
  static HexColor calExtraOpc = HexColor('#F23838');
  static HexColor valueFillColor = HexColor('#B8E78A');
  static HexColor calExtra = HexColor('#731F11');
  static final subscription = Color(0xffA5A23F);
  static HexColor calNeed = HexColor('#1B5D2D');
  static HexColor calNeedOpc = HexColor('#429739');
  static const vgTextColor = Color.fromRGBO(230, 230, 14, 3);
  static const homeCardColor2 = Color(0xffCAE2EA);
  static HexColor calNeed3 = HexColor('#C2DEC5');
  static const unSelectedColor = Color.fromRGBO(238, 237, 237, 5);
  static const normalStatus = Color.fromRGBO(124, 196, 68, 2);
  static const bottom_shadow = Color.fromRGBO(124, 196, 68, 2);
  Color transparentColor = Colors.grey.withOpacity(0.5);
  static const backgroundScreenColor = Color(0XFFefefef);
  // static const activityBaseColor=HexColor('#6F72CA');
  static const tabUnSelectedTextColor = Color(0xff103e42);
  static const tabSelectedTextColor = Color(0xffffffff);
  static const paleFontColor = Color(0xff103e42);
  static final bgColorTab = Colors.grey[200];
  static const contentTitleColor = Color(0xc1000000);
  static const buttonColor = Color.fromRGBO(37, 150, 190, 0);
  static const hightStatusColor = Color.fromRGBO(252, 3, 15, 1);
  static const lowStatusColor = Color.fromRGBO(252, 193, 53, 1);
  static const heartHealthTitle = Color(0xff19A9E5);
  static const persitantColor = Color(0xfffd630c);
  static const hintTextColor = Color(0x56000000);
  static const affiliationUserColor = Color(0xffCC3B19);
  static const greenColor = Colors.green;
  static const ingredientColor = Color(0xffEE6143);

  static const Color nearlyDarkBlue = Color(0xFF2633C5);

  static const shadowColor = Color(0xffc0c0c0);
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
