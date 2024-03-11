import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/TeleconsultationModels/appointmentModels.dart';
import 'package:intl/intl.dart';
import '../../../presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../data/model/get_appointment_list_module.dart';
import '../data/model/get_consultant_list.dart';
import '../data/model/get_specality_module.dart';
import '../data/model/get_subscribtion_list.dart';
import '../data/repositories/online_services_api.dart';
import '../functionalities/online_services_data_cache.dart';
import 'online_services_api_event.dart';
import 'online_services_api_state.dart';

class OnlineServicesApiBloc extends Bloc<OnlineServicesEvent, OnlineServicesState> {
  OnlineServicesApiBloc() : super(OnlineServicesState()) {
    on<OnlineServicesEvent>(mapEventToState);
  }
  final OnlineServicesApiCall _onlineClassApiCall = OnlineServicesApiCall();
  void mapEventToState(OnlineServicesEvent event, Emitter<OnlineServicesState> emit) async {
    emit(ApiCallInitialState());
    if (event is OnlineServicesApiEvent) {
      emit(ApiCallLoadingState());
      try {
        log("bloc Fecth Started");
        //The Below If conditions are used to store
        //if the data is already exsits don't need to fecth the same data again.⚪️
        if (OnlineServiceCache.selectedAffiliationName !=
            selectedAffiliationfromuniquenameDashboard) {
          OnlineServiceCache.resetAllCache();
          OnlineServiceCache.selectedAffiliationName = selectedAffiliationfromuniquenameDashboard;
        }
        //Checking the Class Spec list is already stored or Not ⚪️
        GetOnlineServicesSpeciality temp;
        if (OnlineServiceCache.classtSpecList != null) {
          log("bloc Now we are using existing data");
          temp = OnlineServiceCache.classtSpecList; // Api Call for class specialty
        } else {
          temp = await _fetchData(event.data); //
          OnlineServiceCache.classtSpecList = temp;
        }

        //Checking the Consultant spec List is already stored or Not ⚪️
        GetOnlineServicesSpeciality docSpec;
        if (OnlineServiceCache.consultantSpecList != null) {
          docSpec = OnlineServiceCache.consultantSpecList; // Api Call for class specialty
        } else {
          docSpec = await _fetchDocSpecData(event.data); // Api Call for Consultant specialty
          OnlineServiceCache.consultantSpecList = docSpec;
        }

        //Checking the Doc list is already stored or Not ⚪️
        GetConsultantList docList;
        if (OnlineServiceCache.consultatnList != null) {
          docList = OnlineServiceCache.consultatnList;
        } else {
          //We are providing the spec list to get the doctors list. Because we are fecthing the doctors
          //based on the affiliations , So we are using the specs for loop concept while receiveing
          // the null value for doctors ✅
          GetOnlineServicesSpeciality tempSpec = await _fetchDocSpecData(event.data);
          docList = await _fetchDocListData(apiName: event.data, specList: tempSpec.specialityList);
          OnlineServiceCache.consultatnList = docList;
        }
        log("bloc Fecth Ended");
        emit(ApiCallLoadedState(classSpec: temp, docSpec: docSpec, consultantList: docList));
      } catch (e) {
        emit(ApiCallErrorState(message: e.toString()));
      }
    }
  }

  Future<GetOnlineServicesSpeciality> _fetchData(String apiName) async {
    if (apiName == "specialty") {
      return await _onlineClassApiCall.getOnlineClassSpecality(null, null);
    } else {
      return null;
    }
  }

