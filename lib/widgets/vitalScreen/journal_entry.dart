import 'package:ihl/utils/app_colors.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:ihl/models/ecg_calculator.dart';
import 'package:intl/intl.dart';

/// create table of more data
Widget tableBuilder({Map data}) {
  List<DataRow> rows = [];
  data.forEach((k, v) {
    rows.add(
      DataRow(cells: [
        DataCell(
          Text(
            k.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(v.toString()),
        )
      ]),
    );
  });
  return Center(
    child: Row(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                rows: rows,
                columns: [
                  DataColumn(
                    label: Text('More info'),
                  ),
                  DataColumn(
                    label: Text(''),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// single vital entry
class JournalEntry extends StatelessWidget {
  final String icon;
  final DateTime date;
  final String value;
  final String unit;
  final status;
  final statusColor;
  final Map data;
  final ECGCalc ecgGraphData;
  final Function bottom;
  final key = GlobalKey();
  JournalEntry({
    this.value,
    this.date,
    this.icon,
    this.status,
    this.unit,
    this.data,
    this.statusColor,
    this.ecgGraphData,
    this.bottom,
  });
  ExpandableController _controller = ExpandableController();

  @override
  Widget build(BuildContext context) {
    var format = DateFormat('MM/dd/yyyy hh:mm:ss a');
    String dateToShow = 'N/A';
    String valueToShow = value == 'N/A' ? 'N/A' : value + ' ' + unit;
    if (date != null) {
      dateToShow = DateTimeFormat.relative(date) + ' ago';
    }
    return Column(
      children: <Widget>[
        //ignore: missing_required_param
        ExpandablePanel(
          controller: _controller,
          theme: ExpandableThemeData(
            animationDuration: Duration(milliseconds: 50),
            hasIcon: false,
            useInkWell: true,
            tapBodyToCollapse: true,
          ),
          header: ListTile(
            onTap: () {
              _controller.toggle();
              if (_controller.expanded) {
                bottom(200);
              }
            },
            leading: Image.asset(
              icon,
              color: statusColor,
              height: 30,
            ),
            trailing: Text(
              valueToShow,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 20),
            ),
            title: Text(
              dateToShow,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xff6d6e71),
              ),
            ),
          ),
          expanded: Container(
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  DateTimeFormat.format(date.add(Duration(hours: 5, minutes: 30)),
                      format: DateTimeFormats.americanAbbr),
                ),
                Visibility(visible: status != '', child: Text(status)),
                tableBuilder(data: data),
                ecgGraphData == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'View ECG ',
                                style: TextStyle(color: Colors.white),
                              ),
                              Hero(
                                tag: date,
                                child: Icon(
                                  Icons.show_chart,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              'ECG_graph_screen',
                              arguments: {
                                'ecgGraphData': ecgGraphData,
                                'appBarData': {
                                  'color': statusColor,
                                  'value': value,
                                  'status': status,
                                  'date': dateToShow,
                                },
                                'hero': date
                              },
                            );
                          },
                          style: TextButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      )
              ],
            ),
          ),
        ),
        Divider(
          color: AppColors.dividerColor,
          height: 5,
        )
      ],
    );
  }
}
/**
         ListTile(
          onTap: ()=>{},
          leading: Image.asset(icon,
          color: status,),
          trailing: Text(valueToShow,
          style: TextStyle(
            color: status,
            fontWeight: FontWeight.w800,
            fontSize: 20
          ),),
        title: Text(dateToShow,
        style: TextStyle(fontSize: 20),),
        ),

 */
