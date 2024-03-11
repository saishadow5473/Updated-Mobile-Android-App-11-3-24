import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../../Modules/online_class/bloc/online_class_api_bloc.dart';
import '../../../../../Modules/online_class/bloc/online_class_events.dart';
import '../../../../../Modules/online_class/bloc/online_class_state.dart';
import '../../../../../Modules/online_class/data/model/getClassSpecalityModel.dart';
import '../../../../../Modules/searchbloc.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../presentation/Widgets/searchBarWidget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../../../presentation/pages/onlineServices/SearchByDocAndList.dart';
import 'class_search.dart';

class ViewAllSpecList extends StatefulWidget {
  List<dynamic> classesList;
  List<dynamic> data;

  ViewAllSpecList({Key key, this.classesList, this.data}) : super(key: key);

  @override
  State<ViewAllSpecList> createState() => _ViewAllSpecListState();
}

class _ViewAllSpecListState extends State<ViewAllSpecList> {
  static TextEditingController searchSpecController = TextEditingController();
  List<SpecialityList> specList = List.generate(10, (index) => SpecialityList());
  List<SpecialityList> searchResultSpec = List<SpecialityList>();

  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay
    return "Hello, World!";
  }

  @override
  Widget build(BuildContext context) {
    final searchBloc = SearchBloc();
    return CommonScreenForNavigation(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          title: const Text("Speciality"),
        ),
        content: SizedBox(
            child: Column(
          children: [
            // Header (scrollable)
            SizedBox(
              height: 10.h,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SearchBarWidget(searchBloc: searchBloc, specList: widget.classesList),
                  ],
                ),
              ),
            ),
            StreamBuilder<String>(
              stream: searchBloc.searchQuery,
              builder: (context, snapshot) {
                List searchQueryClass = widget.classesList
                    .where((element) =>
                        element.toLowerCase().contains(snapshot.data.toString().toLowerCase()))
                    .toList();
                if (snapshot.data == null) {
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: widget.classesList.length, // Number of items in the grid
                      itemBuilder: (BuildContext context, int index) {
                        // Build and return grid items here
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: 14.sp),
                          child: InkWell(
                            onTap: () {
                              if (widget.data.contains(widget.classesList[index])) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) => ClassSearch(
                                            selectedSpec: widget.classesList[index],
                                          )),
                                );
                              } else {
                                Get.to(SearchByDocAndList(specName: widget.classesList[index]));
                              }
                            },
                            child: Container(
                              // height: 25.h,
                              // width: 40.w,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.sp),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: Offset(0, 0),
                                        spreadRadius: 3)
                                  ]),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 14.h,
                                    width: 14.w,
                                    child: Image.asset(
                                      'newAssets/Icons/speciality/${widget.classesList[index]}.png',
                                      errorBuilder: (BuildContext BuildContext, Object Object,
                                          StackTrace StackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade100,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                    child: Text(
                                      widget.classesList[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 15.sp),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasData) {
                  return searchQueryClass.length == 0
                      ? Column(
                          children: [
                            SizedBox(
                              height: 50.h,
                              child: Center(
                                child: Text('No Specialities Found !'),
                              ),
                            ),
                          ],
                        )
                      : Expanded(
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemCount: searchQueryClass.length, // Number of items in the grid
                            itemBuilder: (BuildContext context, int index) {
                              // Build and return grid items here
                              return Padding(
                                padding: EdgeInsets.all(8.sp),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(SearchByDocAndList(specName: searchQueryClass[index]));
                                  },
                                  child: Container(
                                    height: 25.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15.sp),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 3,
                                              offset: Offset(0, 0),
                                              spreadRadius: 3)
                                        ]),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 14.w,
                                          width: 14.w,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade100,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            searchQueryClass[index],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 15.sp),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text("No Specialities Found !"),
                  );
                }
                return Center(child: Text("No Specialities Found !"));
              },
            ),
            // Grid
            SizedBox(
              height: 9.h,
            )
          ],
        )));
  }
}
