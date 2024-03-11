import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/app_colors.dart';
import '../../../data/model/TeleconsultationModels/TeleconulstationDashboardModels.dart';
import '../../Widgets/teleconsultation_widgets/teleconsultation_widget_onlineServies.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../dashboard/common_screen_for_navigation.dart';

class SearchBySpecAndList extends StatefulWidget {
  const SearchBySpecAndList({Key key}) : super(key: key);

  @override
  State<SearchBySpecAndList> createState() => _SearchBySpecAndListState();
}

class _SearchBySpecAndListState extends State<SearchBySpecAndList> {
  @override
  void initState() {
    super.initState();
  }

  List<SpecialityList> specList = List.generate(10, (index) => SpecialityList());

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: const Text("Our Specialities"),
      ),
      content: SizedBox(
        height: 100.h,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
              child: PhysicalModel(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                elevation: 2.0,
                child: TextField(
                  controller: TeleConsultationFunctionsAndVariables.searchSpecController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      TeleConsultationFunctionsAndVariables.searchResultSpec.value = specList
                          .where((element) =>
                              element.specialityName.toLowerCase().contains(value.toLowerCase()))
                          .toList();
                    } else {
                      TeleConsultationFunctionsAndVariables.searchResultSpec.value = [];
                    }
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
                      hintText: 'Search by Specialities',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ),
            ),
            Expanded(
              // height: 50.h,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ValueListenableBuilder<List<SpecialityList>>(
                        valueListenable: TeleConsultationFunctionsAndVariables.searchResultSpec,
                        builder: (c, val, _) {
                          if (val.isNotEmpty) {
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(1.h),
                                  child: Wrap(
                                      runSpacing: 2.h,
                                      spacing: 2.h,
                                      children: val.map((e) {
                                        return TeleConsultationWidgetsOnlineSevices.specTiles(
                                            specialityList: e);
                                      }).toList()),
                                ),
                                SizedBox(height: 10.h)
                              ],
                            );
                          } else if (val.isEmpty &&
                              TeleConsultationFunctionsAndVariables
                                  .searchSpecController.text.isNotEmpty) {
                            return const Center(
                              child: Text("No Specialities Found !"),
                            );
                          } else {
                            return FutureBuilder<List<SpecialityList>>(
                                future: TeleConsultationFunctionsAndVariables.allSpecGetter(),
                                builder: (BuildContext ctx, AsyncSnapshot<List<SpecialityList>> i) {
                                  if (i.connectionState == ConnectionState.done) {
                                    specList = i.data;
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(1.h),
                                          child: Wrap(
                                              runSpacing: 2.h,
                                              spacing: 2.h,
                                              children: i.data.map((e) {
                                                return TeleConsultationWidgetsOnlineSevices
                                                    .specTiles(specialityList: e);
                                              }).toList()),
                                        ),
                                        SizedBox(height: 10.h)
                                      ],
                                    );
                                  } else if (i.connectionState == ConnectionState.waiting) {
                                    return Wrap(
                                        runSpacing: 2.h,
                                        spacing: 2.h,
                                        children: specList.map((e) {
                                          return Shimmer.fromColors(
                                            direction: ShimmerDirection.ltr,
                                            period: const Duration(seconds: 2),
                                            baseColor: Colors.white,
                                            highlightColor: Colors.grey.withOpacity(0.2),
                                            child: Container(
                                              height: 30.w,
                                              width: 45.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                          );
                                        }).toList());
                                  } else {
                                    return const Text("No Specs");
                                  }
                                });
                          }
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
