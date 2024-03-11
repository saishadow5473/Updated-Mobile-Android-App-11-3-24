import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../utils/screenutil.dart';
import '../../../../views/teleconsultation/files/medicalFiles.dart';
import 'medFileblocs/medFileBloc.dart';
import 'myAppointmentsTabs.dart';

class MyMedicalFiles extends StatefulWidget {
  bool medicalFiles, normalFlow;
  String ihlConsultantId;
  String appointmentId;

  MyMedicalFiles(
      {Key key, this.medicalFiles, this.ihlConsultantId, this.appointmentId, this.normalFlow})
      : super(key: key);

  @override
  State<MyMedicalFiles> createState() => _MyMedicalFilesState();
}

class _MyMedicalFilesState extends State<MyMedicalFiles> {
  final List<Map> options = [
    {
      'text': "Lab Report",
      'icon': "newAssets/medicalFiles/Lab Report.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    {
      'text': 'X Ray',
      'icon': "newAssets/medicalFiles/X Ray.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    {
      'text': 'CT Scan',
      'icon': "newAssets/medicalFiles/CT Scan.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    {
      'text': 'MRI Scan',
      'icon': "newAssets/medicalFiles/MRI Scan.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
    {
      'text': "Others",
      'icon': "newAssets/medicalFiles/Others.jpg",
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': Colors.white
    },
  ];

  @override
  Widget build(BuildContext context) {
    return widget.medicalFiles == true
        ? SizedBox(
            height: 50.h,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      MedicalFiles(
                          category: options[index]['text'],
                          medicalFiles: widget.medicalFiles,
                          normalFlow: widget.normalFlow,
                          consultStages: false);
                      // runApp(Scaffold(body: MyAppointmentsTabs()));
                      // Get.to(Scaffold(body: Container(child: Text('text'))));
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => SizedBox(
                      //         height: 44.h,
                      //         width: double.maxFinite,
                      //         child: MedicalFiles(options[index]['text'], widget.medicalFiles)))
                      // );
                    },
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          options[index]['text'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : CommonScreenForNavigation(
            contentColor: '',
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.primaryColor,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  Get.back();
                }, //replaces the screen to Main dashboard
                color: Colors.white,
              ),
              title: Text("My Medical Files"),
            ),
            content: GridView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 2 / 1.8
                  // crossAxisSpacing: 4.0,
                  // mainAxisSpacing: 4.0
                  ),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(BlocProvider(
                      create: (BuildContext context) => MedFileBloc(),
                      child: MedicalFiles(
                          category: options[index]['text'],
                          medicalFiles: widget.medicalFiles,
                          ihlConsultantId: widget.ihlConsultantId,
                          appointmentId: widget.appointmentId,
                          normalFlow: widget.normalFlow,
                          consultStages: false),
                    ));
                  },
                  child: medFileCard(
                    index,
                    context,
                    options[index]['text'],
                    options[index]['icon'],
                    options[index]['iconSize'],
                    options[index]['color'],
                    () {
                      Get.to(MedicalFiles(
                        category: options[index]['text'],
                        medicalFiles: widget.medicalFiles,
                        ihlConsultantId: widget.ihlConsultantId,
                        appointmentId: widget.appointmentId,
                        normalFlow: widget.normalFlow,
                        consultStages: false,
                      ));
                      // options[index]['onTap'](context);
                    },

                    // Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       SizedBox(height: 2.h),
                    //       Center(
                    //         child: Padding(
                    //             padding: EdgeInsets.all(5.0),
                    //             child: Container(
                    //                 height: 8.h,
                    //                 width: 60.w,
                    //                 child: Image.asset("newAssets/medicalFiles/CT Scan.jpg"))),
                    //       ),
                    //       SizedBox(
                    //         width: MediaQuery.of(context).size.width * 0.03,
                    //       ),
                    //       Expanded(
                    //           child: Text(
                    //         'TEXT',
                    //         maxLines: 1,
                    //         style: TextStyle(fontSize: 12),
                    //       ))
                    //     ]),
                  ),
                );
              },
            ),
          );
  }

  Widget medFileCard(int index, BuildContext context, var _title, var _icon, var _iconSize,
      var _bgColor, final Function onTap) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2.h),
          Center(
            child: Padding(
                padding: EdgeInsets.all(10.sp),
                child: Container(
                    height: 10.h,
                    width: 60.w,
                    child: Image.asset(
                      "${options[index]['icon']}",
                    ))),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              _title,
              maxLines: 1,
              style: TextStyle(fontSize: 12),
            ),
          ))
        ]);
  }
}
