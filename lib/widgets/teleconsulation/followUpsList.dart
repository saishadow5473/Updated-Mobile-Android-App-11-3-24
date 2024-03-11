import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// List of Followup tile 👀 fetches data on its own
class FollowupList extends StatefulWidget {
  FollowupList({Key key}) : super(key: key);

  @override
  _FollowupListState createState() => _FollowupListState();
}

class _FollowupListState extends State<FollowupList> {
  bool hasfollowup = false;
  List followup = [];
  bool loading = true;
//TODO:implement API
  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);
    loading = false;
    if (teleConsulResponse["followup"] == null ||
        !(teleConsulResponse["followup"] is List) ||
        teleConsulResponse["followup"].isEmpty) {
      if (this.mounted) {
        if (this.mounted) {
          setState(() {
            hasfollowup = false;
          });
        }
      }
      return;
    }
    followup = teleConsulResponse["followup"];

    if (this.mounted) {
      if (this.mounted) {
        setState(() {
          hasfollowup = true;
        });
      }
    }
  }

  FollowUpTile getItem(Map map) {
    return FollowUpTile(
      date: map['booked_date_time'].toString(),
      fees: map['consultation_fees'].toString(),
      name: map['consultant_name'].toString(),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: followup.map((e) {
          return getItem(e);
        }).toList(),
      ),
    );
  }
}
