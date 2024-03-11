import 'package:flutter/material.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/home_dashboard/dashboard_home.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/repositories/repositories.dart';
import 'package:ihl/tabs/profiletab.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_mobile_verify.dart';
import 'package:ihl/views/JointAccount/guest_accounts/guest_accounts_list.dart';
import 'package:ihl/views/JointAccount/joint_account_main.dart';
import 'package:ihl/views/JointAccount/link_existing_account/link_account.dart';
import 'package:ihl/views/JointAccount/linked_account_setting/linked_acc_settings.dart';
import 'package:ihl/views/cardiovascular_views/cardiovascular_survey.dart';
import 'package:ihl/views/consultationStages.dart';
import 'package:ihl/views/consultation_summary.dart';
import 'package:ihl/views/dietDashboard/profile_settings_screen.dart';
import 'package:ihl/views/dietJournal/MealTypeScreen.dart';
import 'package:ihl/views/dietJournal/add_new_meal.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';
import 'package:ihl/views/forgotpwd/forgot_password_screen.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/views/signup/proceed.dart';
import 'package:ihl/views/signup/signup_aff.dart';
import 'package:ihl/views/signup/signup_verify_mobile.dart';
import 'package:ihl/views/survey/surveyUI.dart';
import 'package:ihl/views/survey/waitingScreen.dart';
import 'package:ihl/views/teleconsultation/FollowUpScreen.dart';
import 'package:ihl/views/teleconsultation/MyConsultant.dart';
import 'package:ihl/views/teleconsultation/MySubscription.dart';
import 'package:ihl/views/teleconsultation/consultationHistory.dart';
import 'package:ihl/views/teleconsultation/consultation_history_summary.dart';
import 'package:ihl/views/teleconsultation/exports.dart';
import 'package:ihl/views/teleconsultation/mySubscriptions.dart';
import 'package:ihl/views/teleconsultation/new_speciality_type_screen.dart';
import 'package:ihl/views/teleconsultation/payment/PaymentPage.dart';
import 'package:ihl/views/teleconsultation/payment/paymentFailed.dart';
import 'package:ihl/views/teleconsultation/payment/paymentSuccess.dart';
import 'package:ihl/views/teleconsultation/videocall/CallWaitingScreen.dart';
import 'package:ihl/views/teleconsultation/videocall/videocall.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/views/teleconsultation/wellness_cart.dart';

import 'package:ihl/widgets/signin_email.dart';
import 'package:ihl/widgets/teleconsulation/bookClass.dart';
import 'package:ihl/widgets/teleconsulation/book_appointment.dart';
import 'package:ihl/widgets/teleconsulation/history_details.dart';
import 'package:ihl/widgets/teleconsulation/prescription_details.dart';
import 'package:ihl/widgets/teleconsulation/subscriptionPayment/subscription_payment_failed.dart';
import 'package:ihl/widgets/teleconsulation/subscriptionPayment/subscription_payment_page.dart';
import 'package:ihl/widgets/teleconsulation/subscriptionPayment/subscription_payment_success.dart';

import '../new_design/presentation/pages/home/landingPage.dart';
import '../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import 'JointAccount/create_new_account/create_dob.dart';
import 'JointAccount/create_new_account/create_email.dart';
import 'JointAccount/create_new_account/create_gender.dart';
import 'JointAccount/create_new_account/create_height.dart';
import 'JointAccount/create_new_account/create_mobile_number.dart';
import 'JointAccount/create_new_account/create_name.dart';
import 'JointAccount/create_new_account/create_password.dart';
import 'JointAccount/create_new_account/create_proceed.dart';
import 'JointAccount/create_new_account/create_signup_pic.dart';
import 'JointAccount/create_new_account/create_weight.dart';
import 'JointAccount/link_existing_account/enter_email.dart';

final apirepository = Apirepository();

