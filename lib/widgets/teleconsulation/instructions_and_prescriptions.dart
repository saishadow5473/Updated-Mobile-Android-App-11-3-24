import 'package:flutter/material.dart';

class InstructionsAndPrescriptions extends StatelessWidget {
  final medicineName;
  final dosage;
  InstructionsAndPrescriptions({this.medicineName, this.dosage});
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Table(
            children: [
              TableRow(children: [
                Text('Medicine Name', style: TextStyle(height: 2),
                  textAlign: TextAlign.justify,),
                Text('Dosage', style: TextStyle(height: 2),
                  textAlign: TextAlign.justify,),
              ]),
              TableRow(children: [
                Text(medicineName ?? 'N/A', style: TextStyle(height: 2),
                  textAlign: TextAlign.justify,),
                Text(dosage ?? 'N/A', style: TextStyle(height: 2),
                  textAlign: TextAlign.justify,),
              ])
            ],
          )
        ]
    );
  }
}