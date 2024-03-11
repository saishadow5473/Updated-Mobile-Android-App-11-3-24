import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_by_class_and_list.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../new_design/app/utils/appText.dart';

import 'bloc/online_class_api_bloc.dart';
import 'bloc/online_class_state.dart';

import 'presentation/widgets/online_service_widgets.dart';

class OnlineClassDashboard extends StatelessWidget {
  OnlineClassDashboard({
    Key key,
  }) : super(key: key);
  OnlineClassWidgets onlineClassWidgets = OnlineClassWidgets();

  @override
  Widget build(BuildContext context) {
    final OnlineClassApiBloc apiDataBloc = BlocProvider.of<OnlineClassApiBloc>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3.h, bottom: 1.h),
            child: onlineClassWidgets.searchBar(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: onlineClassWidgets.onlineClassDetails(context,(){}),
          ),
          BlocBuilder<OnlineClassApiBloc, OnlineClassState>(
              builder: (BuildContext ctx, OnlineClassState state) {
            return onlineClassWidgets.sectionHeader(context, AppTexts.classText, () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (BuildContext context) => AboutClass()),
              // );
              state is ApiCallLoadedClassState
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SearchByClassAndList(classesList: state.data.specialityList)),
                    )
                  : null;
            });
          }),
          Padding(
            padding: const EdgeInsets.all(12),
            child: BlocBuilder<OnlineClassApiBloc, OnlineClassState>(
                builder: (BuildContext ctx, OnlineClassState state) {
              return state is ApiCallLoadedClassState
                  ? onlineClassWidgets.specialtyCard(
                      ctx, state.data.specialityList, state.data.totalCount)
                  : Shimmer.fromColors(
                      direction: ShimmerDirection.ltr,
                      period: const Duration(seconds: 2),
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.withOpacity(0.2),
                      child: Container(
                          margin: const EdgeInsets.all(8),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width / 5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Loading')));
            }),
          ),
          BlocBuilder<StreamOnlineClassApiBloc, StreamOnlineClassState>(
              builder: (BuildContext ctx, StreamOnlineClassState state) {
            return Visibility(
              visible:
                  state is StreamApiCallLoadedState ? state.data.subcriptionList.isNotEmpty : true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                onlineClassWidgets.sectionHeader(context, "My Subscription", () {
                  // state is StreamApiCallLoadedState
                  //     ? Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (BuildContext ctx) => ViweAllClass(
                  //                   subcriptionList: state.data.subcriptionList,
                  //                 )),
                  //       )
                  //     : null;
                }),
                state is StreamApiCallLoadedState
                    ? SizedBox(
                        height: 30.h,
                        // width: .w,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.data.subcriptionList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (BuildContext context) =>
                                  //           onlineClassWidgets.aboutClass(
                                  //               context, state.data.subcriptionList[index])),
                                  // );
                                },
                                // child: Padding(
                                //   padding: EdgeInsets.all(8.sp),
                                //   child: onlineClassWidgets.cardDetailsWidget(
                                //       context, state.data.subcriptionList[index]),
                                // ),
                              );
                            }))
                    : Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        period: const Duration(seconds: 2),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey.withOpacity(0.2),
                        child: Container(
                            margin: const EdgeInsets.all(8),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width / 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Hello')))
              ]),
            );
          }),
          SizedBox(
            height: 30.h,
            width: 100.w,
            // color: Colors.white,
          )
        ],
      ),
    );
  }
}
