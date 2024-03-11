import 'package:intl/intl.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/widgets/profileScreen/dateTimeConvert.dart';

/// not implemented ❕❕❕💢
class DOBField extends StatefulWidget {
  final String date;
  final Function changeDate;
  final num fontS;
  DOBField({Key key, this.date, this.changeDate, this.fontS}) : super(key: key);

  @override
  _DOBFieldState createState() => _DOBFieldState();
}

class _DOBFieldState extends State<DOBField> {
  String dob;
  TextEditingController _controller = TextEditingController();
  @override
  void didUpdateWidget(DOBField oldWidget) {
    super.didUpdateWidget(oldWidget);
    dob = widget.date;
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void changeDate(String d) {
    if (this.mounted) {
      setState(() {
        dob = d;
        widget.changeDate(dob);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dob = widget.date;
    _controller.text = dob;
  }

  String validate() {
    DateFormat ipF = DateFormat("MM/dd/yyyy");
    try {
      DateTime i = ipF.parse(dob);
      if (i == null) {
        return 'Enter Date of birth in mm/dd/yyyy format';
      }
    } catch (e) {
      return 'Enter Date of birth in mm/dd/yyyy format';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.datetime,
      onChanged: (value) {
        changeDate(value);
      },
      decoration: InputDecoration(
        errorText: validate(),
        disabledBorder: InputBorder.none,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryAccentColor,
            width: 2,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        suffix: TextButton(
          child: Icon(Icons.calendar_today),
          style: TextButton.styleFrom(
                            textStyle: TextStyle(color: Colors.white),
                            backgroundColor:AppColors.primaryAccentColor,),
          onPressed: () async {
            DatePicker.showDatePicker(
              context,
              theme: DatePickerTheme(
                itemStyle: TextStyle(
                  color: Colors.black,
                  fontSize: ScUtil().setSp(18),
                ),
                cancelStyle: TextStyle(
                  color: Colors.red,
                  fontSize: ScUtil().setSp(16),
                ),
                doneStyle: TextStyle(
                  fontSize: ScUtil().setSp(16),
                ),
                containerHeight: ScUtil().setHeight(240),
              ),
              showTitleActions: true,
              minTime: DateTime(1900, 1, 1),
              maxTime: DateTime.now().subtract(Duration(days: (365 * 13) + 3)),
              onConfirm: (date) {
                dob = dateTimeToString(date);
                changeDate(dob);
              },
              currentTime: stringToDateTime(dob),
              locale: LocaleType.en,
            );
          },
        ),
        labelStyle: TextStyle(
            color: AppColors.appTextColor.withOpacity(0.6),
            fontSize: widget.fontS,
            fontWeight: FontWeight.normal),
        labelText: 'Date of birth(mm-dd-yyyy)',
      ),
    );
  }
}
