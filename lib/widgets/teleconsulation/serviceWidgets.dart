
  import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';

Widget experienceYearsWidget(String exp) {
    if (exp.contains('years')||exp.contains('Years')) {
      return Text('Experience: $exp',
          style: TextStyle(color: AppColors.lightTextColor));
    } else {
      switch (exp) {
        case ('0.0'):
          return SizedBox.shrink();
          break;

        default:
          return Text('Experience: ' + exp + ' Years',
              style: TextStyle(color: AppColors.lightTextColor));
      }
    }
  }