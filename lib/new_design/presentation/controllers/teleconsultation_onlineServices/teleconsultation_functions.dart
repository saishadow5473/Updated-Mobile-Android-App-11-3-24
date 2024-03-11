// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../repositories/api_repository.dart';
import '../../../../utils/app_colors.dart';
import '../../../data/model/TeleconsultationModels/MyAppointments.dart';
import '../../../data/model/TeleconsultationModels/SearchModelsTeleconsultation.dart';
import '../../../data/model/TeleconsultationModels/TeleconulstationDashboardModels.dart';
import '../../../data/model/TeleconsultationModels/allMedicalFiles.dart';
import '../../../data/model/TeleconsultationModels/appointmentModels.dart';
import '../../../data/model/TeleconsultationModels/appointmentTimings.dart';
// import '../../../data/model/TeleconsultationModels/sharesendReportMedicalModel.dart';
import '../../../data/model/TeleconsultationModels/consultation_summary_model.dart';
import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../../data/model/TeleconsultationModels/uploadMedical.dart';
import '../../../data/providers/cache_files.dart/image_cache_ihl.dart';
import '../../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'teleconsultation_apiCalls.dart';

class TeleConsultationFunctionsAndVariables {
  static ValueNotifier<bool> showVitals = ValueNotifier<bool>(false);
  static ValueNotifier<bool> showMedicalFilesCard = ValueNotifier<bool>(false);
  static ValueNotifier<bool> isChecking = ValueNotifier<bool>(false);
  static TextEditingController searchSpecController = TextEditingController();
  static TextEditingController searchDocController = TextEditingController();
  static ValueNotifier<List<SpecialityList>> specName =
      ValueNotifier<List<SpecialityList>>(<SpecialityList>[]);
  static ValueNotifier<String> noSlotsAvailable = ValueNotifier<String>('');
  static ValueNotifier<List<SpecialityList>> searchResultSpec =
      ValueNotifier<List<SpecialityList>>(<SpecialityList>[]);
  static ValueNotifier<List<DoctorModel>> doctors =
      ValueNotifier<List<DoctorModel>>(<DoctorModel>[]);
  static ValueNotifier<List<AllMedicalFiles>> medFilesList =
      ValueNotifier<List<AllMedicalFiles>>(<AllMedicalFiles>[]);
  static ValueNotifier<List<Appointment>> appointments =
      ValueNotifier<List<Appointment>>(<Appointment>[]);
  static ValueNotifier<Map> selectedDateTile =
      ValueNotifier({"selectedTile": "Today", "selectedCategory": "morning", "time": "10:00"});
  static List<AppointmentsTimings> timingsList = <AppointmentsTimings>[];
  static ValueNotifier<List<UploadMedical>> uploadMed =
      ValueNotifier<List<UploadMedical>>(<UploadMedical>[]);

  static Future<List> searchFordocAndSpec({String query, List searchTypes}) async {
    var gettedValueFromApi;
    gettedValueFromApi =
        await TeleConsultationApiCalls.searchByDocAndSpec(query: query, searchTypes: searchTypes);
    if (searchTypes.contains("consultant_name")) {
      List<SearchTeleConulstationData> consultants = [];
      List data1 = gettedValueFromApi["Medical_Consultation"];
      List data2 = gettedValueFromApi["Health_Consultation"];
      consultants.addAll(data1.map((e) => SearchTeleConulstationData.fromJson(e)).toList());
      consultants.addAll(data2.map((e) => SearchTeleConulstationData.fromJson(e)).toList());
      return consultants;
    } else {
      List<SpecialityList> specialities = [];
      List data1 = gettedValueFromApi["Medical_Consultation"][0]["speciality_list"] ?? [];
      List data2 = gettedValueFromApi["Health_Consultation"][0]["speciality_list"] ?? [];
      specialities
          .addAll(data1.map((e) => SpecialityList(specialityName: e, specialityType: "")).toList());
      specialities
          .addAll(data2.map((e) => SpecialityList(specialityName: e, specialityType: "")).toList());
      return specialities;
    }
  }

