import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'appColors.dart';

class AppTextStyles {
  AppTextStyles._();

  // new part last | ADD YOUR STYLES TOO !
  static final iconFonts = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8,
    color: AppColors.paleFontColor,
  );
  static final ShadowFonts = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: Colors.black45,
  );
  static final ShadowFonts1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: Colors.black45,
  );
  static final ShadowFonts2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.sp,
    color: Colors.black45,
  );
  static final bottomNavigationBar = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8,
    color: Color(0XFF111111),
    fontWeight: FontWeight.bold,
  );
  static final bottomNavigationBar2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8,
    color: Color(0XFF111111),
  );
  static final IconTitles = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8,
    color: Color(0xff61C6E7),
  );
  static final contentHeading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: AppColors.primaryAccentColor,
    fontWeight: FontWeight.w800,
  );
  static final lowcontentHeading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: AppColors.lowTextColor,
    fontWeight: FontWeight.w800,
  );
  static final goodcontentHeading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: AppColors.contentTitleColor,
    fontWeight: FontWeight.w800,
  );
  static final vgcontentHeading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: Color(0xff103e42),
    fontWeight: FontWeight.w800,
  );
  static final dashBoardPreference = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15.sp,
    color: Color(0xff103e42),
    fontWeight: FontWeight.w800,
  );
  static final dashBoardPreference1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: Color(0xff103e42),
    fontWeight: FontWeight.w500,
  );
  static final dashBoardPreference2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    color: Color(0xff103e42),
    fontWeight: FontWeight.w500,
  );
  static final content = TextStyle(
    letterSpacing: 1.sp,
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: AppColors.plainColor,
    fontWeight: FontWeight.w500,
  );
  static final subContent = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.sp,
    height: 1.2.sp,
    color: const Color(0xffffffff),
    fontWeight: FontWeight.w300,
  );
  static final cardContent = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.3.sp,
    color: AppColors.primaryColor,
    fontWeight: FontWeight.w800,
  );

  static final specAndExp = TextStyle(
      fontFamily: 'Poppins',
      color: AppColors.hintTextColor,
      fontSize: 12.sp,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w300);
  static final timeInConsulation = TextStyle(
    color: AppColors.primaryColor,
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
  );
  static final consultantName = TextStyle(
    fontFamily: 'Poppins',
    color: const Color(0XFF1C1C1C),
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static final joinCallDeactive = TextStyle(
    fontFamily: 'Poppins',
    color: AppColors.hintTextColor,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
  );
  static final joinCallActive = TextStyle(
    fontFamily: 'Poppins',
    color: AppColors.normalStatus,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
  );
  static final ratingTextInConsultant = TextStyle(
    fontFamily: 'Poppins',
    color: AppColors.hintTextColor,
    fontSize: 10.sp,
  );

  static final profileName = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 19,
    color: Color(0XFF585859),
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
  );
  static final content5 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: Color(0XFF585859),
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
  );
  static final content4 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: Color(0XFF585859),
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
  );
  static final designation = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    letterSpacing: 0.4,
    color: const Color(0xff585859),
  );
  static final contentFont = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.sp,
    color: AppColors.textColor,
  );

  static final contentFont3 = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12.sp,
      color: AppColors.textColor,
      fontWeight: FontWeight.w500);
  static final regularFont = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8.sp,
    color: AppColors.textColor,
  );
  static final regularFont2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: AppColors.textColor,
  );
  static final regularFont3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8.sp,
    color: AppColors.textColor,
  );
  static final secondaryContentFont = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11.sp,
      color: AppColors.blackText,
      fontWeight: FontWeight.w200);
  static final boldContnet = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.sp,
    color: AppColors.textColor,
    fontWeight: FontWeight.bold,
  );
  static final primaryColorText = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13.sp,
      color: AppColors.primaryAccentColor,
      fontWeight: FontWeight.w400);
  static final headerText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.sp,
    color: AppColors.primaryAccentColor,
    fontWeight: FontWeight.w800,
  );
  static final headerText2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13.sp,
    color: AppColors.primaryAccentColor,
    fontWeight: FontWeight.w800,
  );
  static final withinLimit = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13.sp,
    color: HexColor("#429739"),
    fontWeight: FontWeight.w800,
  );
  static final limitExceed = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13.sp,
    color: HexColor("#F23838"),
    fontWeight: FontWeight.w800,
  );
  static final selectedHeadline = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.5.sp,
    color: AppColors.contentTitleColor,
    fontWeight: FontWeight.w800,
  );
  static final whiteTabText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15.sp,
    color: AppColors.textColor,
  );
  static final selectedText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: AppColors.tabSelectedTextColor,
  );
  static final imageText = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12.sp,
      color: AppColors.tabSelectedTextColor,
      fontWeight: FontWeight.bold);
  static final imageTextTitle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12.sp,
      color: AppColors.tabSelectedTextColor,
      fontWeight: FontWeight.bold);
  static final nrmlText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 9.sp,
    color: AppColors.tabSelectedTextColor,
  );
  static final unSelectedText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: AppColors.tabUnSelectedTextColor,
  );
  static final vitalsText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  static final vitalsText2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 9.5.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  static final disabledVitalsText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: Colors.black54,
  );
  static final vitalsUnit = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 9.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  static final blackText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 9.sp,
    color: AppColors.tabUnSelectedTextColor,
  );
  static final blackText1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );
  static final blackText2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );
  static final normalStatus = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.5.sp,
    color: AppColors.normalStatus,
    fontWeight: FontWeight.w400,
  );
  static final highStatus = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.5.sp,
    color: AppColors.hightStatusColor,
    fontWeight: FontWeight.w400,
  );
  static final lowStatus = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.5.sp,
    color: AppColors.lowStatusColor,
    fontWeight: FontWeight.w400,
  );
  static final healthTipsBigFont = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: AppColors.ihlPrimaryColor,
    fontWeight: FontWeight.w500,
  );
  static final heartHealth = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.3.sp,
    color: AppColors.heartHealthTitle,
    fontWeight: FontWeight.w500,
  );
  static final healthTipsNotes = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: const Color(0xc1000000),
  );
  static final hintText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 9.sp,
    color: AppColors.hintTextColor,
    fontWeight: FontWeight.w400,
  );
  static final HealthChallengeTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: const Color(0xff19a9e5),
    fontWeight: FontWeight.w500,
  );
  static final challengeType = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: const Color(0xa8000000),
    fontWeight: FontWeight.w500,
  );
  static final HealthChallengeDescription = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.6.sp,
    wordSpacing: 1.5,
    color: const Color(0xba1c1c1c),
  );
  static final affiliationUserStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: AppColors.affiliationUserColor,
  );
  static final mapText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.sp,
    color: AppColors.contentTitleColor,
  );
  static final customText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 7.sp,
    color: AppColors.contentTitleColor,
  );
  static final peopleCounts = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10.sp,
    color: const Color(0xa8000000),
  );
  static final inviteText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11.sp,
    color: const Color(0xde000000),
  );
  static final sendInvite = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    color: const Color(0xffffffff),
  );
}
