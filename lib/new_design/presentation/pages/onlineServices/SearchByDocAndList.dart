// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:googleapis/apigeeregistry/v1.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../Widgets/teleconsultation_widgets/teleconsultation_widget_onlineServies.dart';

import '../../../../utils/app_colors.dart';
import '../../../data/model/TeleconsultationModels/TeleconulstationDashboardModels.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../dashboard/common_screen_for_navigation.dart';

// ignore: must_be_immutable
class SearchByDocAndList extends StatefulWidget {
  SearchByDocAndList({Key key, this.specName}) : super(key: key);
  String specName;

  @override
  State<SearchByDocAndList> createState() => _SearchByDocAndListState();
}

class _SearchByDocAndListState extends State<SearchByDocAndList> {
  List<DoctorModel> doctorList = List<DoctorModel>.generate(4, (int index) => DoctorModel());
  static ValueNotifier<List<DoctorModel>> searchDoctorList =
      ValueNotifier<List<DoctorModel>>(<DoctorModel>[]);
  static ValueNotifier<bool> showShimmer = ValueNotifier<bool>(false);
  ValueNotifier<String> selectedSpecName = ValueNotifier<String>("");

  @override
  void initState() {
    asyncFunction();
    super.initState();
  }

  asyncFunction() async {
    showShimmer.value = true;
    searchDoctorList.value = <DoctorModel>[];
    TeleConsultationFunctionsAndVariables.searchDocController.clear();
    allSpecList = await TeleConsultationFunctionsAndVariables.allSpecGetter();
    if (widget.specName == null) {
      selectedSpecName.value = allSpecList.first.specialityName;
    } else {
      selectedSpecName.value = widget.specName;
      allSpecList.removeWhere(
          (SpecialityList element) => selectedSpecName.value == element.specialityName);
      allSpecList.insert(0, SpecialityList(specialityName: selectedSpecName.value));
    }

    await gettingFunction();
  }

  bool searchLoader = false;

  gettingFunction() async {
    doctorList = List<DoctorModel>.generate(4, (int index) => DoctorModel());
    showShimmer.value = true;
    doctorList = await TeleConsultationFunctionsAndVariables.gettingDocList(
        specName: selectedSpecName.value);
    // doctorList.removeWhere((element) => element.exclusiveOnly == true);
    searchDoctorList.notifyListeners();
    showShimmer.value = false;
  }