  static Future<List<SpecialityList>> medicalHealthConsultantsSpecialityfunc() async {
    Map<String, dynamic> gettingValueSpeciality;
    gettingValueSpeciality = await TeleConsultationApiCalls.medicalHealthConsultantsSpeciality(
        startIndex: 1, endIndex: 100);

    ///Api Call
    List<dynamic> specialityList = gettingValueSpeciality['specialityList'];
    specName.value.clear();
    specName.notifyListeners();
    specialityList.map((dynamic e) => specName.value.add(SpecialityList.fromJson(e))).toList();
    specName.notifyListeners();
    return specName.value;
  }

  static Future<List<AppointmentsTimings>> getAvailableSlotList(
      {String ihlConsultantID, String vendorID}) async {
    var data;
    data = await TeleConsultationApiCalls.getAvailableSlot(
        ihlConsultantID: ihlConsultantID, vendorID: vendorID);
    List tileNameList = data;
    timingsList.clear();
    // timingsList.notifyListeners();
    try {
      tileNameList.map((e) => timingsList.add(AppointmentsTimings.fromJson(e))).toList();
    } catch (e) {
      print(e);
    }
    selectedDateTile.notifyListeners();
    return timingsList;
  }

  // static method to get a list of cancelled slot list
  static Future<List<AppointmentsTimings>> getCancelledSlotList(
      {String ihlConsultantID, String reason, String appointId}) async {
    // declare a variable to store the data
    var data;
    // call the api to get the data
    data = await TeleConsultationApiCalls.getSlotsCancelled(
        consultId: ihlConsultantID, reason: reason, appointId: appointId);
    // notify the listeners
    selectedDateTile.notifyListeners();
    // return the data
    return data;
  }

  static List<SpecialityList> tempList = <SpecialityList>[];
  static int tempNumber = 0;

  static Future<List<DoctorModel>> doctorsCallsModelSpeciality(
      {String spec, List<SpecialityList> specList}) async {
    if (tempList == null || tempList.isEmpty) {
      tempList = specList;
    }
    Map<String, dynamic> gettingDoctorsInfo;
    gettingDoctorsInfo = await TeleConsultationApiCalls.gettingDoctorsBySpeciality(specName: spec);
    List<dynamic> doctorList = gettingDoctorsInfo['specialityList'];
    doctors.value.clear();
    doctors.notifyListeners();
    List<DoctorModel> docList = <DoctorModel>[];
    doctorList.map((dynamic e) => docList.add(DoctorModel.fromJson(e))).toList();
    docList = affiliationFilter(docList: docList);
    if (docList.isEmpty && tempNumber < tempList.length - 1) {
      tempNumber++;
      return doctorsCallsModelSpeciality(spec: tempList[tempNumber].specialityName);
    } else {
      doctors.value = docList;
      doctors.notifyListeners();
      return doctors.value;
    }
  }

  static Future<List<SpecialityList>> allSpecGetter() async {
    var gettingValueSpeciality;
    gettingValueSpeciality = await TeleConsultationApiCalls.medicalHealthConsultantsSpeciality(
        startIndex: 1, endIndex: 100);
    List specialityList = gettingValueSpeciality['specialityList'];
    List<SpecialityList> allSpecs = [];
    specialityList.map((e) => allSpecs.add(SpecialityList.fromJson(e))).toList();
    return allSpecs;
  }

