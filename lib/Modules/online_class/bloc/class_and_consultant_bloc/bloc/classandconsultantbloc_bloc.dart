import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../constants/spKeys.dart';
import '../../../../../new_design/module/online_serivices/data/repositories/online_services_api.dart';
import '../../../../../new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../../data/model/consultantAndClassListModel.dart';
import '../../../data/repositories/class_and_consultant_api.dart';

part 'classandconsultantbloc_event.dart';
part 'classandconsultantbloc_state.dart';

class ClassandconsultantblocBloc
    extends Bloc<ClassandconsultantblocEvent, ClassandconsultantblocState> {
  ClassandconsultantblocBloc() : super(ClassandconsultantblocInitial()) {
    on<ClassandconsultantblocEvent>(fetchClassAndConsultant);
  }

  fetchClassAndConsultant(
      ClassandconsultantblocEvent event, Emitter<ClassandconsultantblocState> emit) async {
    final OnlineServicesApiCall onlineServicesApiCall = OnlineServicesApiCall();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var historyClass;
    Map teleConsulResponse;
    List subscriptionHistoryList;
    try {
       historyClass = prefs.get(SPKeys.userDetailsResponse);
       teleConsulResponse = json.decode(historyClass);
       subscriptionHistoryList = teleConsulResponse["my_subscriptions"];
    }
    catch(e){
      await onlineServicesApiCall.updateUserDetails();
      historyClass = prefs.get(SPKeys.userDetailsResponse);
      teleConsulResponse = json.decode(historyClass);
      subscriptionHistoryList = teleConsulResponse["my_subscriptions"];
    }
    if (event is GetClassandConsultantEvent) {
      try {
        ClassAndConsultantApi.paginationStartIndex = 1;
        ClassAndConsultantApi.paginationEndIndex = 10;
        ClassAndConsultantListModel data = await fetchdata(event.category);
        data.consultantAndClassList.removeWhere((ConsultantAndClassList element) =>
            subscriptionHistoryList.any((historyElement) =>
            element.classDetail!=null?element.classDetail.courseId == historyElement["course_id"] &&
                (historyElement["approval_status"] == "Accepted" ||
                    historyElement["approval_status"] == "Requested"):false));
        emit(ClassandconsultantUpdated(data));
      } catch (e) {
        print('data');
      }
    } else if (event is GetClassandConsPaginationEvent) {
      emit(ClassandconsultantPagination(event.data));
      ClassAndConsultantListModel data = ClassAndConsultantListModel();
      data = event.data;
      ClassAndConsultantListModel temp = await fetchdata(event.category);
      data.consultantAndClassList.addAll(temp.consultantAndClassList);
      if (selectedAffiliationfromuniquenameDashboard == null ||
          selectedAffiliationfromuniquenameDashboard == "") {
        data.consultantAndClassList.removeWhere((ConsultantAndClassList element) {
          if (element.consultantDetail != null) {
            return element.consultantDetail.exclusiveOnly;
          }
          return false;
        });
      }
      data.consultantAndClassList.removeWhere((ConsultantAndClassList element) =>
          subscriptionHistoryList.any((historyElement) =>
          element.classDetail!=null?element.classDetail.courseId == historyElement["course_id"] &&
              (historyElement["approval_status"] == "Accepted" ||
                  historyElement["approval_status"] == "Requested"):false));
      emit(ClassandconsultantUpdated(data));
    } else {
      emit(ClassandconsultantblocInitial());
    }
  }

  Future<ClassAndConsultantListModel> fetchdata(String category) async {
    List<String> affilaitonList = <String>[];
    if (selectedAffiliationfromuniquenameDashboard != null &&
        selectedAffiliationfromuniquenameDashboard != "") {
      affilaitonList.add(selectedAffiliationfromuniquenameDashboard);
    }
    ClassAndConsultantListModel data = await ClassAndConsultantApi().getData(
      wellbeing: category!="Health E-Market"?category:null,
      affi: affilaitonList,
    );
    return data;
  }
}
