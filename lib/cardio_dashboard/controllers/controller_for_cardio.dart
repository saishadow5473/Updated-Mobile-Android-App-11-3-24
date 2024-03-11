import 'dart:developer';

import 'package:ihl/cardio_dashboard/models/last_updated_medicaldata_model.dart';
import 'package:ihl/cardio_dashboard/models/retrive_medical_data_model.dart';
import 'package:ihl/cardio_dashboard/models/user_data_model_cardio.dart';
import 'package:ihl/cardio_dashboard/networks/network_calls_cardio.dart';

import '../models/store_medical_data.dart';

class CardioController {
  Future<User> userDataGetterCardio() async {
    var response = await NetworkCallsCardio().userData();
    return User.fromJson(response);
  }

  Future<LastUpdatedMedicaldata> medicalData({String userId}) async {
    var response = await NetworkCallsCardio().getMedicalData(userId: userId);
    List list = response;
    return LastUpdatedMedicaldata.fromJson(list[0]);
  }

  Future consultantDataList({String userId}) async {
    var response = await NetworkCallsCardio().getConsaltantData(iHLUserId: userId);
    return response;
  }

  Future<RetriveMedicalData> retrieve_medical_data({String userId}) async {
    var response = await NetworkCallsCardio().retriveMedicalDatas(iHLUserId: userId);
    return RetriveMedicalData.fromJson(response);
  }

  Future storing_medical_data({StoreMedicalData storeMedicalData}) async {
    var response = await NetworkCallsCardio().storeMedicalData(storeMedicalData: storeMedicalData);
    return response;
  }

  Future retriveUserData() async {
    var response = await NetworkCallsCardio().retriveUserData();
    return response;
  }

  Future getCheckinData({String iHLUserId}) async {
    var response = await NetworkCallsCardio().getCheckinData(iHLUserId: iHLUserId);
    return response;
  }
}
