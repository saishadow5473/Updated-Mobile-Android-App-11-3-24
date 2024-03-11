import 'package:flutter/material.dart';

class MaintainWeight extends StatefulWidget {
  @override
  _MaintainWeightState createState() => _MaintainWeightState();
}

class _MaintainWeightState extends State<MaintainWeight> {
  @override
  var sliderValue = 20.0;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.arrow_back_ios_sharp,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Maintain Weight',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,

      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Padding(
      padding: const EdgeInsets.only(left: 40.0, top: 160),
      child: Text(
        'Your Current Weight is',
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
            ),
            Container(
      margin: const EdgeInsets.only(left: 160.0, top: 12),
      padding: const EdgeInsets.only(top:4.0,bottom: 4.0,right: 15,left: 15.0),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black)),
      child: Text(
        '79 Kgs',
        style: TextStyle(fontSize: 15, color: Colors.black),
      ),
            ),

            SizedBox(
      height: 40,
            ),
            Padding(
      padding: const EdgeInsets.only(left: 40.0, top: 80),
      child: Text(
        'It\'okay to estimate you can Update this later',
        style: TextStyle(fontSize: 14, color: Colors.black),
      ),
            ),
            SizedBox(
      height: 40,
            ),
            Container(
              width: 131,
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              margin: EdgeInsets.only(left:200),
              child: Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width:20),
                  Text('Done'),
                ],
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
            ),


            

            
          ],
        ),
    );
  }
}