  Future<GetOnlineServicesSpeciality> _fetchDocSpecData(String apiName) async {
    if (apiName == "specialty") {
      return await _onlineClassApiCall.getConsultantSpecality(null, null);
    } else {
      return null;
    }
  }

//this two variables are only used in the below function
//and the reason why the two variables are stored in the outside of the funciton, that is
//We need to call the function again and again so we need to hold the previous data to avoid refecthing the
//parameter data's✅
  static List<OnlineServicesSpecialityList> tempList = <OnlineServicesSpecialityList>[];
  static int tempNumber = 0;
  //The funciton that returns the affiliated and non-affiliated consultants based on the selected affiliations
  Future<GetConsultantList> _fetchDocListData(
      {String apiName, List<OnlineServicesSpecialityList> specList}) async {
    if (apiName == "specialty") {
      if (tempList == null || tempList.isEmpty) {
        tempList = specList;
      }
      Map<String, dynamic> gettingDoctorsInfo;
      gettingDoctorsInfo = await _onlineClassApiCall
          .getConsultantList(<String>[tempList[tempNumber].specialityName], null);

      List<dynamic> doctorList = gettingDoctorsInfo['specialityList'];
      List<ConsultantList> docList = <ConsultantList>[];
      doctorList.map((dynamic e) => docList.add(ConsultantList.fromJson(e))).toList();
      //In the below method we are removing the non-affiliated doctors or only providing the
      //global doctors alone based on the user ID
      docList = affiliationFilter(docList: docList);
      if (docList.isEmpty && tempNumber < tempList.length - 1) {
        //This one is used ot recall the funcition if the doc list is empty for the selected affiliation
        tempNumber++;
        return _fetchDocListData(apiName: apiName);
      } else {
        //in this case, If the doc list is not empty for the selected affi or for global users we will return the
        //Doc list to the bloc
        tempNumber = 0;
        docList = docList.toSet().toList();
        return GetConsultantList(
            totalCount: gettingDoctorsInfo["total_count"], consultantList: docList);
      }
    } else {
      return null;
    }
  }

  static List<ConsultantList> affiliationFilter({List<ConsultantList> docList}) {
    //in this function we are removing the non-affiliated things and unwanted affiliation
    //doctos in the below section . the below code retutning the list of doctos that only
    //holds the selected affiliated doctors. ⚪️⚪️⚪️
    if (selectedAffiliationfromuniquenameDashboard != "") {
      docList.removeWhere((ConsultantList element) {
        bool af = true;
        if (element.affilationExcusiveData != null) {
          List<AffilationArray> affiLi = element.affilationExcusiveData.affilationArray;
          for (AffilationArray e in affiLi) {
            if (e.affilationUniqueName == selectedAffiliationfromuniquenameDashboard) af = false;
          }
        }
        return af;
      });
    } else {
      docList.removeWhere((ConsultantList element) => element.exclusiveOnly ?? true);
    }
    return docList;
  }
}

class StreamOnlineServicesApiBloc
    extends Bloc<StreamOnlineServicesEvent, StreamOnlineServicesState> {
  StreamOnlineServicesApiBloc() : super(StreamOnlineServicesState()) {
    on<StreamOnlineServicesEvent>(mapEventToState);
  }

  final OnlineServicesApiCall _onlineClassApiCall = OnlineServicesApiCall();

  void mapEventToState(
      StreamOnlineServicesEvent event, Emitter<StreamOnlineServicesState> emit) async {
    emit(StreamApiInitialState());
    if (event is StreamOnlineServicesApiEvent) {
      emit(StreamApiLoadingState());
      try {
        //The Below If conditions are used to store
        //if the data is already exsits don't need to fecth the same data again.⚪️
        //Checking the Appointment List is already stored or Not
        GetAppointmentList appointmentList;
        // if (OnlineServiceCache.appointmentList != null) {
        //   appointmentList = OnlineServiceCache.appointmentList;
        // } else {
        appointmentList = await _fetchUserAppointmentList();
        //   OnlineServiceCache.appointmentList = appointmentList;
        // }

        //Checking the Subscribe List is already stored or Not ⚪️
        GetSubscriptionList subscribeList;
        // if (OnlineServiceCache.subscriptionList != null) {
        //   subscribeList = OnlineServiceCache.subscriptionList;
        // } else {
        subscribeList = await _fetchUserSubscribedList();
        //   OnlineServiceCache.subscriptionList = subscribeList;
        // }
        emit(StreamApiLoadedState(appoinmtmentList: appointmentList, subscribeList: subscribeList));
      } catch (e) {
        print(e);
      }
    }
  }

  Future<GetAppointmentList> _fetchUserAppointmentList() async {
    //In this funciton we are getting the proper approved and requested List form the API and
    // We are validating it by the time comapring method . If the Appointment is expried We are
    //removing the appointment by using sorting method in the list ✅
    GetAppointmentList aList;
    GetAppointmentList bList;
    aList = await _onlineClassApiCall.getAppointmentList(appointmentStatus: "Requested");
    bList = await _onlineClassApiCall.getAppointmentList(appointmentStatus: "Approved");
    aList.appointments.addAll(bList.appointments);
    aList.appointments.sort((CompletedAppointment a, CompletedAppointment b) =>
        a.appointmentStartTime.compareTo(b.appointmentStartTime));
    List<CompletedAppointment> needToRemove = expiredListFilter(aList.appointments);
    needToRemove
        .map((CompletedAppointment e) =>
            aList.appointments.removeWhere((CompletedAppointment ele) => e == ele))
        .toList();
    return aList;
  }

  Future<GetSubscriptionList> _fetchUserSubscribedList() async {
    GetSubscriptionList temp = await _onlineClassApiCall.getSubscriptionList("Accepted", null);
    temp.subscriptions.removeWhere((Subscription element) => element.title == " ");
    return temp;
  }

//The below funciton is used to return the expired appointments from the given list✅
  static List<CompletedAppointment> expiredListFilter(List<CompletedAppointment> appointments) {
    List<CompletedAppointment> expiredAppointments =
        appointments.where((CompletedAppointment element) {
      bool value = DateFormat("yyyy-MM-dd HH:mm a")
          .parse(element.appointmentEndTime)
          .isBefore(DateTime.now());
      return value;
    }).toList();
    return expiredAppointments;
  }
}

