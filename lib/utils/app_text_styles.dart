import 'package:flutter/material.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // new part last | ADD YOUR STYLES TOO !
  static final TextStyle fontSize30MediumStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 4.6875,
    color: AppColors.appTextColor,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle fontSize22MediumStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 2.5,
    color: AppColors.appTextColor,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle fontSize16MediumStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 2.1875,
    color: AppColors.customButtonTextColor,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle fontSize14RegularStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 2.1875,
    color: AppColors.customButtonTextColor,
  );

  static final TextStyle fontSize14V2RegularStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 2.1875,
    color: AppColors.textitemTitleColor,
  );
  static final TextStyle fontSize14V4RegularStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    color: AppColors.textitemTitleColor.withOpacity(.7),
  );
  static final TextStyle fontSize14b4RegularStyle = TextStyle(
    fontSize: 16.sp,
    color: AppColors.lightTextColor,
  );
  static final TextStyle fontSize14V5RegularStyle = TextStyle(
    fontSize: 15.sp,
    color: AppColors.lightTextColor,
  );
  static final TextStyle fontSize14V3RegularStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 2.1875,
    color: AppColors.textItemAmountColor,
  );

  static TextStyle homeTitle = TextStyle(
    fontFamily: 'Poppins',
    color: const Color(0xff6d6e71),
    fontSize: SizeConfig.textMultiplier * 8,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
  );
  static TextStyle appBarText = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
  );
  static TextStyle boldWhiteText = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
  );
  static final TextStyle fontSize14MediumStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 2.1875,
    color: AppColors.customButtonTextColor,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle fontSize12RegularStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 1.875,
    color: AppColors.customButtonTextColor,
  );
  static TextStyle mediumFontColor({Color color}) {
    return TextStyle(
      fontSize: SizeConfig.textMultiplier * 1.875,
      color: color,
    );
  }

  static final TextStyle fontSize12ColorRegularStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 1.875,
    color: AppColors.pageViewSubtitleColor,
  );

  static final TextStyle fontSize12RegularV2Style = TextStyle(
    fontSize: SizeConfig.textMultiplier * 1.875,
    color: AppColors.appItemTitleTextColor,
  );

  static final TextStyle fontSize12MediumStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 1.875,
    color: AppColors.appItemTitleTextColor,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle fontSize11Style = TextStyle(
    fontSize: SizeConfig.textMultiplier * 1.71875,
    color: AppColors.customButtonTextColor,
  );
  static final TextStyle contentSmallText = TextStyle(
    fontSize: 14.sp,
    color: AppColors.backgroundScreenColor,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle fontSize11BoldStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 1.71875,
    color: AppColors.customButtonTextColor,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle fontSize10RegularStyle = TextStyle(
    fontSize: SizeConfig.textMultiplier * 1.5625,
    color: AppColors.appItemTitleTextColor,
    fontWeight: FontWeight.bold,
  );
}
