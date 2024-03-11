import '../data/model/get_appointment_list_module.dart';
import '../data/model/get_consultant_list.dart';
import '../data/model/get_specality_module.dart';
import '../data/model/get_subscribtion_list.dart';

//This class is used to store the cached data of the online services contents ⚪️
class OnlineServiceCache {
  static String selectedAffiliationName;
  static GetOnlineServicesSpeciality consultantSpecList;
  static GetOnlineServicesSpeciality classtSpecList;
  static GetConsultantList consultatnList;
  // static GetAppointmentList appointmentList;
  // static GetSubscriptionList subscriptionList;

//this function is used to remove the stored values from the recent fecth ⚪️
//NOTE ✅ >>> Use this function while the user booking the appointment or new subscription
//Because it's only fecthing the data in two state
//✅ 1. If the value of  "selectedAffiliationName" is changed .
//✅ 2. If the below funciton is called once.
  static resetAllCache() {
    selectedAffiliationName = null;
    classtSpecList = null;
    consultantSpecList = null;
    consultatnList = null;
    // appointmentList = null;
    // subscriptionList = null;
  }
}
