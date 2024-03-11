class TeleConsultationServices {
  String getPluralForm(int value, String unit) {
    String pluralizedUnit = unit.endsWith('s') ? unit : unit + 's';
    if (value == 1) {
      if(unit.endsWith('s')){
        return '1 ${unit.replaceAll('s', '')}';
      }else{
      return '1 $unit';}
    } else {
      return '$value $pluralizedUnit';
    }
  }

  String processString(String input) {
    RegExp regExp = RegExp(r'(\d+)\s*([a-zA-Z]+)'); // purpose of the line split the number and words using regexp
    Match match = regExp.firstMatch(input);

    if (match != null) {
      int value = int.parse(match.group(1));
      String unit = match.group(2);
      return getPluralForm(value, unit);
    } else {
      return "";
    }
  }
}