  static Future<String> shareMedicalDocAfterAppointment(
      {var selectedDocIdList, String appointmentId, String ihl_consultant_id}) async {
//Declare a list of dynamic type to store the appointments
    // List<SendMedicalReport> sharemedicalFilesappointments = [];
//Call the API to get the response data
    var responseData = await TeleConsultationApiCalls.shareMedicalDocAfterApointmentCall(
        selectedDocIdList: selectedDocIdList,
        appointmentId: appointmentId,
        ihl_consultant_id: ihl_consultant_id);
    print(responseData);
    String filesList = responseData['status'];

    // filesList.map((e) => sharemedicalFilesappointments.add(SendMedicalReport.fromJson(e))).toList();
//Return the list of appointments
    print('object$filesList');
    return filesList;
  }

  static Future getAppointmentDetails({String appointmentId}) async {
    Map<String, dynamic> data;
    data = await TeleConsultationApiCalls.appointmentDetailsCalls(appointmentId: appointmentId);
    ConsultationSummaryModel consultationSummary;
    try {
      consultationSummary = ConsultationSummaryModel.fromJson(data);
    } catch (e) {
      debugPrint(e.toString());
    }
    return consultationSummary;
  }

  static Future<List<DoctorModel>> gettingDocList({String specName}) async {
    var data;
    data = await TeleConsultationApiCalls.gettingDoctorsBySpeciality(
        startIndex: 1, endIndex: 100, specName: specName);
    List doctorList = data['specialityList'];
    List<DoctorModel> docList = [];
    try {
      doctorList = removeDuplicates(list: doctorList, key: "ihl_consultant_id");
      doctorList.map((e) => docList.add(DoctorModel.fromJson(e))).toList();
      docList = affiliationFilter(docList: docList);
    } catch (e) {
      print(e);
    }
    return docList;
  }

  static Future<List<AllMedicalFiles>> allMedicalFilesList() async {
    var data;
    data = await TeleConsultationApiCalls.gettingAllMedicalFilesList();
    List medicalList = data;
    try {
      medFilesList.value.clear();
      medFilesList.notifyListeners();
      medicalList.map((e) => medFilesList.value.add(AllMedicalFiles.fromJson(e))).toList();
    } catch (e) {
      print(e);
    }
    return medFilesList.value;
  }

  static Future<String> getConsultantLiveStatus({String consultantid, String vendorId}) async {
    getAvailableTime(status) async {
      if (status != 'Offline' && status != 'busy') status = 'Offline';
      try {
        var availableSlot = await Apirepository()
            .yetToArrive(consultId: consultantid, venderName: vendorId, status: status);
        if (availableSlot[0] != 'NA') {}
        return availableSlot[1];
      } catch (e) {
        print(e.toString());
        return 'no Slots Found';
      }
    }

    var datas;
    datas = await TeleConsultationApiCalls.consultantLiveStatusCall(consultant_id: consultantid);
    var listTimings = datas;
    if (listTimings != '"[]"') {
      var parsedString = listTimings.toString().replaceAll('&quot', '"');
      var parsedString1 = parsedString.replaceAll(";", "");
      var parsedString2 = parsedString1.replaceAll('"[', '[');
      var parsedString3 = parsedString2.replaceAll(']"', ']');
      var finalOutput = json.decode(parsedString3);
      var doctorId = consultantid;
      if (doctorId == finalOutput[0]['consultant_id']) {
        noSlotsAvailable.value =
            await getAvailableTime(finalOutput[0]['status'].toString().toLowerCase());
      }
    }
    return noSlotsAvailable.value;
  }

  static Future<Map> getUploadMedicalDocumentList(
      {String filename,
      String extension,
      String path,
      String chooseType,
      String fileNametext,
      BuildContext context}) async {
    var data;
    data = await TeleConsultationApiCalls.gettingUploadMedicalDocumentList(
        filename: filename,
        extension: extension,
        chosenType: chooseType,
        path: path,
        fileNametext: fileNametext,
        context: context);
    Map uploadmedicalList = data;
    print(uploadmedicalList);
    try {
      uploadMed.value.clear();
      medFilesList.notifyListeners();
      // uploadMed.value=uploadmedicalList
    } catch (e) {
      print(e);
    }
    medFilesList.notifyListeners();
    return uploadmedicalList;
  }

