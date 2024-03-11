import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../health_challenge/models/challengemodel.dart';
import '../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../health_challenge/models/listchallenge.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';

class HealthChallengeController extends GetxController {
  final GlobalKey<AnimatedListState> key = GlobalKey();
  List<Challenge> _listofChallenges = [];
  List<EnrolledChallenge> enrolledChallenge;
  var prefs;
  String affi;
  String _email = '';
  int _start = 0;
  bool _lastPage = false;
  bool _isLoading = true;
  bool _isFetching = true;
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  final String _ListChallengeUpdateId = 'ListUpdate';
  final String _isFetchedId = 'Fetched';
  String get fetchId => _isFetchedId;
  String get updateId => _ListChallengeUpdateId;
  List<Challenge> get listofChallenges => _listofChallenges;
  Future fetchEnrollChallenges() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    var userData = jsonDecode(data);
    String userid = prefs1.getString("ihlUserId");
    _email = userData['User']['email'];
    //Calling listofUserEnrolledChallenges API to get enrolled Challenges
    enrolledChallenge = await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
  }

  Future _fetchNewChallengeList() async {
    int _end = _start + 20;
    _isFetching = true;
    ListChallenge _challenge = ListChallenge(
        affiliation_list: [affi],
        challenge_mode: '',
        pagination_start: _start,
        email: _email,
        pagination_end: _end);
    List<Challenge> _newChallengesFromApi;
    try {
      _newChallengesFromApi = await ChallengeApi().listOfChallenges(challenge: _challenge);
    } catch (e) {
      _lastPage = true;
      _isLoading = false;
      _isFetching = false;
      update([_ListChallengeUpdateId, fetchId]);
      debugPrint('Failed to Network');
    }
    _start += 20;
    // if there are no more challenges, set last page to true and end the fetch
    if (_newChallengesFromApi.length < 20) {
      _lastPage = true;
      _isLoading = false;
      _isFetching = false;
      update([_ListChallengeUpdateId, fetchId]);
    }
    // remove all the enrolled challenges from the new challenges list
    if (enrolledChallenge.isNotEmpty) {
      for (EnrolledChallenge i in enrolledChallenge) {
        _newChallengesFromApi
            .removeWhere((Challenge element) => element.challengeId == i.challengeId);
      }
    }
    // remove all the inactive challenges from the new challenges list
    _newChallengesFromApi.removeWhere((Challenge element) => element.challengeStatus == "deactive");

    // remove all the challenges that have already started from the new challenges list
    _newChallengesFromApi.removeWhere((Challenge element) {
      if (DateFormat('MM-dd-yyyy').format(element.challengeStartTime) != "01-01-2000") {
        return DateTime.now().isAfter(element.challengeEndTime);
      } else {
        return false;
      }
    });
    // if the new challenges list is not empty, add it to the list of challenges
    if (_newChallengesFromApi.isNotEmpty) {
      _listofChallenges.addAll(_newChallengesFromApi);
      // if there are less than 5 challenges, set loading to false and end the fetch
      if (_listofChallenges.length < 5) {
        _isLoading = false;
        _isFetching = false;
        update([_ListChallengeUpdateId, _isFetchedId]);
      } else {
        _isFetching = false;
        update([_isFetchedId]);
      }
    }
    // if the new challenges list is not empty and loading is true, set loading to false
    if (_newChallengesFromApi.isNotEmpty && _isLoading) {
      _isLoading = false;
      update([_ListChallengeUpdateId]);
    } else if (_listofChallenges.isNotEmpty && !_isLoading) {
      update([_ListChallengeUpdateId]);
    }
    // if there are more challenges, fetch the next page
    if (!_lastPage) {
      _fetchNewChallengeList();
    }
  }

  @override
  void onInit() async {
    prefs = await SharedPreferences.getInstance();
    String ss = prefs.getString("sso_flow_affiliation");
    if (ss != null) {
      Map<String, dynamic> exsitingAffi = jsonDecode(ss);
      UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
        "affiliation_unique_name": exsitingAffi["affiliation_unique_name"]
      };
    }
    affi = (UpdatingColorsBasedOnAffiliations.ssoAffiliation == null ||
            UpdatingColorsBasedOnAffiliations.ssoAffiliation['affiliation_unique_name'] == null)
        ? "Global"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
    await fetchEnrollChallenges();
    await _fetchNewChallengeList();
    super.onInit();
  }
}
