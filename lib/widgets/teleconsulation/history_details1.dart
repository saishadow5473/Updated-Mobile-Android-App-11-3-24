import 'package:flutter/material.dart';

class Details1 extends StatelessWidget {
  final name;
  final type;
  final speciality;
  Details1({this.name, this.type, this.speciality});
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Consultant Name   " + "  :  " + name,
            style: TextStyle(height: 2),
            textAlign: TextAlign.justify,
          ),
          Text(
            "Consultation Type   " + "  :  " + type,
            style: TextStyle(height: 2),
            textAlign: TextAlign.justify,
          ),
          Text(
            "Speciality   " + "  :  " + speciality,
            style: TextStyle(height: 2),
            textAlign: TextAlign.justify,
          )
        ]);
  }
}