// class StreamOnlineClassApiBloc extends Bloc<StreamOnlineServicesEvent, StreamOnlineServicesState> {
//   StreamOnlineServicesApiBloc() : super(StreamOnlineServicesState()) {
//     on<StreamOnlineServicesEvent>(mapEventToState);
//   }
//   final OnlineServicesApiCall _onlineClassApiCall = OnlineServicesApiCall();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   StreamSubscription<DocumentSnapshot> _subscription;
//   void mapEventToState(StreamOnlineServicesEvent event, Emitter<StreamOnlineServicesState> emit) async {
//     emit(StreamApiCallInitialState());
//     if (event is StreamOnlineServicesApiEvent) {
//       emit(StreamApiCallLoadingState());
//       try {
//         UpcomingDetails temp = await _fetchData(event.data);
//
//         emit(StreamApiCallLoadedState(data: temp));
//       } catch (e) {
//         emit(StreamApiCallErrorState(message: e.toString()));
//       }
//     }
//     //  emit(InitialTrainerState());
//   }
//
//   Future<UpcomingDetails> _fetchData(String apiName) async {
//     if (apiName == "subscriptionDetails") {
//       return await RetriveDetials().upcomingDetails(fromChallenge: false);
//     } else {
//       return null;
//     }
//   }
// }
// Subscription Filter process
// class SubscrptionFilterBloc extends Bloc<SubscriptionFilterEvent, SubscriptionFilterState> {
//   SubscrptionFilterBloc() : super(SubscriptionFilterState()) {
//     on<SubscriptionFilterEvent>(mapEventToState);
//   }
//   final OnlineClassApiCall _onlineClassApiCall = OnlineClassApiCall();
//   void mapEventToState(SubscriptionFilterEvent event, Emitter<SubscriptionFilterState> emit) async {
//     emit(FilterInitialState());
//     if (event is FilterSubscriptionEvent) {
//       emit(FilterLoadingState());
//       try {
//         var temp =
//         await _subcriptionFilter(endIndex: event.endIndex, filterType: event.filterType);
//
//         emit(FilterLoadedState(subscriptionList: temp));
//       } catch (e) {
//         emit(FilterErrorState(message: e.toString()));
//       }
//     }
//   }
//
//   Future<List> _subcriptionFilter({int endIndex, String filterType}) {
//
//     return _onlineClassApiCall.getSubscriptionHistory(endPage: endIndex, filterType: filterType);
//   }
// }
