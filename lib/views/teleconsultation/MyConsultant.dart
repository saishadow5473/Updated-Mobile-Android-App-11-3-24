import 'package:flutter/material.dart';
import 'package:ihl/views/teleconsultation/myConsultantsTile.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'dart:math';

class MyConsutantScreen extends StatefulWidget {
  @override
  _MyConsutantScreenState createState() => _MyConsutantScreenState();
}

class _MyConsutantScreenState extends State<MyConsutantScreen> {
  List results = [];
  List languageFilters = [];
  @override
  void initState() {
    super.initState();
  }

  bool rndtf() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
      appBar: Column(
        children: [
          SizedBox(
            width: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color: Colors.white,
              ),
              Text(
                'My Consultants',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              SizedBox(
                width: 40,
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MyConsultants(),
      ),
    );
  }
}
