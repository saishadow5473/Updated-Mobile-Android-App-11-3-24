import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../Modules/online_class/bloc/class_and_consultant_bloc/bloc/classandconsultantbloc_bloc.dart';
import '../../../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../../../Modules/online_class/data/model/consultantAndClassListModel.dart';
import '../../../../../Modules/online_class/functionalities/class_time_calculation.dart';
import '../../../../../Modules/online_class/presentation/pages/class_and_consultant_list.dart';
import '../../../../../Modules/online_class/presentation/pages/view_all_class.dart';
import '../../../../../health_challenge/views/health_challenges_types.dart';
import '../../../../app/services/teleconsultation/teleconsultation_services.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../../../presentation/clippath/subscriptionTagClipPath.dart';
import '../../../../presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../../../presentation/pages/onlineServices/SearchByDocAndList.dart';
import '../../bloc/online_services_api_state.dart';
import '../../data/model/get_spec_class_list.dart';
import '../../data/model/get_subscribtion_list.dart';
import '../online_class_screens/book_class_after_subscription.dart';
import '../online_class_screens/book_class_before_subscription.dart';
import '../online_class_screens/class_search.dart';
import '../online_class_screens/view_all.dart';

class OnlineServicesWidgets {
  Widget specialtyCard(BuildContext context,
      {@required List<String> specialtyList,
      int length,
      @required List<dynamic> fullMrgedList,
      @required List<dynamic> data}) {
    ScrollController _scrollController = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Our Specialty",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.5.sp,
                  color: AppColors.primaryAccentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return ViewAllSpecList(
                    classesList: fullMrgedList,
                    data: data,
                  );
                }));
              },
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18.sp,
                weight: 10.sp,
                color: AppColors.primaryColor,
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Container(
            height: 32.h,
            width: 65.h,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(1, 1),
                      spreadRadius: 2,
                      blurRadius: 3,
                      color: Colors.grey.shade300)
                ]),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor:
                    MaterialStateProperty.all(AppColors.primaryAccentColor.withOpacity(0.4)),
                interactive: true,
                radius: const Radius.circular(10.0),
                thickness: MaterialStateProperty.all(3),
                minThumbLength: 60,
              ),
              child: Scrollbar(
                controller: _scrollController,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: specialtyList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 2 / 1.4
                      // crossAxisSpacing: 4.0,
                      // mainAxisSpacing: 4.0
                      ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        if (data.contains(specialtyList[index])) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) => ClassSearch(
                                      selectedSpec: specialtyList[index],
                                    )),
                          );
                        } else {
                          Get.to(SearchByDocAndList(specName: specialtyList[index]));
                        }
                      },
                      child: Card(
                        color: AppColors.plainColor,
                        elevation: 3,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: SizedBox(
                                    height: 10.h,
                                    width: 10.w,
                                    child: Image.asset(
                                      'newAssets/Icons/speciality/${specialtyList[index]}.png',
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
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.03,
                              ),
                              Expanded(
                                  child: Text(
                                specialtyList[index],
                                maxLines: 1,
                                style: const TextStyle(fontSize: 12),
                              ))
                            ]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget CategoryCard(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Our Services",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15.5.sp,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Container(
            height: 32.h,
            width: 65.h,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(1, 1),
                      spreadRadius: 2,
                      blurRadius: 3,
                      color: Colors.grey.shade300)
                ]),
            child: Padding(
              padding: EdgeInsets.only(right: 1.w, left: 1.w, top: .5.h),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor:
                      MaterialStateProperty.all(AppColors.primaryAccentColor.withOpacity(0.4)),
                  interactive: true,
                  radius: const Radius.circular(10.0),
                  thickness: MaterialStateProperty.all(3),
                  minThumbLength: 60,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 2 / 1.4
                        // crossAxisSpacing: 4.0,
                        // mainAxisSpacing: 4.0
                        ),
                    itemBuilder: (BuildContext context, int index) {
                      if (selectedAffiliationfromuniquenameDashboard == "dev_testing" &&
                          index == options.length - 1) {
                        return Container();
                      }
                      // if (selectedAffiliationfromuniquenameDashboard == "dev_testing" &&
                      //     index == options.length - 2) {
                      //   return Container();
                      // }
                      if (selectedAffiliationfromuniquenameDashboard == "ihl_care" &&
                          index == options.length - 1) {
                        return Container();
                      }
                      return GestureDetector(
                        // onTap: options[index]['onTap'],
                        onTap: options[index]['text'] == "Health Challenges"
                            ? () {
                                Get.to(HealthChallengesComponents(
                                  list: const ["global", "Global"],
                                ));
                              }
                            : options[index]["text"] == "Subscription"
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                        builder: (BuildContext ctx) => MultiBlocProvider(
                                              providers: <BlocProvider<TrainerBloc>>[
                                                BlocProvider<TrainerBloc>(
                                                    create: (BuildContext context) =>
                                                        TrainerBloc()),
                                              ],
                                              child: ViweAllClass(
                                                  subcriptionList: const <Subscription>[],
                                                  isHome: "No"),
                                            )))
                                : () {
                                    // Get.to(const ClassAndConsultantListPage());
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) => MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                          create: (BuildContext context) =>
                                                              ClassandconsultantblocBloc()),
                                                    ],
                                                    child: ClassAndConsultantListPage(
                                                      category: options[index]['text'],
                                                    ))));
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         // ignore: always_specify_types
                                    //         builder: (context) => const ClassAndConsultantListPage()));
                                  },
                        child: Card(
                          color: AppColors.plainColor,
                          elevation: 3,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 2.h),
                                Center(
                                  child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SizedBox(
                                          height: 8.h,
                                          width: 60.w,
                                          child: options[index]['image'].toString().contains('svg')
                                              ? SvgPicture.asset(
                                                  'assets/svgs/mobile-icon.svg',
                                                  color: Colors.red,
                                                  fit: BoxFit.contain,
                                                  height: 20,
                                                )
                                              : options[index]['image'].toString().contains('png')
                                                  ? Image(
                                                      image: AssetImage(options[index]['image']))
                                                  : options[index]['icon']
                                                              .toString()
                                                              .contains('Customicons') ||
                                                          options[index]['icon']
                                                              .toString()
                                                              .contains('AppColors')
                                                      ? Icon(
                                                          options[index]['icon'],
                                                          size: 160.0,
                                                          color: options[index]['colors'],
                                                        )
                                                      : Icon(
                                                          options[index]['icon'],
                                                          size: 30.0,
                                                          color: options[index]['colors'],
                                                        ))),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.03,
                                ),
                                Expanded(
                                    child: Text(
                                  '${options[index]['text']}',
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 12),
                                ))
                              ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ClassSpecTile({String title, bool specSelected}) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(25),
                topLeft: Radius.circular(25),
                topRight: Radius.circular(0)),
            elevation: specSelected ? 0 : 3,
            child: ClipPath(
                clipper: const ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(0)))),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 12.w,
                  // width: 30.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Color(0XFFDCDBDB),
                      border: specSelected
                          ? Border(bottom: BorderSide(color: AppColors.primaryColor, width: 1.w))
                          : null),
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
          SizedBox(height: 2.w)
        ],
      ),
    );
  }

  Widget classesWidget(SpecialityClassList data, BuildContext ctx) {
    // ClassDetail classDetails = data;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  ctx,
                  MaterialPageRoute(
                      builder: (context) => BookClassbeforeSubscription(
                            classDetail: data,
                          )));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(1, 1),
                        spreadRadius: 4,
                        blurRadius: 5,
                        color: Colors.grey.shade300)
                  ]),
              child: FutureBuilder(
                future: ClassImage().getCourseImageURL([data.courseId]),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<String> image = snapshot.data[0]['base_64'].split(',');
                    Uint8List bytes1;
                    bytes1 = const Base64Decoder().convert(image[1].toString());
                    return bytes1 == null
                        ? const Placeholder()
                        : Padding(
                            padding: const EdgeInsets.only(top: 15, left: 15, right: 15.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 15.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff7c94b6),
                                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                    image: DecorationImage(
                                        image: Image.memory(
                                          base64Decode(image[1].toString()),
                                        ).image,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Container(
                                  height: 10.h,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, left: 4.0, right: 4.0, bottom: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(width: 60.w, child: Text(data.title)),
                                            Row(
                                              children: [
                                                const Text(
                                                  '★ ',
                                                  style: TextStyle(color: Colors.amber),
                                                ),
                                                Text(data.ratings.toString()),
                                              ],
                                            )
                                          ],
                                        ),
                                        Text(
                                          TimeCalculation()
                                              .getClassStartTime(data.courseTime.first),
                                          style: const TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                  }
                  if (snapshot.hasError) {
                    return Shimmer.fromColors(
                      direction: ShimmerDirection.ltr,
                      enabled: true,
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.shade300,
                      child: Container(
                        height: 40.5.w,
                        width: 90.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      direction: ShimmerDirection.ltr,
                      enabled: true,
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.shade400,
                      child: Container(
                        height: 40.5.w,
                        width: 90.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                    // return Container(
                    //   child: Center(
                    //     child: CircularProgressIndicator(),
                    //   ),
                    // );
                  }
                  return Shimmer.fromColors(
                    baseColor: Colors.white,
                    direction: ShimmerDirection.ltr,
                    highlightColor: Colors.grey.withOpacity(0.2),
                    child: Container(
                      height: 47.5.w,
                      width: 95.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            child: ClipPath(
              clipper: SubscriptionClipPath(),
              child: Container(
                color: AppColors.primaryAccentColor,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      data.feesFor,
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 15.sp),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
