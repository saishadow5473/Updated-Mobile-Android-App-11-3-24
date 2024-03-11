import 'package:flutter/cupertino.dart';
import 'package:ihl/Modules/online_class/data/model/getClassSpecialityNameList.dart';

import '../../data/repositories/online_class_api.dart';

class OnlineClassFunctionsAndVariables {
  static Future<List<SpecialityTypeList>> onlineClassConsultantsSpecialityfunc(
      String specList) async {
    Map<String, dynamic> gettingValueSpeciality;
    gettingValueSpeciality = await OnlineClassApiCall.class_specialty_name(specList: specList);

    ///Api Call
    List<dynamic> specialityList = gettingValueSpeciality['specialityList'];
    ValueNotifier<List<SpecialityTypeList>> list =
        ValueNotifier<List<SpecialityTypeList>>(<SpecialityTypeList>[]);
    try {
      List tileNameList = specialityList;
      tileNameList.map((dynamic e) => list.value.add(SpecialityTypeList.fromJson(e))).toList();
    } catch (e) {
      print(e);
    }
    return list.value;
  }
}
