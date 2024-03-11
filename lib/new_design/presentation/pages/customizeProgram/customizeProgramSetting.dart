import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../main.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/appText.dart';
import '../../../app/utils/textStyle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/providers/network/apis/selectedProgramApi.dart';
import '../../Widgets/appBar.dart';
import '../dashboard/common_screen_for_navigation.dart';
import '../home/landingPage.dart';
import 'CustomizeBLoC.dart';
import 'customizeProgramEvnet.dart';
import 'customizeProgramState.dart';
import 'selectedProgramDashboard.dart';

class ProgramCustomSettings extends StatelessWidget {
  final SelectedDashboardState dataState;
  final List<String> listOfPrograms;
  ProgramCustomSettings({
    Key key,
    this.dataState,
    this.listOfPrograms,
  }) : super(key: key);
  // Implement this code when every program displayed in dashboard.
  // Map<String, List> programsList = {
  //   "Manage Health": ["Vitals", "Calorie Tracker", "Step Tracker"],
  //   "Online Services": ["Teleconsultations", "Online Class"],
  //
  //   ///uncomment this line to add "Diabetics Health"
  //   // "Health Program": ["Heart Health", "Set Your Goals", "Diabetics Health"],
  //   "Health Program": ["Heart Health", "Weight Management"],
  //   "Social": ["Health Challenge", "Health Tips", "News Letter", "Ask IHL", "hPod Locations"]
  // };
  Map<String, List> programsList = {
    "Manage Health": ["Vitals", "Calorie Tracker"],
    "Online Services": ["Teleconsultations", "Online Class"],

    ///uncomment this line to add "Diabetics Health"
    // "Health Program": ["Heart Health", "Set Your Goals", "Diabetics Health"],
    "Health Program": ["Heart Health"],
    "Social": ["Health Challenge", "Health Tips"]
  };
  SelectedDashboard _selectedDasboard;
  @override
  Widget build(BuildContext context) {
    // final SelectedProgramBloc selectedProgramBloc = BlocProvider.of<SelectedProgramBloc>(context);
    Map<String, dynamic> fetchedList;
    List<String> prgrmListSelected;
    dataState is ProgramLoadedState ? fetchedList = dataState.props[0] : null;
    dataState is ProgramLoadedState ? prgrmListSelected = listOfPrograms : null;
    prgrmListSelected.remove("Home");
    print(fetchedList);
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      // ),
      body: CommonScreenForNavigation(
        contentColor: "true",
        content: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: dataState is ProgramLoadedState
                  ? BlocProvider(
                      create: (BuildContext context) => SelectedProgramBloc(
                          fetchedPrograms: prgrmListSelected, storeData: fetchedList),
                      child: BlocBuilder<SelectedProgramBloc, SelectedprogramState>(
                          builder: (BuildContext context, SelectedprogramState state) {
                        final SelectedProgramBloc selectedProgramBloc =
                            BlocProvider.of<SelectedProgramBloc>(context);
                        return Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            SizedBox(height: 10.5.h),
                            Row(
                              children: [
                                const Spacer(flex: 1),
                                Text(
                                  "Dashboard Preference",
                                  style: AppTextStyles.dashBoardPreference,
                                ),
                                const Spacer(flex: 1),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                              child: Text(
                                "Set your preference for dashboard",
                                style: AppTextStyles.dashBoardPreference1,
                              ),
                            ),
                            dataState is ProgramLoadingState
                                ? Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.withOpacity(0.2),
                                    child: Container(
                                      height: 12.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: programsList.length,
                                            itemBuilder: (BuildContext ctx, int index) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Material(
                                                      elevation: state.selectedProgram !=
                                                              programsList.keys.elementAt(index)
                                                          ? 1.0
                                                          : 0.0,
                                                      shadowColor: Colors.blueGrey,
                                                      child: SizedBox(
                                                        height: 8.h,
                                                        child: ListTile(
                                                          onTap: () {
                                                            // if (!state.programSelected.contains(programsList.keys.elementAt(index))) {
                                                            if (state.selectedProgram !=
                                                                programsList.keys
                                                                    .elementAt(index)) {
                                                              selectedProgramBloc.add(
                                                                  SelectProgramEvent(
                                                                      selecetedProgram: programsList
                                                                          .keys
                                                                          .elementAt(index)));
                                                            } else {
                                                              selectedProgramBloc.add(
                                                                  UnSelectProgramEvent(
                                                                      unselecetedProgram:
                                                                          programsList.keys
                                                                              .elementAt(index)));
                                                            }
                                                          },
                                                          leading: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors.transparent,
                                                                borderRadius:
                                                                    BorderRadius.circular(20.w)),
                                                            height: 12.w,
                                                            width: 12.w,
                                                            padding: const EdgeInsets.all(8),
                                                            child: Image.asset(
                                                              'newAssets/Icons/${programsList.keys.elementAt(index)}.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          title: Text(
                                                              programsList.keys.elementAt(index),
                                                              style: AppTextStyles
                                                                  .dashBoardPreference2),
                                                          trailing:
                                                              // state.programSelected.contains(programsList.keys.elementAt(index))
                                                              state.selectedProgram !=
                                                                          programsList.keys
                                                                              .elementAt(index) &&
                                                                      !programsList[programsList
                                                                              .keys
                                                                              .elementAt(index)]
                                                                          .contains(
                                                                              state.selectedProgram)
                                                                  ? Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_outlined,
                                                                      size: 25.sp,
                                                                      color:
                                                                          const Color(0xff103e42),
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .keyboard_arrow_up_outlined,
                                                                      size: 25.sp,
                                                                      color:
                                                                          const Color(0xff103e42),
                                                                    ),
                                                          tileColor:
                                                              //!state.programSelected.contains(programsList.keys.elementAt(index))
                                                              state.selectedProgram !=
                                                                          programsList.keys
                                                                              .elementAt(index) &&
                                                                      !programsList[programsList
                                                                              .keys
                                                                              .elementAt(index)]
                                                                          .contains(
                                                                              state.selectedProgram)
                                                                  ? Colors.white
                                                                  : AppColors.primaryColor
                                                                      .withOpacity(0.2),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        // state.programSelected.contains(programsList.keys.elementAt(index)),
                                                        state.selectedProgram ==
                                                                programsList.keys
                                                                    .elementAt(index) ||
                                                            programsList[programsList.keys
                                                                    .elementAt(index)]
                                                                .contains(state.selectedProgram),
                                                    child: SizedBox(
                                                      height: programsList[programsList.keys
                                                                      .elementAt(index)]
                                                                  .length <=
                                                              1
                                                          ? 190
                                                          : 190 *
                                                              programsList[programsList.keys
                                                                      .elementAt(index)]
                                                                  .length /
                                                              2,
                                                      // color: Colors.transparent,
                                                      child: GridView.builder(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount: programsList[programsList.keys
                                                                  .elementAt(index)]
                                                              .length,
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                                  crossAxisCount: 2,
                                                                  childAspectRatio: 2 / 1.4),
                                                          itemBuilder:
                                                              (BuildContext context, int i) {
                                                            List tempList = programsList[
                                                                programsList.keys.elementAt(index)];
                                                            return Center(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  if (!state.programList
                                                                      .contains(tempList[i])) {
                                                                    selectedProgramBloc.add(
                                                                        SelectProgramEvent(
                                                                            selecetedProgram:
                                                                                programsList.keys
                                                                                    .elementAt(
                                                                                        index),
                                                                            subPrograms:
                                                                                tempList[i]));
                                                                  } else {
                                                                    selectedProgramBloc.add(
                                                                        UnSelectProgramEvent(
                                                                            unselecetedProgram:
                                                                                programsList.keys
                                                                                    .elementAt(
                                                                                        index),
                                                                            removedSubProgram:
                                                                                tempList[i]));
                                                                  }
                                                                },
                                                                child: Card(
                                                                  color: state.programList
                                                                          .contains(tempList[i])
                                                                      ? AppColors.primaryAccentColor
                                                                          .withOpacity(0.1)
                                                                      : Colors.white,
                                                                  elevation: 2,
                                                                  shadowColor: state.programList
                                                                          .contains(tempList[i])
                                                                      ? AppColors.primaryAccentColor
                                                                          .withOpacity(0.1)
                                                                      : null,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(5),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: <Widget>[
                                                                      Container(
                                                                        alignment: Alignment.center,
                                                                        height: 40,
                                                                        width: 40,
                                                                        decoration: BoxDecoration(
                                                                            color: state.programList
                                                                                    .contains(
                                                                                        tempList[i])
                                                                                ? AppColors
                                                                                    .primaryColor
                                                                                    .withOpacity(
                                                                                        0.3)
                                                                                : Colors.white,
                                                                            shape: BoxShape.circle,
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                  blurRadius: 2,
                                                                                  color: Colors.grey
                                                                                      .withOpacity(
                                                                                          0.09),
                                                                                  offset:
                                                                                      const Offset(
                                                                                          1, 1),
                                                                                  spreadRadius: 4)
                                                                            ]),
                                                                        child: Container(
                                                                          height: 20,
                                                                          width: 20,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors
                                                                                  .transparent,
                                                                              image:
                                                                                  DecorationImage(
                                                                                fit: BoxFit.contain,
                                                                                image: tempList[
                                                                                            i] ==
                                                                                        "Teleconsultations"
                                                                                    ? const AssetImage(
                                                                                        'newAssets/tele.png')
                                                                                    : AssetImage(
                                                                                        'newAssets/Icons/${tempList[i]}.png'),
                                                                              )),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: 40.w,
                                                                      ),
                                                                      Text(tempList[i]),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                        RepositoryProvider(
                                            create: (BuildContext context) => SelectedDashboard(),
                                            child: BlocProvider(
                                                create: (BuildContext context) =>
                                                    ButtonBloc()..add(ButtonInitialEvent()),
                                                child: BlocBuilder<ButtonBloc, ButtonState>(
                                                  builder: (BuildContext ctx, ButtonState bState) {
                                                    final ButtonBloc buttonBloc =
                                                        BlocProvider.of<ButtonBloc>(ctx);

                                                    return Column(
                                                      children: [
                                                        Visibility(
                                                            visible: state is SelectedprogramState
                                                                ? state.programSelected.isNotEmpty
                                                                : false,
                                                            child: ElevatedButton(
                                                                onPressed: () async {
                                                                  state.programSelected.length > 2
                                                                      ? buttonBloc.add(
                                                                          ButtonPressedEvent(
                                                                              storeData:
                                                                                  state.storeData))
                                                                      : buttonBloc.add(
                                                                          ButtonWarningEvent());
                                                                },
                                                                style: state.programSelected
                                                                            .length >
                                                                        2
                                                                    ? ElevatedButton.styleFrom(
                                                                        primary: bState
                                                                                .props.isNotEmpty
                                                                            ? bState.props[0] !=
                                                                                    "true"
                                                                                ? AppColors
                                                                                    .primaryColor
                                                                                : Colors.grey
                                                                            : AppColors
                                                                                .primaryColor)
                                                                    : ElevatedButton.styleFrom(
                                                                        primary: Colors.grey),
                                                                child: bState.props.isNotEmpty
                                                                    ? bState.props[0] != "true"
                                                                        ? const Text(
                                                                            AppTexts.continueText)
                                                                        : SizedBox(
                                                                            height: 4.h,
                                                                            child:
                                                                                const CircularProgressIndicator())
                                                                    : const Text(
                                                                        AppTexts.continueText))),
                                                        BlocListener<ButtonBloc, ButtonState>(
                                                          listener: (BuildContext context,
                                                              ButtonState bottonstate) {
                                                            if (bottonstate is ButtonLoadedState) {
                                                              // Show AwesomeDialog when MySuccessState is reached
                                                              if (bottonstate.response ==
                                                                      'Updated Successfully' ||
                                                                  bottonstate.response ==
                                                                      'Successfully Recorded') {
                                                                AwesomeDialog(
                                                                  context: context,
                                                                  dialogType: DialogType.SUCCES,
                                                                  animType: AnimType.BOTTOMSLIDE,
                                                                  dismissOnBackKeyPress: false,
                                                                  title: 'Success',
                                                                  desc: 'Your Preference is saved',
                                                                  btnOkOnPress: () {
                                                                    Get.to(LandingPage());
                                                                  },
                                                                ).show();
                                                              } else {
                                                                AwesomeDialog(
                                                                  context: context,
                                                                  dialogType: DialogType.WARNING,
                                                                  animType: AnimType.BOTTOMSLIDE,
                                                                  dismissOnBackKeyPress: false,
                                                                  title: 'Error',
                                                                  desc: 'Unable to load data',
                                                                  btnOkOnPress: () {
                                                                    Get.to(LandingPage());
                                                                  },
                                                                ).show();
                                                              }
                                                            } else if (bottonstate
                                                                is ButtonWarningState) {
                                                              const SnackBar snackBar = SnackBar(
                                                                duration: Duration(seconds: 2),
                                                                dismissDirection:
                                                                    DismissDirection.none,
                                                                content: Center(
                                                                    child: Text(
                                                                  'Select atleast 3 programs',
                                                                  style:
                                                                      TextStyle(color: Colors.red),
                                                                )),
                                                              );
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(snackBar);
                                                            }
                                                          },
                                                          child:
                                                              Container(), // The child can be an empty container
                                                        )
                                                      ],
                                                    );
                                                  },
                                                ))),
                                        SizedBox(
                                          height: 32.h,
                                        )
                                      ],
                                    ),
                                  ),
                          ],
                        );
                      }),
                    )
                  : Shimmer.fromColors(
                      direction: ShimmerDirection.ltr,
                      period: const Duration(seconds: 2),
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.withOpacity(0.2),
                      child: Container(
                        height: 12.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
