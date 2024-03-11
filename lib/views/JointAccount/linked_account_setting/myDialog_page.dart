import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';

class MyDialog extends StatefulWidget {
  MyDialog({
    this.access,
    this.selectedAccess,
    this.onSelectedAccessListChanged,
  });

  final List<String> access;
  final List<String> selectedAccess;
  final ValueChanged<List<String>> onSelectedAccessListChanged;

  @override
  MyDialogState createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  List<String> _tempSelectedAccess = [];
  bool isChecking = false;
  @override
  void initState() {
    _tempSelectedAccess = widget.selectedAccess;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  height: ScUtil().setHeight(8.0),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    'Select the Access',
                    style: TextStyle(color: AppColors.primaryColor, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      itemCount: widget.access.length,
                      itemBuilder: (BuildContext context, int index) {
                        final accessType = widget.access[index];
                        return Container(
                          child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              // selectedTileColor: AppColors.primaryColor,
                              // activeColor: Colors.red,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 25,
                              ),
                              title: Text(
                                accessType,
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17),
                              ),
                              // tileColor: AppColors.primaryColor,
                              value: _tempSelectedAccess.contains(accessType),
                              onChanged: (bool value) {
                                if (value) {
                                  if (!_tempSelectedAccess
                                      .contains(accessType)) {
                                    setState(() {
                                      _tempSelectedAccess.add(accessType);
                                    });
                                  }
                                } else {
                                  if (_tempSelectedAccess
                                      .contains(accessType)) {
                                    setState(() {
                                      _tempSelectedAccess.removeWhere(
                                          (String access) =>
                                              access == accessType);
                                    });
                                  }
                                }
                                widget.onSelectedAccessListChanged(
                                    _tempSelectedAccess);
                              }),
                        );
                      }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: AppColors.primaryColor)),
                      ),
                      child: Text(
                        'Go Back',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: isChecking == true
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: AppColors.primaryColor)),
                        primary: AppColors.primaryColor,
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (_tempSelectedAccess.length == 0) {
                          // Text('Please select any one options');
                          Get.snackbar(
                            'Hi',
                            'Please select any options',
                            margin:
                                EdgeInsets.only(top: 20, left: 20, right: 20),
                            backgroundColor: AppColors.primaryAccentColor,
                            colorText: Colors.white,
                            duration: Duration(seconds: 5),
                          );
                        } else {
                          Get.snackbar(
                            'Hi',
                            'Access set Successfully!',
                            margin:
                                EdgeInsets.only(top: 20, left: 20, right: 20),
                            backgroundColor: AppColors.primaryAccentColor,
                            colorText: Colors.white,
                            duration: Duration(seconds: 5),
                          );
                          new Future.delayed(new Duration(seconds: 5), () {
                            Navigator.pop(context);
                          });
                          // Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
