import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';

class UserListWithAccess extends StatefulWidget {
  UserListWithAccess({Key key}) : super(key: key);

  @override
  _UserListWithAccessState createState() => _UserListWithAccessState();
}

class _UserListWithAccessState extends State<UserListWithAccess> {
  static get apiRepository => Apirepository();

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  // Read vitals data
// Write vitals data
// Read teleconsultation data
// Write teleconsultation history data.

  Future<void> showPopupMenuDialog(BuildContext context) async {
    bool isChecking = false;
    bool makeValidateVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String reasonRadioBtnVal = "";
        final _formKey = GlobalKey<FormState>();
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
              title: Text(
                'Please select the Access',
                style: TextStyle(color: AppColors.primaryColor),
                textAlign: TextAlign.center,
              ),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Column(
                            children: <Widget>[
                              Row(
                                children: [
                                  new Radio<String>(
                                    value: "Read vitals data",
                                    groupValue: reasonRadioBtnVal,
                                    onChanged: (String value) {
                                      if (this.mounted) {
                                        setState(() {
                                          reasonRadioBtnVal = value;
                                        });
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: new Text(
                                      'Read vitals data',
                                      style: new TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  new Radio<String>(
                                    value: "Write vitals data",
                                    groupValue: reasonRadioBtnVal,
                                    onChanged: (String value) {
                                      if (this.mounted) {
                                        setState(() {
                                          reasonRadioBtnVal = value;
                                        });
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: new Text(
                                      'Write vitals data',
                                      style: new TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  new Radio<String>(
                                    value: 'Read teleconsultation data',
                                    groupValue: reasonRadioBtnVal,
                                    onChanged: (String value) {
                                      if (this.mounted) {
                                        setState(() {
                                          reasonRadioBtnVal = value;
                                        });
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: new Text(
                                      'Read teleconsultation data',
                                      style: new TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  new Radio<String>(
                                    value:
                                        'Write teleconsultation history data',
                                    groupValue: reasonRadioBtnVal,
                                    onChanged: (String value) {
                                      if (this.mounted) {
                                        setState(() {
                                          reasonRadioBtnVal = value;
                                        });
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: new Text(
                                      'Write teleconsultation history data',
                                      style: new TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Visibility(
                            visible: makeValidateVisible ? true : false,
                            child: Text(
                              "Please select the Access",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side:
                                          BorderSide(color: AppColors.primaryColor)),
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: AppColors.primaryColor)),
                                    primary: AppColors.primaryColor,
                                  ),
                                  child: Text(
                                    'Allow Access',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: BasicPageUI(
        appBar: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context)
                    .pushNamed(Routes.Laccountssettings, arguments: false),
                color: Colors.white,
                tooltip: 'Back',
              ),
              centerTitle: true,
              title: Text(
                'User List with Access',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScUtil().setSp(16),
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  // height: MediaQuery.of(context).size.height /
                  //     1.2, // bottom white space fot the teledashboard
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    color: AppColors.cardColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () async {
                        await showPopupMenuDialog(context);
                      },
                      splashColor: Colors.grey.withOpacity(0.5),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: ScUtil().setHeight(3.0),
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(11.0),
                                    height: ScUtil().setHeight(30.0),
                                    width: ScUtil().setWidth(50.0),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.user,
                                    ),
                                  ),
                                  SizedBox(
                                    // width: ScUtil().setWidth(30.0),
                                    width: ScUtil().setWidth(10.0),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Siva Mani',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        //fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ScUtil().setHeight(3.0),
                            ),
                          ]),
                    ),
                  ),
                ),
                Container(
                  // height: MediaQuery.of(context).size.height /
                  //     1.2, // bottom white space fot the teledashboard
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    color: AppColors.cardColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () async {
                        await showPopupMenuDialog(context);
                      },
                      splashColor: Colors.grey.withOpacity(0.5),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: ScUtil().setHeight(3.0),
                            ),
                            Center(
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(11.0),
                                    height: ScUtil().setHeight(30.0),
                                    width: ScUtil().setWidth(50.0),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.user,
                                    ),
                                  ),
                                  SizedBox(
                                    // width: ScUtil().setWidth(30.0),
                                    width: ScUtil().setWidth(10.0),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Priyanka Siva',
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        //fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: ScUtil().setHeight(3.0),
                            ),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
