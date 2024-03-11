import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ihl/Modules/online_class/data/model/getClassSpecalityModel.dart';
import 'package:ihl/new_design/presentation/Widgets/searchBarWidget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../new_design/app/utils/appColors.dart';
import '../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../searchbloc.dart';
import 'bloc/online_class_api_bloc.dart';
import 'bloc/online_class_events.dart';
import 'bloc/online_class_state.dart';

class SearchByClassAndList extends StatefulWidget {
  List<SpecialityList> classesList;

  SearchByClassAndList({Key key, this.classesList}) : super(key: key);

  @override
  State<SearchByClassAndList> createState() => _SearchByClassAndListState();
}

class _SearchByClassAndListState extends State<SearchByClassAndList> {
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
          title: Text("Our Classes"),
        ),
        content: SizedBox(
          child: BlocProvider(
            create: (BuildContext context) =>
                OnlineClassApiBloc()..add(OnlineClassApiEvent(data: "specialty")),
            child: BlocBuilder<OnlineClassApiBloc, OnlineClassState>(
                builder: (BuildContext ctx, OnlineClassState state) {
              // print('object${state}');
              return state is ApiCallLoadedClassState
                  ? Column(
                      children: [
                        // Header (scrollable)
                        SizedBox(
                          height: 10.h,
                          child: Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SearchBarWidget(
                                      searchBloc: searchBloc, specList: state.data.specialityList),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<String>(
                            stream: searchBloc.searchQuery,
                            builder: (context, snapshot) {
                              List<SpecialityList> a = state.data.specialityList
                                  .where((element) => element.specialityName
                                      .toLowerCase()
                                      .contains(snapshot.data.toString().toLowerCase()))
                                  .toList();
                              if (snapshot.data == null) {
                                return Expanded(
                                  child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    itemCount: state
                                        .data.specialityList.length, // Number of items in the grid
                                    itemBuilder: (BuildContext context, int index) {
                                      // Build and return grid items here
                                      return Padding(
                                        padding: EdgeInsets.all(8.sp),
                                        child: Container(
                                          height: 30.h,
                                          width: 45.w,
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
                                                height: 15.w,
                                                width: 15.w,
                                                child: Image.asset(
                                                  'newAssets/Icons/speciality/${state.data.specialityList[index].specialityName.toLowerCase()}.png',
                                                  errorBuilder: (BuildContext, Object, StackTrace) {
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
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  state.data.specialityList[index].specialityName,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 15.sp),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                return Expanded(
                                  child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    itemCount: a.length, // Number of items in the grid
                                    itemBuilder: (BuildContext context, int index) {
                                      // Build and return grid items here
                                      return Padding(
                                        padding: EdgeInsets.all(8.sp),
                                        child: Container(
                                          height: 30.h,
                                          width: 45.w,
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
                                                height: 15.w,
                                                width: 15.w,
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
                                                  a[index].specialityName,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 15.sp),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else if (snapshot.data.isEmpty &&
                                  state.data.specialityList.isEmpty) {
                                return const Center(
                                  child: Text("No Specialities Found !"),
                                );
                              } else {
                                return Expanded(
                                  child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    itemCount: state
                                        .data.specialityList.length, // Number of items in the grid
                                    itemBuilder: (BuildContext context, int index) {
                                      // Build and return grid items here
                                      return Padding(
                                        padding: EdgeInsets.all(8.sp),
                                        child: Container(
                                          height: 30.h,
                                          width: 45.w,
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
                                                height: 15.w,
                                                width: 15.w,
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
                                                  state.data.specialityList[index].specialityName,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 15.sp),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        // Grid
                        SizedBox(
                          height: 9.h,
                        )
                      ],
                    )
                  : Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.withOpacity(0.3),
                      direction: ShimmerDirection.ltr,
                      child: Padding(
                        padding: EdgeInsets.all(1.h),
                        child: Wrap(runSpacing: 2.h, spacing: 2.h, children: [
                          Container(
                            height: 100.h,
                            width: 100.w,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              color: Colors.grey,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          )
                        ]),
                      ),
                    );
            }),
          ),
        ));
  }
}
