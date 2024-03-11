import 'package:ihl/constants/api.dart';
import 'package:strings/strings.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:ihl/utils/app_colors.dart';
import 'dart:math';
import 'package:ihl/utils/imageutils.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';

// ignore: must_be_immutable
class TestSelectConsultantCard extends StatefulWidget {
  Function languageFilter;
  bool isAvailable;
  TestSelectConsultantCard({this.languageFilter}) {
    bool rndtf() {
      Random rnd = Random();
      return rnd.nextBool();
    }

    this.isAvailable = rndtf();
  }

  @override
  _TestSelectConsultantCardState createState() =>
      _TestSelectConsultantCardState();
}

class _TestSelectConsultantCardState extends State<TestSelectConsultantCard> {
  String status = 'Unknown';

  bool rndtf() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  Widget banner() {
    Color color = AppColors.primaryAccentColor;
    if (status == 'Online') {
      color = Colors.green;
    }
    if (status == 'Busy') {
      color = Colors.red;
    }
    if (status == 'Offline') {
      color = Colors.grey;
    }
    if (status == 'Unknown') {
      color = Colors.black;
    }
    return Positioned(
      top: -25,
      left: -60,
      child: Transform.rotate(
        angle: -pi / 4,
        child: Container(
          color: color,
          child: SizedBox(
            width: 150,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    camelize(status.toString()),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget badge() {
    if (widget.isAvailable == true) {
      return Positioned(
        right: 0,
        bottom: -5,
        child: FilterChip(
          label: Icon(Icons.check),
          backgroundColor: Colors.green,
          onSelected: (value) {},
          padding: EdgeInsets.all(0),
        ),
      );
    }
    return Positioned(
      right: 0,
      bottom: -5,
      child: FilterChip(
        label: Icon(Icons.close),
        backgroundColor: Colors.red,
        onSelected: (value) {},
      ),
    );
  }

  Widget specialities() {
    return FilterChip(
      label: Text(
        'Diet Consultation',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      padding: EdgeInsets.all(0),
      backgroundColor: AppColors.primaryAccentColor,
      onSelected: (bool value) {},
    );
  }

  Widget languages() {
    return FilterChip(
      label: Text(
        'Hindi',
        style: TextStyle(
          color: AppColors.primaryColor,
        ),
      ),
      padding: EdgeInsets.all(0),
      onSelected: (bool value) {
        widget.languageFilter(e.toString());
      },
    );
  }

  @override
  void initState() {
    subscribe();
    super.initState();
  }

  void subscribe() async {
    final client1 = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
    Session session1;
    try {
      if (session1 != null) {
        session1.close();
      }
      session1 = await client1.connect().first;
      final subscription = await session1.subscribe('telemed:doctor_status');
      subscription.eventStream.listen((event) {
        if (this.mounted) {
          setState(() {
            status = event.arguments[0];
          });
        }
      });
      await subscription.onRevoke.then((reason) =>
          print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      color: AppColors.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: createImage(
                              'https://images.unsplash.com/photo-1582750433449-648ed127bb54?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=334&q=80'),
                          backgroundColor: AppColors.primaryAccentColor,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. Mari Muthu',
                                style: TextStyle(
                                  letterSpacing: 2.0,
                                  color: AppColors.primaryAccentColor,
                                ),
                              ),
                              Text(
                                "Experience: " + '10 Yrs',
                                style: TextStyle(
                                  color: AppColors.lightTextColor,
                                ),
                              ),
                              Text(
                                "Consultation Fees: Rs. " + '500',
                                style: TextStyle(
                                  color: AppColors.lightTextColor,
                                ),
                              ),
                              SmoothStarRating(
                                allowHalfRating: false,
                                onRated: (v) {},
                                starCount: 5,
                                rating: 4,
                                size: 20.0,
                                isReadOnly: true,
                                color: Colors.amberAccent,
                                borderColor: Colors.grey,
                                spacing: 0.0,
                              ),
                              Wrap(
                                direction: Axis.horizontal,
                                children: [specialities()],
                                runSpacing: 0,
                                spacing: 8,
                              ),
                              Wrap(
                                children: [languages()],
                                runSpacing: 0,
                                spacing: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.0,
                ),
              ]),
              banner()
            ],
          ),
        ),
      ),
    );
  }
}
