import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:intl/intl.dart';

class YetToArrive extends StatelessWidget {
  final String status;
  final String yetToArriveStatus;
  YetToArrive({Key key, this.status, this.yetToArriveStatus}) : super(key: key);
  DateTime _now;
  bool _showYetToArrive = false;
  DateTime alignDateTime(DateTime dt, Duration alignment, [bool roundUp = false]) {
    assert(alignment >= Duration.zero);
    if (alignment == Duration.zero) return dt;
    final correction = Duration(
        days: 0,
        hours: alignment.inDays > 0
            ? dt.hour
            : alignment.inHours > 0
                ? dt.hour % alignment.inHours
                : 0,
        minutes: alignment.inHours > 0
            ? dt.minute
            : alignment.inMinutes > 0
                ? dt.minute % alignment.inMinutes
                : 0,
        seconds: alignment.inMinutes > 0
            ? dt.second
            : alignment.inSeconds > 0
                ? dt.second % alignment.inSeconds
                : 0,
        milliseconds: alignment.inSeconds > 0
            ? dt.millisecond
            : alignment.inMilliseconds > 0
                ? dt.millisecond % alignment.inMilliseconds
                : 0,
        microseconds: alignment.inMilliseconds > 0 ? dt.microsecond : 0);
    if (correction == Duration.zero) return dt;
    final corrected = dt.subtract(correction);
    final result = roundUp ? corrected.add(alignment) : corrected;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // if (NxtAvailableTxt != '') DateTime _now = DateFormat('HH:mm a').parse(NxtAvailableTxt);

    _now = alignDateTime(DateTime.now(), Duration(minutes: 30));
    DateTime _comeTime = DateTime.now();
    if (yetToArriveStatus.contains('Today')) {
      String _todayDateFormat = DateFormat('yyyy-MM-dd').format(_comeTime);
      String _ComingTime = yetToArriveStatus.replaceAll('Today', '$_todayDateFormat');
      _comeTime = DateFormat('yyyy-MM-dd hh:mm a').parse(_ComingTime);
      print(_comeTime.difference(_now).inMinutes);
      if (_comeTime.difference(_now).inMinutes == 0) {
        print(_comeTime.difference(_now).inMinutes);
        _showYetToArrive = true;
      }
    }

    return Visibility(
      // visible: false,
      visible: status.toLowerCase() == 'offline' && _showYetToArrive,
      child: Text(
        ' Yet to arrive  ',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }
}

class NxtAvailableWidget extends StatelessWidget {
  final String status;
  final String NxtAvailableTxt;
  const NxtAvailableWidget({Key key, this.status, this.NxtAvailableTxt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NxtAvailableTxt.contains('no')
        ? NotAvailableNxtWeektxtWidget(
            NxtAvailableTxt: NxtAvailableTxt,
            status: status,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // color: Colors.red,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Center(
                  child: Visibility(
                    // visible: false,
                    visible:
                        (status.toLowerCase() == 'busy' || status.toLowerCase() == 'offline') &&
                            NxtAvailableTxt != '',
                    child: Text(
                      NxtAvailableTxt.contains('no')
                          ? '            '
                          : status.toLowerCase() == 'busy'
                              ? "Next Available at"
                              : 'Available at  ',
                      style: TextStyle(
                        color: AppColors.lightTextColor.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                // color: red,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                width: MediaQuery.of(context).size.width * 0.45,
                child: Visibility(
                  // visible: false,
                  visible: (status.toLowerCase() == 'busy' || status.toLowerCase() == 'offline') &&
                      NxtAvailableTxt != '',
                  child: Card(
                    color: AppColors.primaryAccentColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      child: Text(
                        !NxtAvailableTxt.contains('no') ? NxtAvailableTxt : NxtAvailableTxt,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}

class NotAvailableNxtWeektxtWidget extends StatelessWidget {
  final String status;
  final String NxtAvailableTxt;
  const NotAvailableNxtWeektxtWidget({Key key, this.status, this.NxtAvailableTxt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // color: Colors.red,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Center(
            child: Visibility(
              // visible: false,
              visible: (status.toLowerCase() == 'busy' || status.toLowerCase() == 'offline') &&
                  NxtAvailableTxt != '',
              child: Text(
                NxtAvailableTxt.contains('no')
                    ? 'No slot available in next 7 days  '
                    : 'No slot available in next 7 days  ',
                style: TextStyle(
                  color: AppColors.lightTextColor.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
