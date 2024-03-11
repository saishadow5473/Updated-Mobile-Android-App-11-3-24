import 'package:flutter/material.dart';

class GainWeight extends StatefulWidget {
  @override
  _GainWeightState createState() => _GainWeightState();
}

class _GainWeightState extends State<GainWeight> {
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
          'Gain Weight',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 30),
              child: Text(
                'Your Current Weight is',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 160.0, top: 12),
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 15, left: 15.0),
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: Text(
                '79 Kgs',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 30),
              child: Text(
                'Your goal Weight is',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            Container(
              width: 80,
              height: 33,
              margin: const EdgeInsets.only(left: 160.0, top: 12),
              // padding: const EdgeInsets.only(right: 8.0,left: 8.0,top:14),
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 30,
                    padding: EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        //   suffixText: 'Kgs',
                        //   suffixStyle: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 0,
                      ),
                    ),
                  ),
                  Text(
                    ' Kgs',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 30),
              child: Text(
                'Weight Management',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Slider(
                max: 100,
                min: 0,
                value: sliderValue,
                onChanged: (v) {
                  if (this.mounted) {
                    setState(() {
                      sliderValue = v;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 0),
              child: Text(
                '12 Weeks',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 0),
              child: Text(
                'gain: 0.5 Kg/Week',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            Container(
              width: 131,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: EdgeInsets.only(left: 200),
              child: Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 20),
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
      ),
    );
  }
}