class Router {
  Router._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.Welcome:
        return MaterialPageRoute(
          builder: (_) => WelcomePage(
            deepLink: settings.arguments,
          ),
        );
      case Routes.Onboard:
        return MaterialPageRoute(
          builder: (_) => GooeyCarousel(),
        );
      case Routes.Sname:
        return MaterialPageRoute(
          builder: (_) => SignupName(),
        );
      case Routes.Cname:
        return MaterialPageRoute(
          builder: (_) => CreateName(),
        );
      case Routes.Cemail:
        return MaterialPageRoute(
          builder: (_) => CreateEmail(apiRepository: apirepository),
        );
      case Routes.Eemail:
        return MaterialPageRoute(
          builder: (_) => EnterEmail(
            apiRepository: apirepository,
          ),
        );
      case Routes.Gaccounts:
        return MaterialPageRoute(
          builder: (_) => GuestAccountList(),
        );
      case Routes.Laccountssettings:
        return MaterialPageRoute(
          builder: (_) => LinkedAccountSettings(),
        );
      case Routes.Semail:
        return MaterialPageRoute(
          builder: (_) => SignupEmail(
            apiRepository: apirepository,
            email: "",
          ),
        );
      case Routes.Cpassword:
        return MaterialPageRoute(
          builder: (_) => CreatePwd(),
        );
      case Routes.Cdob:
        return MaterialPageRoute(
          builder: (_) => CreateDob(),
        );
      case Routes.Cgender:
        return MaterialPageRoute(
          builder: (_) => CreateGender(),
        );
      case Routes.Spwd:
        return MaterialPageRoute(
          builder: (_) => SignupPwd(),
        );
      case Routes.Cmobilenumber:
        return MaterialPageRoute(
          builder: (_) => CreateMob(apiRepository: apirepository),
        );
      case Routes.Smob:
        return MaterialPageRoute(
          builder: (_) => SignupMob(apiRepository: apirepository),
        );
      case Routes.Sdob:
        return MaterialPageRoute(
          builder: (_) => SignupDob(),
        );
      case Routes.Spic:
        return MaterialPageRoute(
          builder: (_) => SignupPic(),
        );
      case Routes.Cpic:
        return MaterialPageRoute(
          builder: (_) => CreateSignupPic(),
        );
      case Routes.CProceed:
        return MaterialPageRoute(
          builder: (_) => CreateSignupProcced(),
        );
      case Routes.SProceed:
        return MaterialPageRoute(
          builder: (_) => SignupProcced(),
        );
      case Routes.LinkAccountDash:
        return MaterialPageRoute(
          builder: (_) => LinkExistAccount(),
        );
      case Routes.Profile:
        return MaterialPageRoute(
          builder: (_) => ProfileTab(),
        );
      case Routes.ProfileScreenSettings:
        return MaterialPageRoute(
          builder: (_) => ProfileSettingScreen(),
        );
      case Routes.Survey:
        return MaterialPageRoute(
          builder: (_) => SurveyUi(
            signup: settings.arguments,
          ),
        );
      case Routes.SurveyProceed:
        return MaterialPageRoute(
          builder: (_) => SurveyWaiting(),
        );
      case Routes.Cheight:
        return MaterialPageRoute(
          builder: (_) => CreateHeight(
            gender: 'male',
          ),
        );
      case Routes.Sheight:
        return MaterialPageRoute(
          builder: (_) => SignupHt(
            gender: 'male',
          ),
        );
      case Routes.Cweight:
        return MaterialPageRoute(
          builder: (_) => CreateWeight(),
        );
      case Routes.Sweight:
        return MaterialPageRoute(
          builder: (_) => SignupWt(),
        );
      case Routes.Aff:
        return MaterialPageRoute(
          builder: (_) => SignupAff(),
        );
      // case Routes.CAff:
      //   return MaterialPageRoute(
      //     builder: (_) => CreateSignupAff(),
      //   );
      case Routes.AllSpecialtyType:
        return MaterialPageRoute(
            builder: (_) => NewSpecialtiyTypeScreen(
                  companyName: null,
                ));
      case Routes.JointAccount:
        return MaterialPageRoute(
          builder: (_) => JointAccount(),
        );
      case Routes.Sgender:
        return MaterialPageRoute(
          builder: (_) => SignupGen(),
        );
      case Routes.Home:
        return MaterialPageRoute(
          builder: (_) => LandingPage(),
          // HomeScreen(
          //   introDone: settings.arguments,
          // ),
        );
      case Routes.HomeDashBoard:
        return MaterialPageRoute(
          builder: (_) => HomeDashBoard(
            introDone: settings.arguments,
          ),
        );
      case Routes.Login:
        return MaterialPageRoute(
          builder: (_) => LoginEmailScreen(
            deepLink: settings.arguments,
          ),
        );
      case Routes.ForgotPwd:
        return MaterialPageRoute(
          builder: (_) => ForgotPassword(),
        );
      case Routes.Vitals:
        return MaterialPageRoute(
          builder: (_) => VitalScreen(),
        );
      case Routes.VerifyMobile:
        return MaterialPageRoute(
          builder: (_) => SignupVerifyMob(
            mobileNumber: settings.arguments,
          ),
        );
      case Routes.CVerifyMobile:
        return MaterialPageRoute(
          builder: (_) => CreateVerifyMobile(
            mobileNumber: settings.arguments,
          ),
        );
      case Routes.TeleConDashboard:
        return MaterialPageRoute(
          builder: (_) => TeleDashboard(),
        );
      case Routes.TeleDashboard:
        return MaterialPageRoute(
          builder: (_) => ViewallTeleDashboard(),
        );
      case Routes.CallWaitingScreen:
        return MaterialPageRoute(
          builder: (_) => CallWaitingScreen(
            appointmentDetails: settings.arguments,
          ),
        );
      case Routes.ConsultVideo:
        return MaterialPageRoute(
          builder: (_) => VideoCall(
            callDetails: settings.arguments,
          ),
        );
      case Routes.ConsultationHistory:
        return MaterialPageRoute(
          builder: (_) => ConsultHistory(),
        );
      case Routes.MyAppointments:
        return MaterialPageRoute(
          builder: (_) => MyAppointment(backNav: false),
        );
      case Routes.MyMedicalFiles:
        return MaterialPageRoute(
          builder: (_) => MedicalFiles(category: settings.arguments, medicalFiles: false),
        );
      case Routes.BookAppointment:
        return MaterialPageRoute(
          builder: (_) => BookAppointment(
            doctor: settings.arguments,
            specality: settings.arguments,
          ),
        );
      case Routes.BookClass:
        return MaterialPageRoute(
          builder: (_) => BookClass(
            course: settings.arguments,
          ),
        );
      case Routes.ConsultationType:
        return MaterialPageRoute(
          builder: (_) => ConsultationType(
            liveCall: settings.arguments,
          ),
        );
      case Routes.SpecialityType:
        return MaterialPageRoute(
          builder: (_) => SpecialityTypeScreen(
            arg: settings.arguments,
          ),
        );
      case Routes.SelectConsultant:
        return MaterialPageRoute(
          builder: (_) => SelectConsutantScreen(
            arg: settings.arguments,
          ),
        );
      case Routes.MyConsultant:
        return MaterialPageRoute(
          builder: (_) => MyConsutantScreen(),
        );
      case Routes.SelectClass:
        return MaterialPageRoute(
          builder: (_) => SelectClassesScreen(
            arg: settings.arguments,
          ),
        );
      case Routes.Followup:
        return MaterialPageRoute(
          builder: (_) => FollowUpScreen(),
        );
      case Routes.ConfirmVisit:
        return MaterialPageRoute(
          builder: (_) => ConfirmVisit(visitDetails: settings.arguments),
        );
      case Routes.SubscriptionPaymentPage:
        return MaterialPageRoute(
            builder: (_) => SubscriptionPaymentPage(
                  details: settings.arguments,
                ));
      case Routes.SubscriptionPaymentSuccess:
        return MaterialPageRoute(
            builder: (_) => SubscriptionSuccessPage(details: settings.arguments));
      case Routes.SubscriptionPaymentFailed:
        return MaterialPageRoute(
            builder: (_) => SubscriptionPaymentFailedPage(
                  response: settings.arguments,
                ));
      case Routes.Telepayment:
        return MaterialPageRoute(
            builder: (_) => PaymentPage(
                  details: settings.arguments,
                ));
      case Routes.PaymentSuccess:
        return MaterialPageRoute(builder: (_) => SuccessPage(details: settings.arguments));
      case Routes.PaymentFailure:
        return MaterialPageRoute(
          builder: (_) => FailedPage(
            response: settings.arguments,
          ),
        );
      case Routes.ConsultSummary:
        return MaterialPageRoute(
            builder: (_) => ConsultSummaryPage(consultationNotes: settings.arguments));
      case Routes.historyDetails:
        return MaterialPageRoute(
          builder: (_) => HistoryDetails(),
        );
      case Routes.MySubscriptions:
        return MaterialPageRoute(
            builder: (_) => MySubscription(
                  afterCall: settings.arguments,
                ));
      // case Routes.MySubscriptions:
      //   return MaterialPageRoute(
      //       builder: (_) => MySubscriptions(
      //             afterCall: settings.arguments,
      //           ));
      case Routes.WellnessCart:
        return MaterialPageRoute(builder: (_) => WellnessCart());
      case Routes.PrescriptionDetails:
        return MaterialPageRoute(builder: (_) => PrescriptionDetails());
      case Routes.ConsultStages:
        return MaterialPageRoute(
            builder: (_) => ConsultStagesPage(
                  appointmentId: settings.arguments,
                ));
      case Routes.ConsultationHistorySummary:
        return MaterialPageRoute(
          builder: (_) => ConsultationHistorySummary(),
        );
      case Routes.HealthJournal:
        return MaterialPageRoute(
          builder: (_) => DietJournal(),
        );
      case Routes.AddFood:
        return MaterialPageRoute(
          builder: (_) => AddFood(
            mealsListData: settings.arguments,
            selectedpage: settings.arguments,
            cardioNavigate: false,
          ),
        );
      case Routes.MealTypeScreen:
        return MaterialPageRoute(
          builder: (_) => MealTypeScreen(
            mealsListData: settings.arguments,
          ),
        );
      case Routes.CardiovascularSurvey:
        return MaterialPageRoute(
          builder: (_) => CardiovascularSurvey(
              // mealsListData: settings.arguments,
              ),
        );
      case "ECG_graph_screen":
        return MaterialPageRoute(
            builder: (_) => ECGGraphScreen(
                  ecgValue: settings.arguments,
                ));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
