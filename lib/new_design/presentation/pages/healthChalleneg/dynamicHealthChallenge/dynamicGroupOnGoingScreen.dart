import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../Getx/controller/google_fit_controller.dart';
import '../../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../../health_challenge/models/group_details_model.dart';
import '../../../../../health_challenge/models/group_model.dart';
import '../../../../../health_challenge/views/group_member_lists.dart';
import '../../../../app/utils/appText.dart';

import '../../../../../health_challenge/models/challenge_detail.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_text_styles.dart';
import '../../../clippath/subscriptionTagClipPath.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import '../getX_widget_responsive/challange_ui_reponse.dart';
import '../widgets/on_going_challenge_widgets.dart';
import 'dynamicCertificateDetailScreen.dart';
import 'dynamicGroupMemberListScreen.dart';

class DynamicGroupOnGoingScreen extends StatelessWidget {
  final ChallengeDetail challengeDetail;
  final GroupDetailModel groupModel;
  final EnrolledChallenge filteredList;
  final bool currentUserIsAdmin;
  EnrolledChallenge enrolledchallenge;
  bool firstTimeLog = false;
  DynamicGroupOnGoingScreen(
      {Key key,
      this.currentUserIsAdmin,
      this.challengeDetail,
        this.enrolledchallenge,
      this.groupModel,
      this.filteredList,
      this.firstTimeLog})
      : super(key: key);
  // challengeDaysCalculation(){
  //
  // }
  Widget _progressText(String title, value, type) {
    return Column(
      children: [
        Text('$title'),
        SizedBox(
          height: 2.h,
        ),
        Text(
          '$value',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        SizedBox(
          height: 2.h,
        ),
        Text('($type)'),
      ],
    );
  }

// group container title heading widget
  Widget _groupHeading(Widget content) {
    return Container(
      height: 7.h,
      width: 95.w,
      color: AppColors.primaryColor.withOpacity(0.6),
      alignment: Alignment.center,
      child: content,
    );
  }

// challenge with unit return the container design
  Widget _unitGroupContributionContainer(Widget content) => Container(
      height: 22.h,
      width: 95.w,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          offset: Offset(0, 2),
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 1,
          spreadRadius: 3,
        ),
        BoxShadow(
          offset: Offset(0, -2),
          color: Colors.white,
          blurRadius: 2,
          spreadRadius: 3,
        ),
      ]),
      child: content);

  Widget _noUnitContributionContainer() {
    return Column(
      children: [
        _groupHeading(
          currentUserIsAdmin
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 25.sp,
                    ),
                    Text(groupModel.groupName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.white)),
                    Visibility(
                      visible: true,
                      child: IconButton(
                        onPressed: () {
                          Get.to(DynamicGroupMemberList(
                            challengeDetail: challengeDetail,
                            filteredData: filteredList,
                            groupDetailModel: groupModel,
                          ));
                        },
                        icon: Icon(
                          Icons.play_arrow,
                        ),
                        color: Colors.white,
                      ),
                    )
                  ],
                )
              : Text('${groupModel.groupName}',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.white)),
        ),
        Container(
          height: 18.h,
          width: 95.w,
          margin: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 1,
              spreadRadius: 3,
            ),
            BoxShadow(
              offset: Offset(0, -2),
              color: Colors.white,
              blurRadius: 2,
              spreadRadius: 3,
            ),
          ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total members in the group     ',
                      style: TextStyle(color: Colors.black, fontSize: 16.5.sp),
                    ),
                    TextSpan(
                      text: '${challengeDetail.maxUsersGroup} members',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Target completed by                 ',
                      style: TextStyle(color: Colors.black, fontSize: 16.5.sp),
                    ),
                    TextSpan(
                      text: '3 members',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              NeumorphicIndicator(
                  orientation: NeumorphicIndicatorOrientation.horizontal,
                  style: IndicatorStyle(
                      accent: AppColors.primaryColor, variant: AppColors.primaryColor),
                  height: 1.2.h,
                  width: 75.w,
                  percent: filteredList.userAchieved ?? 0 / filteredList.target ?? 0),
            ],
          ),
        )
      ],
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _stepsController = TextEditingController();
  SessionSelectionController sessionSelectionController = Get.put(SessionSelectionController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return CommonScreenForNavigation(
        resizeToAvoidBottomInset: true,
        contentColor: "true",
        appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                Get.delete<SessionSelectionController>();

                Get.back();
              }, //replaces the screen to Main dashboard
              color: Colors.white,
            ),
            title: Text(
              challengeDetail.challengeName,
              style: AppTextStyles.appBarText,
            ),
            backgroundColor: AppColors.primaryColor),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 100.w,
            // height: 100.h,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 27.h,
                        width: 95.w,
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                            ],
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(challengeDetail.challengeImgUrl))),
                      ),
                      Positioned(
                        top: .5.h,
                        child: SizedBox(
                          child: ClipPath(
                            clipper: SubscriptionClipPath(),
                            child: Container(
                              height: 2.7.h,
                              width: 20.w,
                              color: AppColors.primaryAccentColor,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: GetBuilder<SessionSelectionController>(
                                      id: Get.put(SessionSelectionController()).dayTextUpdate,
                                      builder: (_) => Text(
                                            "${_.selectedDay}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Poppins',
                                                fontSize: 10.sp),
                                          )),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    width: 90.w,
                    child: Text(challengeDetail.challengeDescription.capitalizeFirst,
                        textAlign: TextAlign.justify,
                        style: AppTextStyles.fontSize14b4RegularStyle)),
                onGoingchallengeLogDetails(context, challengeDetail, filteredList, _stepsController,
                    firstTimeLog, _formKey),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 3.sp),
                  child: Column(
                    children: [
                      Visibility(
                        visible: currentUserIsAdmin && challengeDetail.mileStoneTotalTarget != null,
                        child: _groupHeading(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 25.sp,
                              ),
                              Text(groupModel.groupName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              Visibility(
                                visible: true,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DynamicGroupMemberList(
                                                challengeDetail: challengeDetail,
                                                filteredData: filteredList,
                                                groupDetailModel: groupModel,
                                              )),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.play_arrow,
                                  ),
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                            GetBuilder<SessionSelectionController>(
    id: sessionSelectionController.dateUpdateId,
    initState: (GetBuilderState<SessionSelectionController> v) {
    sessionSelectionController.firstDateGetter(enrolledchallenge, challengeDetail);
    },
    builder: (SessionSelectionController controller) {
      return Visibility(
                        visible: challengeDetail.mileStoneTotalTarget != null,
                        child: _unitGroupContributionContainer(
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  _progressText(
                                      'Contribution', '${controller.targetAdded}', challengeDetail.challengeUnit),
                                  _progressText('Group', challengeDetail.mileStoneTotalTarget, challengeDetail.challengeUnit),
                                  _progressText(
                                      'Remaining',
                                      '${double.parse(challengeDetail.mileStoneTotalTarget??'0') - controller.targetAdded}',
                                      challengeDetail.challengeUnit)
                                ],
                              ),
                              SizedBox(
                                height: 2.5.h,
                              ),
                              NeumorphicIndicator(
                                  orientation: NeumorphicIndicatorOrientation.horizontal,
                                  style: IndicatorStyle(
                                      accent: AppColors.primaryColor,
                                      variant: AppColors.primaryColor),
                                  height: 1.2.h,
                                  width: 75.w,
                                  percent:
                                      filteredList.groupAchieved  / int.parse(challengeDetail.mileStoneTotalTarget??'0') ),
                            ],
                          ),
                        ),
                      );}),
                      Visibility(
                        visible: challengeDetail.mileStoneTotalTarget != null,
                        child: _groupHeading(
                          Text('My Contribution',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ),
                      ),
                      Visibility(
                        visible: challengeDetail.mileStoneTotalTarget != null,
                        child: _unitGroupContributionContainer(
                          Column(
                            children: [
                              _progressText('Contribution', '${filteredList.userAchieved}', challengeDetail.challengeUnit),
                              SizedBox(
                                height: 2.5.h,
                              ),
                              NeumorphicIndicator(
                                  orientation: NeumorphicIndicatorOrientation.horizontal,
                                  style: IndicatorStyle(
                                      accent: AppColors.primaryColor,
                                      variant: AppColors.primaryColor),
                                  height: 1.2.h,
                                  width: 75.w,
                                  percent:
                                      filteredList.userAchieved  / int.parse(challengeDetail.mileStoneTotalTarget??'0') ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: challengeDetail.mileStoneTotalTarget== null,
                        child: _noUnitContributionContainer(),
                      ),
                  GetBuilder<SessionSelectionController>(
                    id: Get.put(SessionSelectionController()).finishTargetUpdate,
                    builder: (_){
                      if (_.targetAdded >
                          int.parse(challengeDetail.mileStoneTotalTarget??'0')) {
                        _.finishTarget=true;
                        _.updatefinishTarget(true);
                      }
                      return
    Visibility(
                    visible: !_.finishTarget,
                    child: Card(
                      elevation: 4,
                      child: Column(
                        children:[
                          SizedBox(
                          height: 18.h,
                          width: 96.w,
                          child: Center(
                            child: Row(children: [
                              Spacer(),
                              Text('Congrats you have successfully\ncompleted the above challenge!!!'),
                              Image.asset(
                                'assets/images/certificateImage.png',
                                height: 12.h,
                                fit: BoxFit.fill,
                              ),
                              Spacer()
                            ],),
                          ),
                        ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(onPressed: (){
                              Get.to(DynamicCertificateScreen(
                                challengeDetail: challengeDetail,
                                enrolledChallenge: enrolledchallenge,
                                duration: 0,
                                groupName: groupModel.groupName,
                              ));
                            },style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                backgroundColor: const Color.fromRGBO(25, 169, 229, 1)), child: Text('Download Certificate')
                            ),
                          )

                        ] )),
                  );
                    }),
                      SizedBox(height: 20.h,)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
