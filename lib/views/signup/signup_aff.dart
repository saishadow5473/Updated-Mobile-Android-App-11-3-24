import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/widgets/offline_widget.dart';

final iHLUrl = API.iHLUrl;
final ihlToken = API.ihlToken;

class SignupAff extends StatefulWidget {
  static const id = '/signup_aff';

  @override
  _SignupAffState createState() => _SignupAffState();
}

class _SignupAffState extends State<SignupAff> {
  http.Client _client = http.Client(); //3gb
  String apiToken;
  bool userExistR = false;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  FocusNode emailFocusNode;
  bool emailchar = false;
  bool mobilechar = false;
  final affiliateEmailController = TextEditingController();
  final affiliateMobileController = TextEditingController();
  String userAffiliation;
  bool makeAffiliationAndMobileControllerVisible = false;
  List affiliations = [];
  String affiliationUniqueName;

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    getAffiliateListAPI();
    emailFocusNode = FocusNode();
    _initAsync();
    affiliateEmailController.addListener(() {
      if (this.mounted) {
        setState(() {
          emailchar = affiliateEmailController.text.contains(
              RegExp(
                  "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$"),
              0);
          mobilechar = affiliateMobileController.text
              .contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'));
        });
      }
    });
    affiliateMobileController.addListener(() {
      if (this.mounted) {
        setState(() {
          mobilechar = affiliateMobileController.text
              .contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'));
        });
      }
    });
  }

  Future getAffiliateListAPI() async {
    final response = await _client.get(
      Uri.parse(API.iHLUrl + '/consult/get_list_of_affiliation'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    if (response.statusCode == 200) {
      List companies = json.decode(response.body);
      for (int i = 0; i < companies.length; i++) {
        setState(() {
          affiliations.add(companies[i]['affiliation_unique_name']);
          affiliationUniqueName = companies[i]["company_name"];
        });
      }
    } else {
      print(response.body);
    }
  }

  Widget affiliationField() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColors.appTextColor.withOpacity(0.6),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                hint: Text('Select'),
                value: userAffiliation,
                items: affiliations.map((var value) {
                  return DropdownMenuItem<String>(
                    child: Text(value),
                    value: value,
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    userAffiliation = value;
                    makeAffiliationAndMobileControllerVisible = true;
                  });
                }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
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
                      value: 1.0, // percent filled
                      backgroundColor: Color(0xffDBEEFC),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.Sweight),
                color: Colors.black,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Navigator.of(context).pushNamed(Routes.Spic);
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
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: ScUtil().setSp(16),
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
            extendBodyBehindAppBar: true,
            body: Form(
              key: _formKey,
              autovalidateMode:AutovalidateMode.onUserInteraction,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromRGBO(244, 246, 250, 1),
                      Color.fromRGBO(255, 255, 255, 1)
                    ],
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 8 * SizeConfig.heightMultiplier,
                      ),
                      Text(
                        AppTexts.step9,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(12),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            height: 1.1),
                      ),
                      SizedBox(
                        height: 8 * SizeConfig.heightMultiplier,
                      ),
                      Text(
                        AppTexts.affiliation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(109, 110, 113, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(26),
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            height: 1.33),
                      ),
                      SizedBox(
                        height: 3 * SizeConfig.heightMultiplier,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                        child: Text(
                          AppTexts.sub9,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(109, 110, 113, 1),
                              fontFamily: 'Poppins',
                              fontSize: ScUtil().setSp(15),
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.normal,
                              height: 1.75),
                        ),
                      ),
                      SizedBox(
                        height: 4 * SizeConfig.heightMultiplier,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Container(
                          child: affiliationField(),
                        ),
                      ),
                      SizedBox(
                        height: 4 * SizeConfig.heightMultiplier,
                      ),
                      Visibility(
                        visible: makeAffiliationAndMobileControllerVisible
                            ? true
                            : false,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Container(
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter affiliation Email Id';
                                } else if (!(emailchar) && value.isNotEmpty) {
                                  return "Invalid Email";
                                }
                                return null;
                              },
                              controller: affiliateEmailController,
                              decoration: new InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 8.0),
                                    child: Icon(Icons.email),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 17.0, horizontal: 15.0),
                                  labelText: "Affiliation Email",
                                  fillColor: Colors.white24,
                                  border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(15.0),
                                      borderSide: new BorderSide(
                                          color: Colors.blueGrey))),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 4 * SizeConfig.heightMultiplier,
                      ),
                      Visibility(
                        visible: makeAffiliationAndMobileControllerVisible
                            ? true
                            : false,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Container(
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter affiliation Mobile number';
                                } else if (!(mobilechar) && value.isNotEmpty) {
                                  return "Invalid Mobile";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              controller: affiliateMobileController,
                              decoration: new InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 8.0),
                                    child: Icon(Icons.phone),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 17.0, horizontal: 15.0),
                                  labelText: "Affiliation Mobile",
                                  fillColor: Colors.white24,
                                  border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(15.0),
                                      borderSide: new BorderSide(
                                          color: Colors.blueGrey))),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5 * SizeConfig.heightMultiplier,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                        child: Center(
                          child: Container(
                            height: 60,
                            child: GestureDetector(
                              onTap: () {
                                if (_formKey.currentState.validate()) {
                                  Map affiliationData = {
                                    "affilate_unique_name":
                                        affiliationUniqueName,
                                    "affilate_name": userAffiliation,
                                    "affilate_email":
                                        affiliateEmailController.text,
                                    "affilate_mobile":
                                        affiliateMobileController.text,
                                    "affliate_identifier_id": "DE003"
                                  };
                                  Map affiliateToSend = {
                                    'af_no1': affiliationData
                                  };
                                  SpUtil.putString(
                                      'affiliate', jsonEncode(affiliateToSend));
                                  Navigator.of(context).pushNamed(Routes.Spic);
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
                                        'Continue',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1),
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
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2 * SizeConfig.heightMultiplier,
                      ),
                      RichText(
                          text: TextSpan(
                        text: 'Skip and Continue!',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            SpUtil.putString('affiliate', "none");
                            Navigator.of(context).pushNamed(Routes.Spic);
                          },
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
