import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HealthJournalSearvices {
  String convertTimeOfDayToDateTime({TimeOfDay time, String format}) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final String formatedDate = DateFormat(format).format(date);
    return formatedDate;
  }
}

class DisablePasteTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text != null && newValue.text.isNotEmpty && oldValue.text != newValue.text) {
      // Prevent pasting by returning the old value
      return oldValue;
    }
    return newValue;
  }
}
