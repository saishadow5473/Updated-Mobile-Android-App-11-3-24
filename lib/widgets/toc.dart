import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/tabs/profiletab.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/consultationType.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_design/app/utils/appText.dart';
import '../new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../views/screens.dart';
import '../views/teleconsultation/new_speciality_type_screen.dart';

class Toc extends StatefulWidget {
  bool specnewScreen, fourPillars;

  Toc({Key key, this.specnewScreen, this.fourPillars}) : super(key: key);

  @override
  _TocState createState() => _TocState();
}

class _TocState extends State<Toc> {
  // Controller for the ListView
  ScrollController _controller = ScrollController();

  bool atMaxScroll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '  Tele Consultation T & C  ',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _controller,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                AppTexts.tocText,
                textAlign: TextAlign.justify,
              ),
              SizedBox(
                height: 1.h,
              ),
              // !widget.specnewScreen
              //     ? Container()
              //     : !widget.fourPillars
              //         ? FloatingActionButton.extended(
              //             onPressed: () {
              //               Navigator.of(context).pop('User Agreed');
              //             },
              //             label: const Text('ACCEPT'))
              //         : FloatingActionButton.extended(
              //             onPressed: () {
              //               Navigator.of(context).pop('User Agreed');
              //             },
              //             label: const Text('ACCEPT'))
            ],
          ),
        ),
      ),
      floatingActionButton: !widget.fourPillars
          ? FloatingActionButton.extended(
              onPressed: () {
                atMaxScroll ? Navigator.of(context).pop('User Agreed') : null;
              },
              label: const Text('I Agree'),
              icon: const Icon(Icons.check))
          : FloatingActionButton.extended(
              onPressed: () {
                if (!atMaxScroll) {
                  Get.showSnackbar(
                    const GetSnackBar(
                      title: "Warning!!!",
                      message: "Please read the document till the end",
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
                atMaxScroll ? Navigator.of(context).pop('User Agreed') : null;
              },
              label: const Text('ACCEPT'),
              icon: const Icon(Icons.check)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Add a listener to the scroll controller in didChangeDependencies
    _controller.addListener(() {
      // Check if the current scroll offset is close to the maximum scroll extent
      atMaxScroll = _controller.offset >= _controller.position.maxScrollExtent - 200;

      // Call the callback function with the atMaxScroll value
      onMaxScroll(atMaxScroll);
    });
  }

  // Callback function to be called on max scroll changes
  void onMaxScroll(bool atMaxScroll) {
    // You can perform actions based on the atMaxScroll value
    print('At Max Scroll: $atMaxScroll');
  }
}

Future openTocDialog(context, {on_Tap, bool ontap_Available, bool specnewScreen}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.get('data');
  var tocAccepted = prefs.getBool('TOCAccepted');
  Map res = jsonDecode(data);
  // var userTOCAccepted = res['User']['isTeleMedPolicyAgreed'];
  // var isLastTOCcheckinAvailable =
  //     res['User']['teleconsult_last_checkin_service'];
  // var isLastInvoiceAvailable;
  // if (isLastTOCcheckinAvailable != null) {
  //   isLastInvoiceAvailable =
  //       res['User']['teleconsult_last_checkin_service']['invoice_id'];
  // }
  var address = res['User']['address'].toString();
  var area = res['User']['area'].toString();
  var city = res['User']['city'].toString();
  var state = res['User']['state'].toString();
  var pincode = res['User']['pincode'].toString();

  if ((tocAccepted == null || tocAccepted == false) //&&
      // (userTOCAccepted == null || userTOCAccepted == false) &&
      // (isLastInvoiceAvailable == null)
      ) {
    String result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return Toc(
            specnewScreen: specnewScreen ?? false,
            fourPillars: true,
          );
        },
        fullscreenDialog: true));
    print(result);
    if (result == 'User Agreed') {
      ///we are not setting it to true
      ///prefs.setBool('TOCAccepted', true);
      ///instead we are setting it to false
      prefs.setBool('TOCAccepted', false);

      ///and we are not calling the api also to update the telemed terms
      // updateTeleMedTOC();
      if (area == null ||
          area == "" ||
          area == "null" ||
          address == null ||
          address == "" ||
          address == "null" ||
          city == null ||
          city == "" ||
          city == "null" ||
          state == null ||
          state == "" ||
          state == "null" ||
          pincode == null ||
          pincode == "" ||
          pincode == "null") {
        //1
        Get.to(NewSpecialtiyTypeScreen());
        // Get.to(ProfileTab(
        //     editing: true,
        //     bacNav: () {
        //       Get.to(ViewallTeleDashboard(
        //         includeHelthEmarket: true,
        //       ));
        //     });
        return true;
      } else {
        if (ontap_Available.toString() != 'null' && ontap_Available.toString() != 'false') {
          on_Tap;
        } else {
          Get.to(ViewallTeleDashboard(
            backNav: false,
          ));
        }
      }
    } else {
      Get.dialog(
        AlertDialog(
          title: Column(
            children: [
              const Text(
                'Info !',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please agree to the Terms & Conditions to access and use the TeleConsultation features',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  child: const Text(
                    'Proceed Now',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Get.close(1);
                    openTocDialog(context, ontap_Available: ontap_Available, on_Tap: on_Tap);
                  },
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  // Get.to(ViewallTeleDashboard(
                  //   backNav: false,
                  // ));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 16, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      debugPrint('Not Accepted');
    }
  } else {
    if (area == null ||
        area == "" ||
        area == "null" ||
        address == null ||
        address == "" ||
        address == "null" ||
        city == null ||
        city == "" ||
        city == "null" ||
        state == null ||
        state == "" ||
        state == "null" ||
        pincode == null ||
        pincode == "" ||
        pincode == "null") {
      Get.offAll(ProfileTab(
        editing: true,
      ));
    } else {
      Get.to(ViewallTeleDashboard(
        backNav: false,
      ));
    }
  }
}

Future openTocDialogForFourPillars(context,
    {on_Tap, bool ontap_Available, bool specnewScreen}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.get('data');
  var tocAccepted = prefs.getBool('TOCAccepted');
  Map res = jsonDecode(data);
  // var userTOCAccepted = res['User']['isTeleMedPolicyAgreed'];
  // var isLastTOCcheckinAvailable =
  //     res['User']['teleconsult_last_checkin_service'];
  // var isLastInvoiceAvailable;
  // if (isLastTOCcheckinAvailable != null) {
  //   isLastInvoiceAvailable =
  //       res['User']['teleconsult_last_checkin_service']['invoice_id'];
  // }
  var address = res['User']['address'].toString();
  var area = res['User']['area'].toString();
  var city = res['User']['city'].toString();
  var state = res['User']['state'].toString();
  var pincode = res['User']['pincode'].toString();

  if ((tocAccepted == null || tocAccepted == false) //&&
      // (userTOCAccepted == null || userTOCAccepted == false) &&
      // (isLastInvoiceAvailable == null)
      ) {
    String result = await Get.to(
        Toc(
          specnewScreen: specnewScreen ?? false,
          fourPillars: true,
        ),
        fullscreenDialog: true);
    print(result);
    if (result == 'User Agreed') {
      ///we are not setting it to true
      ///prefs.setBool('TOCAccepted', true);
      ///instead we are setting it to false
      prefs.setBool('TOCAccepted', false);

      ///and we are not calling the api also to update the telemed terms
      // updateTeleMedTOC();
      if (area == null ||
          area == "" ||
          area == "null" ||
          address == null ||
          address == "" ||
          address == "null" ||
          city == null ||
          city == "" ||
          city == "null" ||
          state == null ||
          state == "" ||
          state == "null" ||
          pincode == null ||
          pincode == "" ||
          pincode == "null") {
        Get.to(ProfileTab(
            editing: true,
            bacNav: () {
              Get.to(const AffiliationDashboard());
            }));
        return true;
      } else {
        if (ontap_Available.toString() != 'null' && ontap_Available.toString() != 'false') {
          on_Tap;
        } else {
          Get.to(const AffiliationDashboard());
        }
      }
    } else {
      Get.dialog(
        AlertDialog(
          title: Column(
            children: [
              const Text(
                'Info !',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please agree to the Terms & Conditions to access and use the TeleConsultation features',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  child: const Text(
                    'Proceed Now',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  // Get.to(ViewallTeleDashboard(
                  //   backNav: false,
                  // ));
                  Get.back();
                  Get.back();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 16, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      debugPrint('Not Accepted');
    }
  } else {
    if (area == null ||
        area == "" ||
        area == "null" ||
        address == null ||
        address == "" ||
        address == "null" ||
        city == null ||
        city == "" ||
        city == "null" ||
        state == null ||
        state == "" ||
        state == "null" ||
        pincode == null ||
        pincode == "" ||
        pincode == "null") {
      Get.offAll(ProfileTab(
        editing: true,
      ));
    } else {
      Get.to(AffiliationDashboard());
    }
  }
}

Future openTocDialogForAffiliation(context, bool liveCall, String companyName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var data = prefs.get('data');
  Map res = jsonDecode(data);
  // var userTOCAccepted = res['User']['isTeleMedPolicyAgreed'];
  var address = res['User']['address'].toString();
  var area = res['User']['area'].toString();
  var city = res['User']['city'].toString();
  var state = res['User']['state'].toString();
  var pincode = res['User']['pincode'].toString();
  var tocAccepted = prefs.getBool('TOCAccepted');
  // var isLastTOCcheckinAvailable =
  //     res['User']['teleconsult_last_checkin_service'];
  // var isLastInvoiceAvailable;
  // if (isLastTOCcheckinAvailable != null) {
  //   isLastInvoiceAvailable =
  //       res['User']['teleconsult_last_checkin_service']['invoice_id'];
  // }

  if ((tocAccepted == null || tocAccepted == false) //&&
      // (userTOCAccepted == null || userTOCAccepted == false) &&
      // (isLastInvoiceAvailable == null)
      ) {
    String result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return Toc();
        },
        fullscreenDialog: true));
    if (result == 'User Agreed') {
      ///now we are not calling the api since now we are asking for permission everytime
      // updateTeleMedTOC();
      if (area == null ||
          area == "" ||
          area == "null" ||
          address == null ||
          address == "" ||
          address == "null" ||
          city == null ||
          city == "" ||
          city == "null" ||
          state == null ||
          state == "" ||
          state == "null" ||
          pincode == null ||
          pincode == "" ||
          pincode == "null") {
        Get.to(ProfileTab(
          editing: true,
        ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConsultationType(liveCall: liveCall, companyName: companyName)));
      }
    } else {
      Get.dialog(
        AlertDialog(
          title: Column(
            children: [
              const Text(
                'Info !',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please agree to the Terms & Conditions to access and use the TeleConsultation features',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: AppColors.primaryColor),
                  child: const Text(
                    'Proceed Now',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Get.close(1);
                    openTocDialogForAffiliation(context, liveCall, companyName);
                  },
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 16, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      debugPrint('Not Accepted');
    }
  } else {
    if (area == null ||
        area == "" ||
        area == "null" ||
        address == null ||
        address == "" ||
        address == "null" ||
        city == null ||
        city == "" ||
        city == "null" ||
        state == null ||
        state == "" ||
        state == "null" ||
        pincode == null ||
        pincode == "" ||
        pincode == "null") {
      Get.offAll(ProfileTab(
        editing: true,
      ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ConsultationType(liveCall: liveCall, companyName: companyName)));
    }
  }
}
