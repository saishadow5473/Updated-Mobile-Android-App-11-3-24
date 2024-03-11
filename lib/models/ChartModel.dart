import 'package:flutter/material.dart';

var defaultDailyStat = DailyStatUiModel(
  steps: 0,
  isToday: false,
);

class DailyStatUiModel {
  int steps;
  bool isToday;

  DailyStatUiModel({
    @required this.steps,
    @required this.isToday,
  });

  DailyStatUiModel copyWith(
          {String day,
          int steps,
          bool isToday,
          bool isSelected,
          int dayPosition}) =>
      DailyStatUiModel(
        steps: steps ?? this.steps,
        isToday: isToday ?? this.isToday,
      );
}
