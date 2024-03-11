import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:intl/intl.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../../new_design/presentation/pages/basicData/screens/ProfileCompletion.dart';
import '../../tabs/profiletab.dart';
import '../../views/teleconsultation/viewallneeds.dart';

/// Select Appointment Slot 👀👀
class SelectAppSlot extends StatefulWidget {
  final String companyName;
  final affiliationPrice;
  final List next30;
  final Map consultant;
  final isFetching;

  SelectAppSlot(
      {@required this.next30,
      this.consultant,
      this.companyName,
      this.affiliationPrice,
      this.isFetching});

  @override
  _SelectAppSlotState createState() => _SelectAppSlotState();
}

class _SelectAppSlotState extends State<SelectAppSlot> {
  Map selectedDate = {'': []};
  List _selectedDate = [];
  String selectedTime = '';
  final double buttonSize = 120.0;
  ScrollController _controller;
  bool makeSlotsVisible = false;
  bool isToday = true;
  int _selectedSlot = 0;

  TimeOfDay timeConvert(String normTime) {
    int hour;
    int minute;
    DateTime convertedTime = DateFormat.jm().parse(normTime);
    hour = convertedTime.hour;
    minute = convertedTime.minute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget timeButton(String time) {
    TimeOfDay tt = timeConvert(time);

    TimeOfDay t = TimeOfDay.now();
    final now = new DateTime.now();
    DateTime nowTime = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    DateTime fromAPI = DateTime(now.year, now.month, now.day, tt.hour, tt.minute);

    if (fromAPI.isAfter(nowTime)) {
      if (this.mounted) {
        setState(() {
          makeSlotsVisible = true;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          makeSlotsVisible = false;
        });
      }
    }
    //condition to check selected date is today or not
    if (isToday == true) {
      // condition to check slot time is expired
      if (makeSlotsVisible == true) {
        if (time == selectedTime) {
          return ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
            ),
            child: Text(time.toString(), style: TextStyle(fontSize: 14)),
          );
        }
        return ElevatedButton(
          onPressed: () {
            if (this.mounted) {
              setState(() {
                selectedTime = time.toString();
              });
            }
          },
          style: ElevatedButton.styleFrom(
            primary: AppColors.primaryAccentColor,
          ),
          child: Text(time.toString(), style: TextStyle(fontSize: 14)),
        );
      }
      return SizedBox(
        height: 0,
        width: 0,
      );
    } else {
      if (time == selectedTime) {
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
          ),
          child: Text(time.toString(), style: TextStyle(fontSize: 14)),
        );
      }
      return ElevatedButton(
        onPressed: () {
          if (this.mounted) {
            setState(() {
              selectedTime = time.toString();
            });
          }
        },
        style: ElevatedButton.styleFrom(
          primary: AppColors.primaryAccentColor,
        ),
        child: Text(time.toString(), style: TextStyle(fontSize: 14)),
      );
    }
  }

  IconData getIcon(String string) {
    if (string == 'morning') {
      return FontAwesomeIcons.cloudSun;
    }
    if (string == 'afternoon') {
      return FontAwesomeIcons.sun;
    }
    if (string == 'evening') {
      return FontAwesomeIcons.moon;
    }
    if (string == 'night') {
      return FontAwesomeIcons.cloudMoon;
    }
    return FontAwesomeIcons.briefcaseMedical;
  }

  Widget getEachTime(List list, String string) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              getIcon(string),
              size: 25.0,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                camelize(string),
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.0,
        ),
        Wrap(
          runAlignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          children: list.map((e) => timeButton(e)).toList(),
        ),
        Divider(
          thickness: 2.0,
          height: 30.0,
          indent: 5.0,
        ),
      ],
    );
  }

  int nextAvailable(List list) {
    if (list == null) {
      return 0;
    }
    for (int i = 0; i < list.length; i++) {
      if (list[i].values.first != [] &&
          list[i].values.first != null &&
          list[i].values.first.isNotEmpty) {
        return i;
      }
    }
    return 0;
  }

  Map getTimeMapList(List times) {
    Map toSend = {};
    times.forEach((element) {
      toSend[timings(element)] ??= [];
      toSend[timings(element)].add(element);
    });
    // torearrange in M A E N
    Map temp = {};
    if (toSend.containsKey("morning")) {
      temp['morning'] = toSend['morning'];
    }
    if (toSend.containsKey("afternoon")) {
      temp['afternoon'] = toSend['afternoon'];
    }
    if (toSend.containsKey("evening")) {
      temp['evening'] = toSend['evening'];
    }
    if (toSend.containsKey("night")) {
      temp['night'] = toSend['night'];
    }
    toSend = temp;
    return toSend;
  }

  Widget makeList(Map map) {
    return Container(
      child: Column(
        children: map.keys.map((e) => getEachTime(map[e], e.toString())).toList(),
      ),
    );
  }

  Widget getDateButton(Map e, int index) {
    // print(e);
    int _slot = 0;
    String _mor = 'morning', _aft = 'afternoon', _eve = 'evening', _nig = 'night';
    final _now = DateTime.now();
    TimeOfDay t = TimeOfDay.now();
    DateTime nowTime = DateTime(_now.year, _now.month, _now.day, t.hour, t.minute);

    for (var key in e.keys) {
      if (key == 'today') {
        e[key][0][_mor].forEach((time) {
          TimeOfDay tt = timeConvert(time);
          DateTime fromAPI = DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
          if (fromAPI.isAfter(nowTime)) {
            _slot++;
          }
        });
        // if (_now.hour < 12) _slot += e[key][0][_mor].length;
      } else {
        _slot += e[key][0][_mor].length;
      }
      if (key == 'today') {
        e[key][0][_aft].forEach((time) {
          TimeOfDay tt = timeConvert(time);
          DateTime fromAPI = DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
          if (fromAPI.isAfter(nowTime)) {
            _slot++;
          }
        });
        // if (_now.hour >= 12 && _now.hour < 17) _slot += e[key][0][_aft].length;
      } else {
        print('Not Today');
        _slot += e[key][0][_aft].length;
      }
      // _tempList.add(e[key][0][_aft]);
      if (key == 'today') {
        e[key][0][_eve].forEach((time) {
          TimeOfDay tt = timeConvert(time);
          DateTime fromAPI = DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
          if (fromAPI.isAfter(nowTime)) {
            _slot++;
          }
        });
        // if (_now.hour >= 17 && _now.hour < 20) _slot += e[key][0][_eve].length;
      } else {
        print('Not Today');
        _slot += e[key][0][_eve].length;
      }
      if (key == 'today') {
        e[key][0][_nig].forEach((time) {
          TimeOfDay tt = timeConvert(time);
          DateTime fromAPI = DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
          if (fromAPI.isAfter(nowTime)) {
            _slot++;
          }
        });
      } else {
        _slot += e[key][0][_nig].length;
      }

      // _tempList.add(e[key][0][_eve]);

      // _tempList.add(e[key][0][_nig]);
    }

    // print('Data ${e[_tem]}');
    // eDateSlot.forEach((element) => print('Today $element'));
    // e[0].forEach((element) {
    //   Map ele = element;
    //   print(ele);
    // });
    List _list = [];

    if (_selectedSlot == index) {
      selectedDate = e;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 3),
            side: BorderSide(
                color: _slot == 0 ? Colors.grey[300] : AppColors.primaryAccentColor, width: 3.0),
            backgroundColor: _slot == 0 ? Colors.white : AppColors.primaryAccentColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.keys.first.toString(),
                style: TextStyle(color: Colors.white),
              ),
              Text(
                //e.values.toList()[0].length.toString()
                '$_slot slots available',
                style: TextStyle(color: Colors.green[100]),
              ),
            ],
          ),
          onPressed: _slot == 0
              ? null
              : () {
                  e[e.keys.first][0][_mor].forEach((ek) => _list.add(ek));
                  e[e.keys.first][0][_aft].forEach((ek) => _list.add(ek));
                  e[e.keys.first][0][_eve].forEach((ek) => _list.add(ek));
                  e[e.keys.first][0][_nig].forEach((ek) => _list.add(ek));
                  if (this.mounted) {
                    setState(() {
                      _selectedSlot = index;
                      print(_selectedSlot);
                      // condition to check selected day is today or not
                      if (e.keys.first.toString() == 'today' ||
                          e.keys.first.toString() == 'Today') {
                        isToday = true;
                      } else {
                        isToday = false;
                      }
                      // _selectedDate = _tempList;
                      _selectedDate = _list;
                      selectedTime = '';
                    });
                  }
                },
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: Colors.white,
            padding: EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 3),
            side: const BorderSide(color: AppColors.primaryAccentColor, width: 3.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.keys.first.toString()),
            Text(
              '$_slot slots available',
              style: TextStyle(
                  color: _slot == 0
                      ? Colors.grey
                      : _selectedSlot == index
                          ? AppColors.primaryColor
                          : Colors.green),
            ),
          ],
        ),
        onPressed: _slot == 0
            ? null
            : () {
                e[e.keys.first][0][_mor].forEach((ek) => _list.add(ek));
                e[e.keys.first][0][_aft].forEach((ek) => _list.add(ek));
                e[e.keys.first][0][_eve].forEach((ek) => _list.add(ek));
                e[e.keys.first][0][_nig].forEach((ek) => _list.add(ek));
                if (this.mounted) {
                  setState(() {
                    _selectedSlot = index;
                    print(_selectedSlot);
                    // condition to check selected day is today or not
                    selectedDate = e;
                    if (e.keys.first.toString() == 'today' || e.keys.first.toString() == 'Today') {
                      isToday = true;
                    } else {
                      isToday = false;
                    }
                    // _selectedDate = _tempList;
                    _selectedDate = _list;
                    selectedTime = '';
                  });
                }
                selectedDate = e;
              },
      ),
    );
  }

  //Condition to place the slots on Morning , Afternoon ,evening and night based their time
  String timings(String time) {
    DateTime convertedTime1 = DateFormat.jm().parse(time);
    int convertedTime2 = convertedTime1.hour;
    if (convertedTime2 < 12) {
      return 'morning';
    } else if (convertedTime2 < 17) {
      return 'afternoon';
    } else if (convertedTime2 < 21) {
      return 'evening';
    }
    return 'night';
  }

  Map dataToSend() {
    //Change to check genix
    //widget.consultant["consultation_fees"] = 100;
    widget.consultant["livecall"] = false;
    return {
      'date': selectedDate.keys.first,
      'time': selectedTime,
      'doctor': widget.consultant,
      'affiliationPrice': widget.companyName != "none" ? widget.affiliationPrice.toString() : 'none'
    };
  }

  @override
  void initState() {
    super.initState();
    int ini = nextAvailable(widget.next30);
    if (widget.next30 != null && widget.next30.isNotEmpty) {
      selectedDate = widget.next30[ini];
      _controller = ScrollController(initialScrollOffset: (ini * buttonSize) - 50);
    }
  }

  bool firstLoading = true;

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    if (widget.isFetching == false) {
      return Card(
        // elevation: 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Color(0xfff4f6fa),
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        // color: Color(0xfff4f6fa),
        color: FitnessAppTheme.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: Column(
            children: [
              CircularProgressIndicator(),
              // Text("Please wait while we are fetching"),
              // Text("We are fetching"),
              // Text("the available slots!"),
            ],
          )),
        ),
      );
    } else if (widget.next30 == null || widget.next30.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Color(0xfff4f6fa),
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        // color: Color(0xfff4f6fa),
        color: FitnessAppTheme.white,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(15.0),
        // ),
        // color: Color(0xfff4f6fa),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: Column(
            children: [
              Icon(FontAwesomeIcons.info),
              Text("No slots available "),
            ],
          )),
        ),
      );
    }
    if (firstLoading && mounted) {
      firstLoading = false;
      var e = widget.next30[0];
      String _mor = 'morning', _aft = 'afternoon', _eve = 'evening', _nig = 'night';
      var _list = [];
      e[e.keys.first][0][_mor].forEach((ek) => _list.add(ek));
      e[e.keys.first][0][_aft].forEach((ek) => _list.add(ek));
      e[e.keys.first][0][_eve].forEach((ek) => _list.add(ek));
      e[e.keys.first][0][_nig].forEach((ek) => _list.add(ek));
      _selectedDate = _list;
    }
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Color(0xfff4f6fa),
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        // color: Color(0xfff4f6fa),
        color: FitnessAppTheme.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 30.0,
                    color: Colors.blue,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, top: 8.0, bottom: 8.0),
                    child: Text(
                      "Select Appointment Slot",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: ScUtil().setSp(22.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10,
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return getDateButton(widget.next30[index], index);
                  },
                  itemCount: widget.next30.length,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Divider(
                thickness: 2.0,
                height: 30.0,
                indent: 5.0,
              ),
              SizedBox(
                height: 10.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 80,
                      width: MediaQuery.of(context).size.width / 20,
                      decoration: new BoxDecoration(
                        color: AppColors.primaryAccentColor,
                      ),
                    ),
                    Text(
                      ' Available    ',
                      style: TextStyle(fontSize: 8),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 80,
                      width: MediaQuery.of(context).size.width / 20,
                      decoration: new BoxDecoration(
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      ' Slot Selected ',
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
              _selectedDate.isEmpty
                  ? Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text('No slots available for Today'))
                  : makeList(getTimeMapList(_selectedDate)),
              Visibility(
                visible: _selectedDate.isNotEmpty,
                child: SizedBox(
                  height: 20.0,
                ),
              ),
              Visibility(
                visible: _selectedDate.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(selectedTime.isNotEmpty
                      ? selectedDate.keys.first.toString() + ' at ' + selectedTime
                      : ''),
                ),
              ),
              ButtonTheme(
                minWidth: 290.0,
                height: 50.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    primary: AppColors.primaryAccentColor,
                  ),
                  child: Text("Confirm Appointment",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  onPressed: selectedTime.isEmpty
                      ? null
                      : () {
                          PercentageCalculations().calculatePercentageFilled() != 100
                              ? Get.to(ProfileTab(
                                  editing: true,
                                  bacNav: () {
                                    Get.to(ViewallTeleDashboard(
                                      includeHelthEmarket: true,
                                    ));
                                  }))
                              : Navigator.of(context).pushNamed(
                                  Routes.ConfirmVisit,
                                  arguments: dataToSend(),
                                );
                        },
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              //Refund policy
              /*GestureDetector(
                onTap: () => refundDialogBox(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Refund Policy",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  refundDialogBox() {
    _buildChild(BuildContext context) => Container(
          height: MediaQuery.of(context).size.height / 1.25,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            children: <Widget>[
              Container(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Refund Policy",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12), topRight: Radius.circular(12))),
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cancellation Time",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        Text(
                          "Refund",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("x_hours"),
                        Text("_"),
                      ],
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("refund_perenct_\nbefore_x_hours"),
                        Text("50%"),
                      ],
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("refund_perenct_\nafter_x_hours"),
                        Text("30%"),
                      ],
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("refund_perenct_\nfor_customer_noshow"),
                        Text("0%"),
                      ],
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("refund_perenct_for_\nconsultant_cancel_\nbefore_appointment"),
                        Text("100%"),
                      ],
                    ),
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("refund_percent_for_\nconsultant_no_show"),
                        Text("100%"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  primary: AppColors.primaryColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 13.0, bottom: 13.0, right: 15, left: 15),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: _buildChild(context),
          );
        });
  }
}