  List<dynamic> sampleList = List<dynamic>.generate(4, (int index) => String);
  List<SpecialityList> allSpecList = <SpecialityList>[];

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: const Text("Doctor List"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      content: SizedBox(
        height: 100.h,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.w, 4.w, 4.w),
              child: PhysicalModel(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                elevation: 2.0,
                child: TextField(
                  controller: TeleConsultationFunctionsAndVariables.searchDocController,
                  onChanged: (String value) async {
                    searchLoader = true;
                    searchDoctorList.value = <DoctorModel>[];
                    debounce(() async {
                      List<DoctorModel> ss = await TeleConsultationFunctionsAndVariables.searchDoc(
                          query: value, searchTypes: <dynamic>["consultant_name"]);
                      searchLoader = false;
                      ss.removeWhere((DoctorModel element) => element.exclusiveOnly == true);
                      searchDoctorList.value = ss;
                    });
                  },
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      hintText: 'Search by Doctors',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ),
            ),
            Expanded(
                child: ValueListenableBuilder<List<DoctorModel>>(
              valueListenable: searchDoctorList,
              builder: (BuildContext context, List<DoctorModel> value, Widget child) => Column(
                children: <Widget>[
                  if (TeleConsultationFunctionsAndVariables.searchDocController.text.isNotEmpty)
                    if (searchDoctorList.value.isNotEmpty)
                      Container(
                        width: searchDoctorList.value.length < 2 ? 95.w : null,
                        height: 70.h,
                        // padding: EdgeInsets.only(bottom: 2.h),
                        child: GridView.builder(
                          itemCount: searchDoctorList.value.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            return TeleConsultationWidgetsOnlineSevices.docTiles(
                                doc: searchDoctorList.value[index]);
                          },
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: 62.w,
                              crossAxisCount: 2,
                              mainAxisSpacing: 2.w,
                              crossAxisSpacing: 2.w),
                        ),
                        // Wrap(
                        //     alignment: WrapAlignment.start,
                        //     runSpacing: 1.w,
                        //     spacing: 2.w,
                        //     children: searchDoctorList.value.map((DoctorModel doc) {
                        //       return TeleConsultationWidgetsOnlineSevices.docTiles(doc: doc);
                        //     }).toList()),
                      )
                    else if (searchLoader)
                      Container(
                        width: sampleList.length < 2 ? 95.w : null,
                        height: 70.h,
                        padding: EdgeInsets.only(bottom: 4.h),
                        child:
                            // GridView.builder(
                            //   shrinkWrap: true,
                            //   itemCount: sampleList.length,
                            //   itemBuilder: (BuildContext ctx, int index) {
                            //     return Padding(
                            //       padding: EdgeInsets.all(1.w),
                            //       child: Shimmer.fromColors(
                            //         direction: ShimmerDirection.ltr,
                            //         period: const Duration(seconds: 2),
                            //         baseColor: Colors.white,
                            //         highlightColor: Colors.grey.withOpacity(0.2),
                            //         child: Container(
                            //           width: 45.w,
                            //           height: 62.w,
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //             borderRadius: BorderRadius.circular(20),
                            //           ),
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            //       mainAxisExtent: 62.w,
                            //       crossAxisCount: 2,
                            //       mainAxisSpacing: 2.w,
                            //       crossAxisSpacing: 2.w),
                            // ),
                            Wrap(
                                alignment: WrapAlignment.start,
                                runSpacing: 1.w,
                                spacing: 2.w,
                                children: sampleList.map((dynamic doc) {
                                  return Padding(
                                    padding: EdgeInsets.all(1.w),
                                    child: Shimmer.fromColors(
                                      direction: ShimmerDirection.ltr,
                                      period: const Duration(seconds: 2),
                                      baseColor: Colors.white,
                                      highlightColor: Colors.grey.withOpacity(0.2),
                                      child: Container(
                                        width: 45.w,
                                        height: 60.w,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList()),
                      )
                    else
                      const Center(
                        child: Text("No Doctors Founds"),
                      )
                  else
                    Column(children: <Widget>[
                      ValueListenableBuilder<String>(
                          valueListenable: selectedSpecName,
                          builder: (BuildContext ctz, String value, Widget wid) {
                            // if (showShimmer.value) {
                            //   return SizedBox(
                            //     width: 100.w,
                            //     height: 14.w,
                            //     child: ListView(
                            //       scrollDirection: Axis.horizontal,
                            //       children: doctorList
                            //           .map((DoctorModel e) => Shimmer.fromColors(
                            //                 direction: ShimmerDirection.ltr,
                            //                 period: const Duration(seconds: 2),
                            //                 baseColor: Colors.white,
                            //                 highlightColor: Colors.grey.withOpacity(0.2),
                            //                 child: TeleConsultationWidgetsOnlineSevices.tabbar(
                            //                     titile: "Speadsdfgfhfsdadc",
                            //                     selectedTile: value.toString()),
                            //               ))
                            //           .toList(),
                            //     ),
                            //   );
                            // }
                            return SizedBox(
                              width: 100.w,
                              height: 14.w,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  ...allSpecList.map((SpecialityList e) {
                                    return InkWell(
                                      onTap: () async {
                                        if (selectedSpecName.value != e.specialityName) {
                                          selectedSpecName.value = e.specialityName;
                                          await gettingFunction();
                                        }
                                      },
                                      child: TeleConsultationWidgetsOnlineSevices.tabbar(
                                          titile: e.specialityName, selectedTile: value),
                                    );
                                  }).toList(),
                                  SizedBox(width: 2.w)
                                ],
                              ),
                            );
                          }),
                      SizedBox(height: 2.w),
                      ValueListenableBuilder<bool>(
                          valueListenable: showShimmer,
                          builder: (BuildContext context, bool value, Widget widget) {
                            if (value) {
                              return Wrap(
                                runSpacing: 1.w,
                                spacing: 2.w,
                                children: doctorList
                                    .map((DoctorModel e) => Padding(
                                          padding: EdgeInsets.all(1.w),
                                          child: Shimmer.fromColors(
                                            direction: ShimmerDirection.ltr,
                                            period: const Duration(seconds: 2),
                                            baseColor: Colors.white,
                                            highlightColor: Colors.grey.withOpacity(0.2),
                                            child: Container(
                                              width: 45.w,
                                              height: 60.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              );
                            }
                            if (doctorList.isEmpty) {
                              return Container(
                                height: 60.h,
                                alignment: Alignment.center,
                                child: const Text("Currently No Doctors Available !"),
                              );
                            }
                            return Container(
                              width: doctorList.length < 2 ? 95.w : null,
                              height: 100.h < 800 ? 65.5.h : 70.h,
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: doctorList.length,
                                itemBuilder: (BuildContext ctx, int index) {
                                  return TeleConsultationWidgetsOnlineSevices.docTiles(
                                      doc: doctorList[index]);
                                },
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisExtent: 62.w,
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 2.w,
                                    crossAxisSpacing: 2.w),
                              ),
                              //  Wrap(
                              //     alignment: WrapAlignment.start,
                              //     runSpacing: 1.w,
                              //     spacing: 2.w,
                              //     children: doctorList.map((DoctorModel doc) {
                              //       return TeleConsultationWidgetsOnlineSevices.docTiles(
                              //           doc: doc);
                              //     }).toList()),
                            );
                          }),
                      // SizedBox(height: 6.h)
                    ]),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Timer _debounceTimer;

  void debounce(VoidCallback callback) {
    const Duration debounceDuration = Duration(seconds: 2);
    if (_debounceTimer != null) {
      _debounceTimer.cancel();
    }
    _debounceTimer = Timer(debounceDuration, callback);
  }
}
