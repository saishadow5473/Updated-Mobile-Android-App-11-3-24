import 'package:ihl/utils/app_colors.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:ihl/models/ecg_calculator.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:provider/provider.dart';
import 'add_new_dish.dart';
import 'package:ihl/views/dietJournal/add_new_dish.dart';

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
                columns: const [
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

class CalorieJournalEntry extends StatelessWidget {
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
  CalorieJournalEntry({
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
          theme: const ExpandableThemeData(
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
            leading: Icon(
              Icons.local_fire_department,
              size: ScUtil().setSp(30),
              color: statusColor,
            ),
            // Image.asset(
            //   icon,
            //   color: statusColor,
            //   height: 30,
            // ),
            trailing: Text(
              valueToShow,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20),
            ),
            title: Text(
              dateToShow,
              style: const TextStyle(
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
                  DateTimeFormat.format(date, format: DateTimeFormats.american),
                ),
                Text(status),
                tableBuilder(data: data),
                ecgGraphData == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: TextButton(
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
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'View ECG ',
                                style: TextStyle(color: Colors.white),
                              ),
                              Hero(
                                tag: date,
                                child: const Icon(
                                  Icons.show_chart,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
        const Divider(
          color: AppColors.dividerColor,
          height: 5,
        )
      ],
    );
  }
}

class IngredientsJournalEntry extends StatefulWidget {
  final Map data;
  final Function bottom;

  IngredientsJournalEntry({
    this.data,
    this.bottom,
  });

  @override
  _IngredientsJournalEntryState createState() =>
      _IngredientsJournalEntryState();
}

class _IngredientsJournalEntryState extends State<IngredientsJournalEntry> {
  // final key = GlobalKey();

  ExpandableController _controller = ExpandableController();
  Widget tableBuilder1({Map data}) {
    // var d = data;
    // d.removeWhere((key, value) => key == 'item');
    List<DataRow> rows = [];
    data.forEach((k, v) {
      // if(k=='item'){
      //   continue;
      // }
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
                  headingRowHeight: 18,
                  columns: const [
                    DataColumn(
                        label: Icon(
                      Icons.east,
                      color: Colors.transparent,
                      size: 0,
                    )
                        // ingredientsForDish.length>0? 'Nutrition Fact of ${ingredientsForDish[index]} per 1 gram'
                        // ),
                        // ${ingredientsForDish[index]}
                        ),
                    DataColumn(
                        label: Icon(
                      Icons.east,
                      color: Colors.transparent,
                      size: 0,
                    ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //ignore: missing_required_param
        ExpandablePanel(
          controller: _controller,
          theme: const ExpandableThemeData(
            animationDuration: Duration(milliseconds: 50),
            hasIcon: false,
            useInkWell: true,
            tapBodyToCollapse: true,
          ),
          header: ListTile(
            onTap: () {
              _controller.toggle();
              if (_controller.expanded) {
                widget.bottom(200);
              }
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                // widget.data['image']!=null?widget.data['image']
                // :
                "https://www.bakingbusiness.com/ext/resources/2019/1/01142019/Ingredients2019.jpg?1547588432",
                // color: AppColors.dietJournalOrange,
                height: 60,
                width: 60,
              ),
            ),
            trailing: Text(
              widget.data['calorie'] != null
                  ? widget.data['calorie'] + ' cal'
                  : '',
              style: TextStyle(
                  color: AppColors.dietJournalOrange,
                  fontWeight: FontWeight.w800,
                  fontSize: 15),
            ),
            title: Text(
              widget.data['item'] ?? '',
              style: const TextStyle(
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
                Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      // color: Colors.blue,
                      padding: const EdgeInsets.only(top: 30.0, left: 104),
                      child: Text(
                          widget.data.length > 0 ? 'Nutrition Fact ' : ''
                          // DateTimeFormat.format(date, format: DateTimeFormats.american),
                          ),
                    ),
                    Container(
                      // color: Colors.blue,
                      margin: const EdgeInsets.only(
                        left: 69.7,
                        top: 6,
                      ),
                      // padding: EdgeInsets.only(bottom: 10),
                      width: 20.5,
                      height: 20.5,
                      child: RawMaterialButton(
                        onPressed:
                            // true//completed
                            //     ?

                            () async {
                          if (this.mounted) {
                            setState(() {
                              // widget.data.clear();
                              // AddNewDish aa = AddNewDish();

                              for (int i = 0;
                                  i <
                                      Provider.of<listData>(context,
                                              listen: false)
                                          .a
                                          .length;
                                  i++) {
                                if (Provider.of<listData>(context,
                                            listen: false)
                                        .a[i]['item'] ==
                                    widget.data['item']) {
                                  Provider.of<listData>(context, listen: false)
                                      .changeListData(widget.data, 'remove');
                                  // a.removeAt(i);
                                  // a.reversed.toList();

                                  // ingredientsForDish.removeAt(ingredientsForDish.indexOf(a[i]['item']));

                                }
                              }
                            });
                          }
                        },
                        // : () {},
                        elevation: 1.0,
                        fillColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17.0)), //(0xffDBEEFC),
                        child: const Icon(
                          Icons.remove_outlined,
                          size: 17.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                // Text(
                //   DateTimeFormat.format(date, format: DateTimeFormats.american),
                // ),
                // Text(status),
                tableBuilder1(data: widget.data),
                // ecgGraphData == null
                //     ? Container()
                //     : Padding(
                //         padding: const EdgeInsets.only(left: 50, right: 50),
                //         child: TextButton(
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: <Widget>[
                //               Text(
                //                 'View ECG ',
                //                 style: TextStyle(color: Colors.white),
                //               ),
                //               Hero(
                //                 tag: date,
                //                 child: Icon(
                //                   Icons.show_chart,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //             ],
                //           ),
                //           // onPressed: () {
                //           //   Navigator.pushNamed(
                //           //     context,
                //           //     'ECG_graph_screen',
                //           //     arguments: {
                //           //       'ecgGraphData': ecgGraphData,
                //           //       'appBarData': {
                //           //         'color': statusColor,
                //           //         'value': value,
                //           //         'status': status,
                //           //         'date': dateToShow,
                //           //       },
                //           //       'hero': date
                //           //     },
                //           //   );
                //           // },
                //           // color: Colors.blue,
                //         ),
                //       )
              ],
            ),
          ),
        ),

        const Divider(
          color: AppColors.dividerColor,
          height: 5,
        )
      ],
    );
  }
}
