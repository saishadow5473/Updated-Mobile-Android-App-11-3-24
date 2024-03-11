import '../../../new_design/data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../../../new_design/module/online_serivices/data/model/get_subscribtion_list.dart';
import '../data/model/getClassSpecalityModel.dart';


class OnlineClassState {}

class ApiCallInitialClassState extends OnlineClassState {}

class ApiCallLoadingClassState extends OnlineClassState {}

class ApiCallLoadedClassState extends OnlineClassState {
  GetClassSpeciality data;
  ApiCallLoadedClassState({this.data});
}

class ApiCallErrorClassState extends OnlineClassState {
  final String message;
  ApiCallErrorClassState({this.message});
}

class StreamOnlineClassState {}

class StreamApiCallInitialState extends StreamOnlineClassState {}

class StreamApiCallLoadingState extends StreamOnlineClassState {}

class StreamApiCallLoadedState extends StreamOnlineClassState {
  UpcomingDetails data;
  StreamApiCallLoadedState({this.data});
}

class StreamApiCallErrorState extends StreamOnlineClassState {
  final String message;
  StreamApiCallErrorState({this.message});
}

class SubscriptionFilterState {}

class FilterInitialState extends SubscriptionFilterState {}

class FilterLoadingState extends SubscriptionFilterState {
  final String filterType;
  FilterLoadingState({this.filterType});
}

class FilterLoadedState extends SubscriptionFilterState {
  final List<Subscription> subscriptionList;
  final String filterType;
  FilterLoadedState({this.subscriptionList,this.filterType});
}

class FilterErrorState extends SubscriptionFilterState {
  String message;
  FilterErrorState({this.message});
}
