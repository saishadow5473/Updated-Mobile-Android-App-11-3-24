

import '../../../../Modules/online_class/data/model/getClassSpecalityModel.dart';
import '../../../../Modules/online_class/data/model/getSubsrciptionListModel.dart';
import '../../../data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../data/model/get_appointment_list_module.dart';
import '../data/model/get_consultant_list.dart';
import '../data/model/get_specality_module.dart';
import '../data/model/get_subscribtion_list.dart';

class OnlineServicesState {}

class ApiCallInitialState extends OnlineServicesState {}

class ApiCallLoadingState extends OnlineServicesState {}

class ApiCallLoadedState extends OnlineServicesState {
  GetOnlineServicesSpeciality classSpec;
  GetOnlineServicesSpeciality docSpec;
  GetConsultantList consultantList;
  ApiCallLoadedState({this.classSpec, this.docSpec,this.consultantList});
}

class ApiCallErrorState extends OnlineServicesState {
  final String message;
  ApiCallErrorState({this.message});
}

class StreamOnlineServicesState {}

class StreamApiInitialState extends StreamOnlineServicesState {}

class StreamApiLoadingState extends StreamOnlineServicesState {}

class StreamApiLoadedState extends StreamOnlineServicesState {
  GetAppointmentList appoinmtmentList;
  GetSubscriptionList subscribeList;
  StreamApiLoadedState({this.appoinmtmentList,this.subscribeList});
}

class StreamApiErrorState extends StreamOnlineServicesState {
  final String message;
  StreamApiErrorState({this.message});
}

// class SubscriptionFilterState {}

// class FilterInitialState extends SubscriptionFilterState {}
//
// class FilterLoadingState extends SubscriptionFilterState {}
//
// class FilterLoadedState extends SubscriptionFilterState {
//   final List<Subscription> subscriptionList;
//   FilterLoadedState({this.subscriptionList});
// }
// class FilterErrorState extends SubscriptionFilterState{
//   String message;
//   FilterErrorState({this.message});
// }