// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../new_design/presentation/controllers/healthchallenge/healthChallengeController.dart';
import '../../widgets/offline_widget.dart';
import '../controllers/challenge_api.dart';
import '../models/challengemodel.dart';
import '../models/listchallenge.dart';
import '../widgets/custom_listview_widget.dart';
import '../../widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Getx/controller/listOfChallengeContoller.dart';
import '../models/enrolled_challenge.dart';

class ListofChallenges extends StatefulWidget {
  ListofChallenges({Key key, @required this.list, this.challengeType}) : super(key: key);
  List list;
  final String challengeType;
  @override
  State<ListofChallenges> createState() => _ListofChallengesState();
}

class _ListofChallengesState extends State<ListofChallenges> {
  final HealthChallengeController _healthChallengeController = Get.put(HealthChallengeController());

  @override
  void dispose() {
    Get.delete<HealthChallengeController>();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: ScrollessBasicPageUI(
        appBar: AppBar(
          leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              )),
          title: Text(
              widget.challengeType == null
                  ? 'New Challenge'
                  : widget.challengeType.toLowerCase() == 'step challenge'
                      ? 'Step Challenge'
                      : 'Other Challenges',
              style: const TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: GetBuilder<HealthChallengeController>(
            id: _healthChallengeController.updateId,
            init: HealthChallengeController(),
            builder: (_builder) {
              if (_builder.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (!_builder.isLoading && _builder.listofChallenges.isNotEmpty) {
                return GetBuilder<HealthChallengeController>(
                  init: HealthChallengeController(),
                  id: _builder.fetchId,
                  builder: (_) {
                    return ListView.builder(
                        itemCount: _builder.listofChallenges.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _builder.listofChallenges.length) {
                            return Center(
                                child: _builder.isFetching
                                    ? const CircularProgressIndicator()
                                    : const SizedBox.shrink());
                          }
                          return PlaningGrid(
                            title: _builder.listofChallenges[index].challengeName,
                            challengeType: _builder.listofChallenges[index].challengeType,
                            groupOrIndividual: _builder.listofChallenges[index].challengeMode,
                            imageUrl: _builder.listofChallenges[index].challengeImgUrlThumbnail,
                            challangeID: _builder.listofChallenges[index].challengeId,
                          );
                        });
                  },
                );
              } else if (!_builder.isLoading && _builder.listofChallenges.isEmpty) {
                return const Center(child: Text('No challenges currently available.'));
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
