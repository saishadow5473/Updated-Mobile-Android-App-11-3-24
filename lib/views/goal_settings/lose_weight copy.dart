import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/home_screen.dart';

class LoseWeightScreen extends StatefulWidget {
  const LoseWeightScreen({Key key}) : super(key: key);

  @override
  _LoseWeightScreenState createState() => _LoseWeightScreenState();
}

class _LoseWeightScreenState extends State<LoseWeightScreen> {
  TextEditingController currentWeightController = TextEditingController(text: '80.00');
  TextEditingController targetWeightController = TextEditingController(text: '70.00');
  final key = new GlobalKey();
  double goalDuration = 0.5;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.back();
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Container(
              color: AppColors.bgColorTab,
              child: CustomPaint(
                painter: BackgroundPainter(
                    primary: Colors.green.withOpacity(0.8), secondary: Colors.green),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 40,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.network(
                                'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back_ios),
                                      color: Colors.white,
                                      onPressed: () => Get.back(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScUtil().setWidth(40),
                                  ),
                                ],
                              ),
                              Container(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 35),
                        child: Text(
                          'Set Your Goal',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.white, fontSize: 32.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        side: BorderSide(width: 5, color: Color(0xfff4f6fa))),
                                    child: Container(
                                      height: 100,
                                      width: 320,
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xfff4f6fa),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.green,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_circle_down,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Great choice! You've opted to lose weight.",
                                                  style: TextStyle(
                                                    color: Color(0xff2d3142),
                                                    fontSize: ScUtil().setSp(14),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "We're excited to witness your transformation.",
                                                  style: TextStyle(
                                                    color: Color(0xff4c5980),
                                                    fontSize: ScUtil().setSp(11),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 25),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Your current weight',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 160,
                                          margin: EdgeInsets.only(left: 25),
                                          child: TextField(
                                            controller: currentWeightController,
                                            cursorColor: Colors.green,
                                            decoration: InputDecoration(
                                              suffixIcon: Padding(
                                                padding: const EdgeInsets.only(top: 13.0),
                                                child: Text(
                                                  'Kgs',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              counterText: '',
                                              counterStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 0,
                                              ),
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.green),
                                              ),
                                              focusColor: Colors.green,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.green),
                                              ),
                                            ),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textInputAction: TextInputAction.next,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Tooltip(
                                          key: key,
                                          child: IconButton(
                                            icon: Icon(Icons.info),
                                            onPressed: () {
                                              final dynamic tooltip = key.currentState;
                                              tooltip.ensureTooltipVisible();
                                            },
                                          ),
                                          message:
                                              'Your Current weight displayed here based on your '
                                              'last updated weight. In case, you '
                                              'know your most recent weight, you can enter.',
                                          padding: EdgeInsets.all(20),
                                          margin: EdgeInsets.all(20),
                                          showDuration: Duration(seconds: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.9),
                                            borderRadius:
                                                const BorderRadius.all(Radius.circular(4)),
                                          ),
                                          textStyle: TextStyle(color: Colors.white),
                                          preferBelow: true,
                                          verticalOffset: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 25),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Your target weight',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      width: 160,
                                      margin: EdgeInsets.only(left: 25),
                                      child: TextField(
                                        controller: targetWeightController,
                                        cursorColor: Colors.green,
                                        decoration: InputDecoration(
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(top: 6.0),
                                            child: Text(
                                              'Kgs',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          counterText: '',
                                          counterStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 0,
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.green),
                                          ),
                                          focusColor: Colors.green,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.green),
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 25),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Choose your pace',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    '$goalDuration kg / week',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (goalDuration < 0.7 && goalDuration > 0.3)
                                        ? 'Recommended'
                                        : (goalDuration >= 0.7)
                                            ? 'Strict'
                                            : 'Relaxed',
                                    style: TextStyle(
                                      color: (goalDuration < 0.7 && goalDuration > 0.3)
                                          ? Colors.green
                                          : Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.green,
                                      thumbColor: Colors.green,
                                      inactiveTrackColor: Colors.green.withOpacity(0.4),
                                    ),
                                    child: Slider(
                                      min: 0.1,
                                      max: 1.0,
                                      divisions: 10,
                                      value: goalDuration,
                                      onChanged: (value) {
                                        setState(() {
                                          goalDuration = value.toPrecision(1);
                                        });
                                      },
                                    ),
                                  ),
                                  Visibility(
                                    visible: (goalDuration < 0.7 && goalDuration > 0.3),
                                    replacement: Container(),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'We suggest this pace for a lasting weight loss success.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 120)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: Colors.green,
              label: Text('Continue', style: TextStyle(fontWeight: FontWeight.w600)),
              icon: Icon(Icons.check_circle_outline_rounded)),
        ),
      ),
    );
  }
}
