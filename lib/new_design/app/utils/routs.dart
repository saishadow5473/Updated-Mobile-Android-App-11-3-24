import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/askIHL/askIHL.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'package:ihl/new_design/presentation/pages/healthChalleneg/healthChallenge.dart';
import 'package:ihl/new_design/presentation/pages/healthProgram/healthProgram.dart';
import 'package:ihl/new_design/presentation/pages/healthTips/healthTips.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/new_design/presentation/pages/myVitals/myVitalsDashBoard.dart';
import 'package:ihl/new_design/presentation/pages/newsLetter/newsLetter.dart';
import 'package:ihl/new_design/presentation/pages/profile/profile_screen.dart';
import 'package:ihl/new_design/presentation/pages/social/social.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/new_design/presentation/pages/teleconsultation/teleconsultation.dart';
import 'package:ihl/views/teleconsultation/genixWebView.dart';
import 'package:ihl/views/teleconsultation/videocall/CallWaitingScreen.dart';

import '../../presentation/pages/hpodLocations/hpodLocations.dart';

class Routes {
  static const String home = '/home';
  static const String challenge = '/challeneg';
  static const String healthTips = '/healthTips';
  static const String newsLetter = '/newsLetter';
  static const String teleConsultation = '/teleConsultation';
  static const String myVitals = '/myVitals';
  static const String healthProgram = '/healthPrograms';
  static const String social = '/social';
  static const String newaffiliations = '/newaffiliations';
  static const String profile = '/profile';
  static const String tipsDetailedScreen = '/tipsdetailedscreen';
  static const String splashScreen = '/splashScreen';
  static const String hpodLocations = '/hpodLocations';
  static const String askIHL = '/askIHL';
  static const String CallWaitingScreen = '/Videocall Waiting screen';
  static const String GenixCallJoin = '/Genix call join';
}

final getPages = [
  GetPage(
    name: Routes.home,
    page: () => LandingPage(),
  ),
  GetPage(name: Routes.CallWaitingScreen, page: () => CallWaitingScreen(), arguments: []),
  GetPage(name: Routes.GenixCallJoin, page: () => GenixWebView(), arguments: []),
  GetPage(
    name: Routes.challenge,
    page: () => const HealthChallenge(),
  ),
  GetPage(
    name: Routes.healthTips,
    page: () => HealthTips(),
  ),
  GetPage(
    name: Routes.newsLetter,
    page: () => NewsLetter(),
  ),
  GetPage(
    name: Routes.teleConsultation,
    page: () => Teleconsultation(),
  ),
  GetPage(
    name: Routes.myVitals,
    page: () => const MyvitalsDetails(),
  ),
  GetPage(
    name: Routes.healthProgram,
    page: () => const HealthProgram(),
  ),
  GetPage(
    name: Routes.social,
    page: () => const Social(),
  ),
  GetPage(
    name: Routes.newaffiliations,
    page: () => AffiliationDashboard(),
  ),
  GetPage(
    name: Routes.profile,
    page: () => Profile(),
  ),
  // GetPage(
  //   name: Routes.tipsDetailedScreen,
  //   page: () => TipsDetailedScreen(),
  // ),
  GetPage(name: Routes.hpodLocations, page: () => HpodLocations()),
  GetPage(name: Routes.splashScreen, page: () => SplashScreen()),
  GetPage(name: Routes.askIHL, page: () => AskIHL()),
];
