///📚contains keys for shared preferences
class SPKeys {
  static String userData = 'data';
  static String guestuserData = 'guestdata';
  static String vitalsData = 'userVitalData';
  static String firstVisit = 'FirstVisit';
  static String email = 'email';
  static String password = 'password';
  static String authToken = 'auth_token';
  static String stepCounter = 'StepCounterInstance';
  static String stepCounterEvent = 'StepCounterInstance';
  static String weight = 'userLatestWeight';
  static String height = 'userLatestHeight';
  static String platformData = 'platformData';
  static String userDetailsResponse = 'userDetailsResponse';
  static String invoiceNo = 'invoiceNumber';
  static String jointAccUserID = 'id';
  static String is_sso = 'is_sso';
  static String sso_token = 'sso_token';
  static String signInType = 'sign_in_type';
  static String isToday = 'isToday';
  static String breakfastIndex = 'breakfastIndex';
  static String lunchIndex = 'lunchIndex';
  static String snacksIndex = 'snacksIndex';
  static String dinnerIndex = 'dinnerIndex';

  ///JointAccount sp constant with credentials (email, pass, mobile number)
  static String jwcFname = 'jwcFname';
  static String jwcLname = 'jwcLname';
  static String jwcEmail = 'jwcEmail';
  static String jwcMobile = 'jwcMobile';
  static String jwcHeight = 'jwcHeight';
  static String jwcWeight = 'jwcWeight';
  static String jwcDob = 'jwcDob';
  static String jwcPass = 'jwcPass';
  static String jwcGender = 'jwcGender';
  static String jwcEmailGiven = 'jwcEmailGiven';
  static String jwcMobileGiven = 'jwcMobileGiven';
  static String jwcDobGiven = 'jwcDobGiven';

  ///JointAccount sp constant withOut credentials (email, pass, mobile number)
  static String jwocFname = 'jwocFname';
  static String jwocLname = 'jwocLname';
  static String jwocEmail = 'jwocEmail';
  static String jwocMobile = 'jwocMobile';
  static String jwocHeight = 'jwocHeight';
  static String jwocWeight = 'jwocWeight';
  static String jwocDob = 'jwocDob';
  static String jwocPass = 'jwocPass';
  static String jwocGender = 'jwocGender';
  static String jwocEmailGiven = 'jwocEmailGiven';
  static String jwocMobileGiven = 'jwocMobileGiven';
  static String jwocDobGiven = 'jwocDobGiven';

  ///JointAccount sp constant
  static String jFname = 'jFname';
  static String jLname = 'jLname';
  static String jEmail = 'jEmail';
  static String jMobile = 'jMobile';
  static String jHeight = 'jHeight';
  static String jWeight = 'jWeight';
  static String jDob = 'jDob';
  static String jPass = 'jPass';
  static String jGender = 'jGender';
  static String jEmailGiven = 'jEmailGiven';
  static String jMobileGiven = 'jMobileGiven';
  static String jDobGiven = 'jDobGiven';

  static String jUserData = 'data';
  static String jVitalsData = 'userVitalData';
  static String jVitalRead = 'jVitalRead';
  static String jVitalWrite = 'jVitalWrite';
  static String jTeleconsultRead = 'jTeleconsultRead';
  static String jTeleconsultWrite = 'jTeleconsultWrite';

  // static String password = 'password';
  // static String authToken = 'auth_token';
  static String jStepCounter = 'StepCounterInstance';
  static String jUserLatestweight = 'userLatestWeight';
  static String jUserLatestheight = 'userLatestHeight';
  static String jPlatformData = 'platformData';
  static String jUserDetailsResponse = 'userDetailsResponse';
  static String jInvoiceNo = 'invoiceNumber';

  ///FOR SAVING THE APPOINTMENT OR LIVE CALL TYPE THAT IT IS AFFILIATED BY GLOBAL OR OTHER SERRVICE
  static String affiliateUniqueName = 'affiliateUniqueName';

  // For marathon register user

  static String mPlaceSelected = 'mPlaceSelected';
  static String mMarathonTypeSelected = 'mMarathonTypeSelected';
  static String mAppTypeSelected = 'mAppTypeSelected';
  static String mOrgTypeSelected = 'mOrgTypeSelected';
  static String mDeptTypeSelected = 'mDeptTypeSelected';
  static String mEmpIDGiven = 'mEmpIDGiven';
  static String mEventSourceSelected = 'mEventSourceSelected';

  //For Checking the app version for new update
  static String needToCheckAppVersion = 'needToCheckAppVersion';
}

class GSKeys {
  static String challengeDetail = 'challengeDetail',
      userDetail = 'userDetail',
      currentDayValue = 'currentDayValue',
      isSSO = 'isSSO';
}
