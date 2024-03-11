import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../new_design/data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../../../new_design/data/providers/network/apis/dashboardApi/retriveUpcommingDetails.dart';
import '../data/model/getClassSpecalityModel.dart';
import '../data/model/getSubsrciptionListModel.dart';
import '../data/repositories/online_class_api.dart';
import 'online_class_events.dart';
import 'online_class_state.dart';

class OnlineClassApiBloc extends Bloc<OnlineClassEvent, OnlineClassState> {
  OnlineClassApiBloc() : super(OnlineClassState()) {
    on<OnlineClassEvent>(mapEventToState);
  }
  final OnlineClassApiCall _onlineClassApiCall = OnlineClassApiCall();
  void mapEventToState(OnlineClassEvent event, Emitter<OnlineClassState> emit) async {
    emit(ApiCallInitialClassState());
    if (event is OnlineClassApiEvent) {
      emit(ApiCallLoadingClassState());
      try {
        GetClassSpeciality temp = await _fetchData(event.data);

        emit(ApiCallLoadedClassState(data: temp));
      } catch (e) {
        emit(ApiCallErrorClassState(message: e.toString()));
      }
    }
  }

  Future<GetClassSpeciality> _fetchData(String apiName) async {
    if (apiName == "specialty") {
      return await _onlineClassApiCall.getOnlineClassSpecality(null, null);
    } else {
      return null;
    }
  }
}

class StreamOnlineClassApiBloc extends Bloc<StreamOnlineClassEvent, StreamOnlineClassState> {
  StreamOnlineClassApiBloc() : super(StreamOnlineClassState()) {
    on<StreamOnlineClassEvent>(mapEventToState);
  }
  final OnlineClassApiCall _onlineClassApiCall = OnlineClassApiCall();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot> _subscription;
  void mapEventToState(StreamOnlineClassEvent event, Emitter<StreamOnlineClassState> emit) async {
    emit(StreamApiCallInitialState());
    if (event is StreamOnlineClassApiEvent) {
      emit(StreamApiCallLoadingState());
      try {
        UpcomingDetails temp = await _fetchData(event.data);

        emit(StreamApiCallLoadedState(data: temp));
      } catch (e) {
        emit(StreamApiCallErrorState(message: e.toString()));
      }
    }
    //  emit(InitialTrainerState());
  }

  Future<UpcomingDetails> _fetchData(String apiName) async {
    if (apiName == "subscriptionDetails") {
      return await RetriveDetials().upcomingDetails(fromChallenge: false);
    } else {
      return null;
    }
  }
}

class SubscrptionFilterBloc extends Bloc<SubscriptionFilterEvent, SubscriptionFilterState> {
  SubscrptionFilterBloc() : super(SubscriptionFilterState()) {
    on<SubscriptionFilterEvent>(mapEventToState);
  }
  final OnlineClassApiCall _onlineClassApiCall = OnlineClassApiCall();
  void mapEventToState(SubscriptionFilterEvent event, Emitter<SubscriptionFilterState> emit) async {
    emit(FilterInitialState());
    if (event is FilterSubscriptionEvent) {
      emit(FilterLoadingState(filterType: event.filterType));
      try {
        var temp = await _subcriptionFilter(endIndex: event.endIndex, filterType: event.filterType);
        emit(FilterLoadedState(subscriptionList: temp, filterType: event.filterType));
      } catch (e) {
        emit(FilterErrorState(message: e.toString()));
      }
    }
  }

  Future<List> _subcriptionFilter({int endIndex, String filterType}) async {
    return filterType == "Completed"
        ? await _onlineClassApiCall.getSubscriptionCompletedHistory(endPage: endIndex)
        : await _onlineClassApiCall.getSubscriptionHistory(endPage: endIndex, filterType: filterType);
  }
}