  static Future<Uint8List> vendorImage({String vendorName}) async {
    final ImageCacheManager imageCacheManager = ImageCacheManager();
    Uint8List cachedImage = imageCacheManager.getImage(vendorName);
    if (cachedImage != null) {
      log("There is a image in cache");
      return cachedImage;
    } else {
      dynamic data = await TeleConsultationApiCalls.vendorImageGetter(vendorName: vendorName);
      if (data == null || data == "" || data["error_message"] == "images not found") {
        //Transperent Image base64 string 👇🏻
        return base64Decode(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mN88/lNPQAI6gNM1il6pAAAAABJRU5ErkJggg==");
      } else {
        String img = data["status"]
            .replaceAll('data:image/jpeg;base64,', '')
            .replaceAll('}', '')
            .replaceAll('data:image/jpegbase64,', '');
        imageCacheManager.cacheImage(url: vendorName, imageData: base64Decode(img));
        return base64Decode(img);
      }
    }
  }

  static Future<List<Appointment>> AppointmentsApproved() async {
    //Declare a variable to store the parsed date
    DateTime parseDate;
    //Declare a list to store the appointments
    List<Appointment> appointmentList = [];
    //Declare a variable to store the result of the API call
    var gettingValueAppointments;
    //Call the API call to get the appointments
    gettingValueAppointments =
        await TeleConsultationApiCalls.MyAppointmentsApprovedCall(startIndex: 1, endIndex: 100);
    //Get the list of appointments from the API call
    List AppointmentsList = gettingValueAppointments['Appointments'];
    //Clear the list of appointments
    appointments.value.clear();
    //Notify the listeners
    appointments.notifyListeners();

    AppointmentsList.map((e) => appointments.value.add(Appointment.fromJson(e))).toList();
    //Map the list of appointments and add them to the list of appointments
    appointments.value.addAll(AppointmentsList.map((e) => Appointment.fromJson(e)).toList());
    //Remove the appointments that have already started
    appointments.value.removeWhere((element) {
      //Parse the date and check if it is after the current date
      bool value = DateFormat("yyyy-MM-dd HH:mm a")
          .parse(element.appointmentEndTime)
          .isAfter(DateTime.now());
      //Return the opposite of the value
      return !value;
    });
    //Print the list of appointments
    //Notify the listeners
    appointments.notifyListeners();
    //Return the list of appointments
    return appointments.value;
  }

  static bool checkAppointmentExpiry(
      {var appointmentStartTime, appointmentStatus, callStatus, callFees}) {
    bool expiry =
        DateFormat("yyyy-MM-dd HH:mm a").parse(appointmentStartTime).isBefore(DateTime.now());
    bool callValue = (callStatus == "N/A" || callStatus == "Missed" || callStatus == "missed");
    bool appointmentValue = (appointmentStatus == "Canceled" ||
        appointmentStatus == "canceled" ||
        appointmentStatus == "Completed" ||
        appointmentStatus == "completed" ||
        callFees == "0");
    return callValue && expiry && !appointmentValue;
  }

  static List<CompletedAppointment> expiredListFilter(var appointments) {
    List<CompletedAppointment> expiredAppointments = appointments.where((element) {
      bool value = DateFormat("yyyy-MM-dd HH:mm a")
          .parse(element.appointmentEndTime)
          .isBefore(DateTime.now());
      return value;
    }).toList();
    return expiredAppointments;
  }

  static Future<List<CompletedAppointment>> appointmentList(
      {int startIndex, int endIndex, String type}) async {
    //Declare a list of dynamic type to store the appointments
    List<CompletedAppointment> appointments = <CompletedAppointment>[];
    //Call the API to get the response data
    List<dynamic> responseData = await TeleConsultationApiCalls.myAppointmentApi(
        startIndex: startIndex, endIndex: endIndex, type: type);
    if (type == "Requested") {
      List<dynamic> rs2 = await TeleConsultationApiCalls.myAppointmentApi(
          startIndex: 0, endIndex: 510, type: "Approved");
      appointments.addAll(responseData.map((e) => CompletedAppointment.fromJson(e)).toList());
      appointments.addAll(rs2.map((e) => CompletedAppointment.fromJson(e)).toList());
    } else if (type == "Canceled") {
      List<dynamic> responseData2 = await TeleConsultationApiCalls.myAppointmentApi(
          startIndex: startIndex, endIndex: endIndex, type: "Rejected");
      appointments.addAll(responseData.map((e) => CompletedAppointment.fromJson(e)).toList());
      appointments.addAll(responseData2.map((e) => CompletedAppointment.fromJson(e)).toList());
    } else {
      //Map the response data to CompletedAppointment type and store it in the list
      appointments = responseData.map((e) => CompletedAppointment.fromJson(e)).toList();
    }
    //Return the list of appointments
    return appointments;
  }

  static Future<List> searchDoc({String query, List searchTypes}) async {
    var gettedValueFromApi;
    List<DoctorModel> consultants = [];
    gettedValueFromApi =
        await TeleConsultationApiCalls.searchByDocAndSpec(query: query, searchTypes: searchTypes);
    if (searchTypes.contains("consultant_name")) {
      List data1 = gettedValueFromApi["Medical_Consultation"];
      List data2 = gettedValueFromApi["Health_Consultation"];
      consultants.addAll(data1.map((e) => DoctorModel.fromJson(e)).toList());
      consultants.addAll(data2.map((e) => DoctorModel.fromJson(e)).toList());
    }
    return consultants;
  }

  static List<DoctorModel> affiliationFilter({List<DoctorModel> docList}) {
    //in this function we are removing the non-affiliated things and unwanted affiliation
    //doctos in the below section . the below code retutning the list of doctos that only
    //holds the selected affiliated doctors. ⚪️⚪️⚪️
    if (selectedAffiliationfromuniquenameDashboard != "") {
      docList.removeWhere((DoctorModel element) {
        bool af = true;
        if (element.affilationExcusiveData != null) {
          List<AffilationArray> affiLi = element.affilationExcusiveData.affilationArray;
          for (AffilationArray e in affiLi) {
            if (e.affilationUniqueName == selectedAffiliationfromuniquenameDashboard) af = false;
          }
          return af;
        } else {
          return element.exclusiveOnly ?? false;
        }
      });
    } else {
      docList.removeWhere((DoctorModel element) => element.exclusiveOnly);
    }
    return docList;
  }

//The below function is used to remove duplicates based on the provided key and it's a common funciton ✅
  static List<dynamic> removeDuplicates({List<dynamic> list, String key}) {
    //the seen is used to store the check the doctor is already added or not
    Set<dynamic> seen = <dynamic>{};
    List<dynamic> uniqueList = <dynamic>[];
// in this loop function we are adding the doctors list which is not duplicated with the provided key
    for (Map<String, dynamic> item in list) {
      if (seen.add(item[key])) {
        uniqueList.add(item);
      }
    }
    return uniqueList;
  }

  permissionCheckerForCall({Function nav}) async {
    await Permission.camera.request();
    await Permission.microphone.request();
    bool camera = await Permission.camera.isDenied;
    bool microphone = await Permission.microphone.isDenied;
    if (camera || microphone) {
      bool cameraCheck = await Permission.camera.isDenied;
      bool microphoneCheck = await Permission.microphone.isDenied;
      if (cameraCheck == false && microphoneCheck == false) {
        nav();
      } else {
        Get.snackbar('Info', 'Allow microphone and camera for call access.',
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.info),
            snackPosition: SnackPosition.TOP);
        Timer(const Duration(seconds: 3), () async {
          await openAppSettings();
        });
      }
    } else {
      log("Permission granted for Camera and MicroPhone");
      nav();
    }
  }
}
