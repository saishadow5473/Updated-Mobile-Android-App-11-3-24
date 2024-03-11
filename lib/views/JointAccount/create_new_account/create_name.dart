import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_email.dart';
import 'package:ihl/widgets/offline_widget.dart';

class CreateName extends StatefulWidget {
  CreateName({Key key, this.title}) : super(key: key);
  // final apirepository = Apirepository();
  final String title;
  @override
  _CreateNameState createState() => _CreateNameState();
}

class _CreateNameState extends State<CreateName> {
  TextEditingController jFnameController = TextEditingController();
  TextEditingController jLnameController = TextEditingController();
  FocusNode jFnameFocusNode;
  FocusNode jLnameFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    _initAsync();
    super.initState();
    jFnameFocusNode = FocusNode();
    jLnameFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (_formKey.currentState.validate()) {
              SpUtil.putString('jFname', jFnameController.text);
              SpUtil.putString('jLname', jLnameController.text);
              Navigator.of(context).pushNamed(Routes.Cdob);
              // Get.to(
              //   CreateEmail(
              //     apiRepository: widget.apirepository,
              //   ),
              // );
            } else {
              if (this.mounted) {
                setState(() {
                  _autoValidate = true;
                });
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF19a9e5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    AppTexts.continuee,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(16),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        top: true,
        child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: OfflineWidget(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 5,
                    child: LinearProgressIndicator(
                      value: 0.125, // percent filled
                      backgroundColor: Color(0xffDBEEFC),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context)
                    .pushNamed(Routes.JointAccount, arguments: false),
                color: Colors.black,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    if (_formKey.currentState.validate()) {
                      SpUtil.putString(SPKeys.jFname, jFnameController.text);
                      SpUtil.putString(SPKeys.jLname, jLnameController.text);
                      // Navigator.of(context).pushNamed(Routes.Cemail);
                      Navigator.of(context).pushNamed(Routes.Cdob);

                      // Get.to(CreateEmail(
                      //   apiRepository: widget.apirepository,
                      // ));
                    } else {
                      if (this.mounted) {
                        setState(() {
                          _autoValidate = true;
                        });
                      }
                    }
                  },
                  child: Text(AppTexts.next,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Color(0xFF19a9e5),
                    ),
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent)),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xffF4F6FA),
            body: Form(
              key: _formKey,
              autovalidateMode:AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      AppTexts.step1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF19a9e5),
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(12),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          height: 1.1),
                    ),
                    SizedBox(
                      height: 2 * SizeConfig.heightMultiplier,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                      child: Text(AppTexts.hello,
                          style: TextStyle(
                              fontSize: ScUtil().setSp(26),
                              fontFamily: 'Poppins',
                              color: Color.fromRGBO(109, 110, 113, 1),
                              fontWeight: FontWeight.bold)),
                    ),
                    // SizedBox(
                    //   height: 1 * SizeConfig.heightMultiplier,
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    //   child: Text(
                    //     AppTexts.sub1,
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //         color: Color.fromRGBO(109, 110, 113, 1),
                    //         fontFamily: 'Poppins',
                    //         fontSize: ScUtil().setSp(15),
                    //         letterSpacing: 0.2,
                    //         fontWeight: FontWeight.normal,
                    //         height: 1),
                    //   ),
                    // ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Text(
                        AppTexts.familysubtxt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(109, 110, 113, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(13),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.normal,
                            height: 1),
                      ),
                    ),
                    SizedBox(
                      height: 6 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Container(
                          child: TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            controller: jFnameController,
                            focusNode: jFnameFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Your First Name';
                              } else if (!(value.length >= 3)) {
                                return "Min. 3 Characters Required";
                              }
                              return null;
                            },
                            autofocus: false,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(jLnameFocusNode);
                            },
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              fontSize: ScUtil().setSp(16),
                            ),
                            decoration: new InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 17.0, horizontal: 15.0),
                                labelText: "First Name",
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(15.0),
                                    borderSide: new BorderSide(
                                        color: Colors.blueGrey))),
                          ),
                        )),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: jLnameController,
                          focusNode: jLnameFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your Last Name!';
                            } else if (!(value.length >= 3)) {
                              return "Min. 3 Characters Required";
                            }
                            return null;
                          },
                          style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                          ),
                          decoration: new InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 17.0, horizontal: 15.0),
                              labelText: "Last Name",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                  borderSide:
                                      new BorderSide(color: Colors.blueGrey))),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Center(
                        child: _customButton(),
                      ),
                    ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
