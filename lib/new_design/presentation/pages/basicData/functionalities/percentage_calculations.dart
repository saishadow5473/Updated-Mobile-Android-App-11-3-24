import 'package:get_storage/get_storage.dart';

import '../../../../../utils/SpUtil.dart';
import '../models/basic_data.dart';

int totalAttributes = 6;

class PercentageCalculations {
  int filledAttributes = 0;

  // Total number of attributes
  int calculatePercentageFilled() {
    //BasicDataModel basicData = BasicDataModel();
    final GetStorage box = GetStorage();
    BasicDataModel basicData = box.read('BasicData');
try{
      // Check if each attribute is not empty or null and increment the count
      if (basicData.name != null) filledAttributes++;
      // if (basicData.password != null) filledAttributes++;
      if (basicData.gender != null) filledAttributes++;
      if (basicData.height != null) filledAttributes++;
      if (basicData.weight != null) filledAttributes++;
      if (basicData.dob != null) filledAttributes++;
      if (basicData.mobile != null) filledAttributes++;
    }
    catch(e){
      filledAttributes=6;
    }

    // Calculate the percentage
    double percentageFilled = (filledAttributes / totalAttributes) * 100;
    bool isSSO = SpUtil.getBool('isSSoUser');
    if (isSSO ?? false) {
      if (int.parse(percentageFilled.toStringAsFixed(0)) > 80) {
        return 100;
      }
    }
    return int.parse(percentageFilled.toStringAsFixed(0));
  }

  int checkHowManyFilled() {
    try {
      calculatePercentageFilled();
      return filledAttributes;
    }
    catch(e){
      print(e);
      return 100;
    }
  }
}
