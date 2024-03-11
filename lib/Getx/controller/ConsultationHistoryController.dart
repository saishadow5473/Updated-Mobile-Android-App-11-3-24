import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:ihl/Getx/controller/listOfChallengeContoller.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api.dart';

class ConsultationHistoryController extends GetxController {
  final ListChallengeController listChallengeController = Get.find();
  final PagingController<int, dynamic> pagingController = PagingController(firstPageKey: 0);
  var count = 0;
  List history = [],
      allList = [],
      completed = [],
      requested = [],
      rejected = [],
      approved = [],
      currentList = [],
      cancelled = [];
  List completdCon = [];
  List approvedCon = [];
  List requestedCon = [];
  List rejectedCon = [];
  List cancelledCon = [];
  var filterType;
  bool filterBool = true;
  String _ihlUserId;

  int _pageSize = 0;
  bool isLoading = true;
  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    getConsultationHistory(10, filterType);
    pagingController.addPageRequestListener((startIndexPage) {
      print(startIndexPage);
      print('Pagination Called');
      fetchPage(startIndexPage);
    });
    // TODO: implement onInit
    super.onInit();
  }

  void updateSearchTerm(String searchTerm) {
    filterBool = true;
    filterType = searchTerm;
    pagingController.refresh();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      final isLastPage = currentList.length < _pageSize;
      if (isLastPage) {
        getConsultationHistory(pageKey, filterType);
        pagingController.appendLastPage(currentList);
        // tileLoad = false;
      } else {
        final nextPageKey = pageKey + currentList.length;
        getConsultationHistory(nextPageKey, filterType);
        pagingController.appendPage(currentList, nextPageKey);
        print(currentList.length);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  Future getApprovedConsultation(int endPage) async {
    try {
      final getApprovedConsultant = await Dio().post(
        API.iHLUrl + "/consult/get_user_consultation_history_pagination",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          'ihl_id': listChallengeController.userid,
          'start_index': 0,
          'end_index': endPage,
          "status": "Approved"
        },
      );
      var apprvdConsult = getApprovedConsultant.data["consultation_history"];
      for (int i = 0; i < apprvdConsult.length; i++) {
        approvedCon.add(apprvdConsult[i]);
      }
    } on DioError catch (e) {
      throw checkAndThrowError(e.type);
    }
  }

  Future getCanceldConsultation(int endPage) async {
    try {
      final getCanceldConsultant = await Dio().post(
        API.iHLUrl + "/consult/get_user_consultation_history_pagination",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          'ihl_id': listChallengeController.userid,
          'start_index': 0,
          'end_index': endPage,
          "status": "Canceled"
        },
      );
      var cancledConsult = getCanceldConsultant.data["consultation_history"];
      for (int i = 0; i < cancledConsult.length; i++) {
        cancelledCon.add(cancledConsult[i]);
      }
    } on DioError catch (e) {
      throw checkAndThrowError(e.type);
    }
  }

  Future getCompletedConsultation(int endPage) async {
    try {
      final getCmpletedConsultant = await Dio().post(
        API.iHLUrl + "/consult/get_user_consultation_history_pagination",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          'ihl_id': listChallengeController.userid,
          'start_index': 0,
          'end_index': endPage,
          "status": "completed"
        },
      );
      var completedConsultnt = getCmpletedConsultant.data["consultation_history"];
      for (int i = 0; i < completedConsultnt.length; i++) {
        completdCon.add(completedConsultnt[i]);
      }
    } on DioError catch (e) {
      throw checkAndThrowError(e.type);
    }
  }

  Future getRequstedConsultation(int endPage) async {
    try {
      final getRequstedConsultant = await Dio().post(
        API.iHLUrl + "/consult/get_user_consultation_history_pagination",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          'ihl_id': listChallengeController.userid,
          'start_index': 0,
          'end_index': endPage,
          "status": "Requested"
        },
      );
      var requstedConsultnt = getRequstedConsultant.data["consultation_history"];
      for (int i = 0; i < requstedConsultnt.length; i++) {
        requestedCon.add(requstedConsultnt[i]);
      }
    } on DioError catch (e) {
      throw checkAndThrowError(e.type);
    }
  }

  Future getRejectedConsultation(int endPage) async {
    try {
      final getRejectedConsultant = await Dio().post(
        API.iHLUrl + "/consult/get_user_consultation_history_pagination",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          'ihl_id': listChallengeController.userid,
          'start_index': 0,
          'end_index': endPage,
          "status": "rejected"
        },
      );
      var rejectedConsultnt = getRejectedConsultant.data["consultation_history"];
      for (int i = 0; i < rejectedConsultnt.length; i++) {
        rejectedCon.add(rejectedConsultnt[i]);
      }
    } on DioError catch (e) {
      throw checkAndThrowError(e.type);
    }
  }

  Future getConsultationHistory(int endPage, var fliterType) async {
    history = [];
    allList = [];
    completed = [];
    requested = [];
    rejected = [];
    approved = [];
    cancelled = [];
    print('get');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ihlUserId = prefs.getString("ihlUserId");
    try {
      final getUserDetails = await Dio().post(
        API.iHLUrl + "/consult/get_user_consultation_history_pagination",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: {
          'ihl_id': _ihlUserId,
          'start_index': 0,
          'end_index': endPage == 0 || endPage < 10 ? 10 : endPage,
          "status": fliterType
        },
      );
      if (getUserDetails.statusCode == 200) {
        history = getUserDetails.data['consultation_history'];
        count = getUserDetails.data["total_count"];
        print(history.length);
        var currentDateTime = new DateTime.now();

        for (int i = 0; i < history.length; i++) {
          var endTime = history[i]["appointment_details"]["appointment_end_time"];
          String appointmentEndTime = endTime;

          if (appointmentEndTime[7] != '-') {
            String appEndTime = '';
            for (var i = 0; i < appointmentEndTime.length; i++) {
              if (i == 5) {
                appEndTime += '0' + appointmentEndTime[i];
              } else {
                appEndTime += appointmentEndTime[i];
              }
            }
            appointmentEndTime = appEndTime;
          }
          if (appointmentEndTime[10] != " ") {
            String appEndTime = '';
            for (var i = 0; i < appointmentEndTime.length; i++) {
              if (i == 8) {
                appEndTime += '0' + appointmentEndTime[i];
              } else {
                appEndTime += appointmentEndTime[i];
              }
            }
            appointmentEndTime = appEndTime;
          }

          String appointmentEndTimeSubstring = appointmentEndTime.substring(11, 19);
          String appointmentEndDateSubstring = appointmentEndTime.substring(0, 10);
          DateTime endTimeFormatTime = DateFormat.jm().parse(appointmentEndTimeSubstring);
          String endTimeString = DateFormat("HH:mm:ss").format(endTimeFormatTime);
          String fullAppointmentEndDate = appointmentEndDateSubstring + " " + endTimeString;
          var appointmentEndingTime = DateTime.parse(fullAppointmentEndDate);

          if (appointmentEndingTime.isBefore(currentDateTime) ||
              ((history[i]["appointment_status"] == "Completed" ||
                      history[i]["appointment_status"] == "completed") &&
                  (history[i]["call_status"] == "Completed" ||
                      history[i]["call_status"] == "completed")) ||
              (history[i]["appointment_status"] == "Canceled" ||
                  history[i]["appointment_status"] == "canceled") ||
              (history[i]["appointment_status"] == "Rejected" ||
                  history[i]["appointment_status"] == "rejected")) {
            allList.add(history[i]);
          }

          if (appointmentEndingTime.isBefore(currentDateTime) &&
              (history[i]["appointment_status"] == "Completed" ||
                  history[i]["appointment_status"] == "completed")) {
            completed.add(history[i]);
          } else if (appointmentEndingTime.isBefore(currentDateTime) &&
              (history[i]["appointment_status"] == "Approved" ||
                  history[i]["appointment_status"] == "approved")) {
            approved.add(history[i]);
          } else if (appointmentEndingTime.isBefore(currentDateTime) &&
              (history[i]["appointment_status"] == "Rejected" ||
                  history[i]["appointment_status"] == "rejected")) {
            rejected.add(history[i]);
          } else if (appointmentEndingTime.isBefore(currentDateTime) &&
              (history[i]["appointment_status"] == "Requested" ||
                  history[i]["appointment_status"] == "requested")) {
            requested.add(history[i]);
          } else if (appointmentEndingTime.isBefore(currentDateTime) &&
              (history[i]["appointment_status"] == "canceled" ||
                  history[i]["appointment_status"] == "Canceled")) {
            cancelled.add(history[i]);
          }
        }
        currentList = history;
        filterBool = false;
        isLoading = false;
        update(['consultationHistoryloading']);
      }
    } on DioError catch (e) {
      throw checkAndThrowError(e.type);
    }
  }

  static checkAndThrowError(DioErrorType errorType) {
    switch (errorType) {
      case DioErrorType.sendTimeout:
        log('Send TimeOut');
        throw Exception('sendTimeout');
        break;
      case DioErrorType.receiveTimeout:
        log('Receive TimeOut');
        throw Exception('receiveTimeout');
        break;
      case DioErrorType.response:
        log('Error Response');
        throw Exception('response');
        break;
      case DioErrorType.cancel:
        log('Connection Cancel');
        throw Exception('cancel');
        break;
      case DioErrorType.other:
        log('Other Error');
        throw Exception('other');
        break;
      case DioErrorType.connectTimeout:
        log('Connect Timeout');
        throw Exception('connectTimeout');
        break;
    }
  }
}
