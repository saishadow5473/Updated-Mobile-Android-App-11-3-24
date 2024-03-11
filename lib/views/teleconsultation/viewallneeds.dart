// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/teleconsulation/dashboardCards.dart';
import 'package:ihl/widgets/toc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/customicons_icons.dart';
import '../../new_design/presentation/Widgets/appBar.dart';
import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../../new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import '../../new_design/presentation/pages/onlineServices/MyMedicalFiles.dart';
import 'files/MedicalFilesCategory.dart';
import 'specialityType.dart';

/// Main Teleconsultation dashboard 🚚
class ViewallTeleDashboard extends StatefulWidget {
  ViewallTeleDashboard({Key key, this.backNav, this.includeHelthEmarket, bool onlyTeleconsultation})
      : super(key: key);
  final bool backNav;
  final bool includeHelthEmarket;

  @override
  State<ViewallTeleDashboard> createState() => _ViewallTeleDashboardState();
}

class _ViewallTeleDashboardState extends State<ViewallTeleDashboard> {
  /// list of options in dashboard 🚃🚃🚃
  static Map ff = {};

  final List<Map> options = [
    // {
    //   'text': "Consult Now",
    //   'icon': FontAwesomeIcons.video,
    //   'iconSize': 40.0,
    //   'onTap': (BuildContext context) {
    //     openTocDialog(context,
    //         on_Tap: Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: true),
    //         ontap_Available: true);
    //   },
    //   'color': AppColors.startConsult,
    // },
    // {
    //   'text': 'Book Appointment',
    //   'icon': FontAwesomeIcons.calendarAlt,
    //   'iconSize': 40.0,
    //   'onTap': (BuildContext context) {
    //     openTocDialog(context,
    //         on_Tap: Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: false),
    //         ontap_Available: true);
    //   },
    //   'color': AppColors.bookApp,
    // },
    {
      'text': 'Consultation',
      'icon': Icons.medical_services_rounded,
      'iconSize': 40.0,
      'onTap': (BuildContext context) {
        // openTocDialog(context,
        //     on_Tap: Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: true),
        //     ontap_Available: true);
        openTocDialog(context,
            on_Tap: Navigator.of(context).pushNamed(
              Routes.AllSpecialtyType,
            ),
            ontap_Available: true);
      },
      'color': AppColors.bookApp,
    },
    {
      'text': 'Appointments',
      'icon': FontAwesomeIcons.calendarCheck,
      'iconSize': 40.0,
      'onTap': (BuildContext context) {
        Get.to(MyAppointment(
          backNav: true,
        ));
        // Navigator.of(context).pushNamed(Routes.MyAppointments);
      },
      'color': AppColors.myConsultant,
    },
    {
      'text': 'Consultation History',
      'icon': FontAwesomeIcons.history,
      'iconSize': 40.0,
      'onTap': (BuildContext context) {
        Navigator.of(context).pushNamed(Routes.ConsultationHistory);
      },
      'color': AppColors.history,
    },

    ///commented on 310 Dec
    {
      'text': AppTexts.teleConDashboardFiles, //"My Medical Files",
      'icon': FontAwesomeIcons.file,
      'iconSize': 40.0,
      'onTap': (BuildContext context) {
        Get.to(MyMedicalFiles(medicalFiles: false, normalFlow: true));
        // Get.to(MedicalFiles());
        // Navigator.of(context)
        //     .pushNamed(Routes.ConsultationType, arguments: true);
      },
      'color': AppColors.medicalFiles,
    },
    // {
    //   'text': 'My Subscriptions',
    //   'icon': FontAwesomeIcons.solidBell,
    //   'iconSize': 40.0,
    //   'onTap': (BuildContext context) {
    //     localSotrage.write("healthEmarketNavigation", true);
    //     Navigator.of(context).pushNamed(Routes.MySubscriptions, arguments: false);
    //   },
    //   'color': AppColors.subscription
    // },
    // {
    //   'text': 'Health E-Market',
    //   'icon': Customicons.fitness_class,
    //   'iconSize': 170.0,
    //   'onTap': (BuildContext context) {
    //     // Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: null);
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => SpecialityTypeScreen(arg: ff)),
    //     );
    //   },
    //   'color': AppColors.onlineClass,
    // },
  ];

  @override
  void initState() {
    asynFun();
    super.initState();
  }

  final TabBarController tabController = Get.put(TabBarController());

  asynFun() async {
    if (widget.includeHelthEmarket ?? false) {
      options.addAll([
        {
          'text': 'Subscription',
          'icon': FontAwesomeIcons.solidBell,
          'iconSize': 40.0,
          'onTap': (BuildContext context) {
            localSotrage.write("healthEmarketNavigation", true);
            bool sso = UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
                UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] !=
                    null &&
                Tabss.isAffi;
            if (sso) {
              Get.to(ViewFourPillar());
            } else {
              //To avoid back navigation stuck we are assigning as subNav as false⚪⚪
              localSotrage.write("subNav", false);
              Navigator.of(context).pushNamed(Routes.MySubscriptions, arguments: false);
            }
          },
          'color': AppColors.subscription
        },
        {
          'text': 'Health E-Market',
          'icon': Customicons.fitness_class,
          'iconSize': 170.0,
          'onTap': (BuildContext context) {
            if (selectedAffiliationcompanyNamefromDashboard != "") {
              Get.to(ViewFourPillar());
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SpecialityTypeScreen(arg: ff)),
              );
            }
          },
          'color': AppColors.onlineClass,
        },
      ]);
      ff = await UpcomingDetailsController.getPlatformDatas();
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(UpcomingDetailsController());
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        // ignore: missing_return
        onWillPop: () async {
          if (widget.backNav == true) {
            Get.offAll(LandingPage());
          } else if (widget.backNav == false) {
            Get.offAll(LandingPage());
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('TOCAccepted', false);
            Get.find<UpcomingDetailsController>().updateUpcomingDetails(fromChallenge: false);
            Get.offAll(LandingPage());
          }
        },
        //replaces the screen to Main dashboard
        child: BasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: ScUtil().setWidth(20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () async {
                      print('aaaa${widget.backNav}');
                      tabController.updateProgramsTab(val: 0);
                      if (widget.backNav == true) {
                        Get.offAll(LandingPage());
                      } else if (widget.backNav == false) {
                        Get.offAll(LandingPage());
                      } else {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool('TOCAccepted', false);
                        Get.find<UpcomingDetailsController>()
                            .updateUpcomingDetails(fromChallenge: false);
                        Get.offAll(LandingPage());

                        // Navigator.pushAndRemoveUntil(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => Home()),
                        //     (Route<dynamic> route) => false);
                      }
                    }, //replaces the screen to Main dashboard
                    color: Colors.white,
                  ),
                  Text(
                    (widget.includeHelthEmarket ?? false) ? 'Online Services' : 'Teleconsultation',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScUtil().setSp(24.0),
                        // fontFamily: 'Poppins'
                        fontFamily: 'Poppins'
                        // fontFamily: 'Poppins-Black'
                        ),
                  ),
                  SizedBox(
                    width: ScUtil().setWidth(40),
                  )
                ],
              ),
              SizedBox(
                height: ScUtil().setHeight(20),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height /
                        1.2, // bottom white space fot the teledashboard
                    child: ListView.builder(
                      physics: const ScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        return card(
                          context,
                          options[index]['text'],
                          options[index]['icon'],
                          options[index]['iconSize'],
                          options[index]['color'],
                          () {
                            options[index]['onTap'](context);
                          },
                        );
                      },
                    ),
                  ),
                  //ConsultationHistory(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
