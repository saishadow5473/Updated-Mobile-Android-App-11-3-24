import 'package:intl/intl.dart';

///DateTime To String MM/dd/yyyy 💡
String dateTimeToString(DateTime dateTime) {
  DateFormat ipF = DateFormat("MM/dd/yyyy");
  return ipF.format(dateTime);
}

///String to DateTime MM/dd/yyyy 💡
DateTime stringToDateTime(String date) {
  if (date == '' || date == null) {
    return DateTime.now();
  } else {
    try {
      DateFormat ipF = DateFormat("MM/dd/yyyy");
      return ipF.parse(date);
    } catch (e) {
      try {
        DateFormat ipF = DateFormat("MM-dd-yyyy");
        return ipF.parse(date);
      } catch (e) {
        try {
          DateFormat ipF = DateFormat("dd/MM/yyyy");
          return ipF.parse(date);
        } catch (e) {
          try {
            DateFormat ipF = DateFormat("dd-MM-yyyy");
            return ipF.parse(date);
          } catch (e) {
            return DateTime.now();
          }
        }
      }
    }
  }
}
