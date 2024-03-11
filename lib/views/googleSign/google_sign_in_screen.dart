import 'dart:convert';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';

import 'package:flutter/src/painting/text_style.dart' as textStylePack;
import 'package:http/http.dart' as http;

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = new FocusNode();

  GoogleSignInAccount _currentUser;
  String _contactText = '';
  var _googleSignIn;
  var oauth;
  var microSoftUserDetails;
  var microSoftUserProfilePic;
  String signInType = "";
  String companyName = "";
  bool isFetching = false;
  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      // Optional clientId
      // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile'
      ],
    );
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    //########## This Part is for SSO
    final Config config = Config(
      tenant: 'common',
      clientId: 'e61ccb73-be25-4f31-a708-0156bd0dda6d',
      scope: 'User.Read',
      redirectUri: 'https://indiahealthlink.com/',
    );
    oauth = AadOAuth(config);

    _googleSignIn.signInSilently();
  }

  Future<void> _handleMicrosoftSignIn() async {
    setState(() {
      isFetching = true;
    });
    await oauth.logout();
    await oauth.login();
    var token = await oauth.getAccessToken();
    await getMicrosoftAccountDetail(token);
  }

  Future<void> _handleMicrosoftSignOut() async {
    await oauth.logout();
    setState(() {
      microSoftUserDetails = null;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleGoogleSignOut() => _googleSignIn.disconnect();
  Widget _buildBody() {
    final GoogleSignInAccount user = _currentUser;
    if (signInType == "") {
      return Text("Select org");
    } else if (signInType == "google") {
      if (user != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ListTile(
              leading: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0), child: Image.network(user.photoUrl)),
              title: Text(user.displayName ?? ''),
              subtitle: Text(user.email),
            ),
            const Text('Signed in successfully.'),

            ElevatedButton(
              onPressed: _handleGoogleSignOut,
              child: const Text('SIGN OUT Google'),
            ),
            // ElevatedButton(
            //   child: const Text('REFRESH'),
            //   onPressed: () => _handleGetContact(user),
            // ),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text('You are not currently signed in.'),
            SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: Image.asset(
                'assets/images/google.png',
                height: ScUtil().setHeight(30),
                width: ScUtil().setWidth(30),
                fit: BoxFit.cover,
              ),
              label: Text('Sign in using google'),
              style: ElevatedButton.styleFrom(
                  primary: Colors.blue[400],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: textStylePack.TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    } else if (signInType == "microsoft") {
      if (microSoftUserDetails == null || microSoftUserDetails == "") {
        return isFetching
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Text('You are not currently signed in.'),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleMicrosoftSignIn,
                    icon: Image.asset(
                      'assets/images/microsoft.png',
                      height: ScUtil().setHeight(30),
                      width: ScUtil().setWidth(30),
                      fit: BoxFit.cover,
                    ),
                    label: Text('Sign in using microsoft'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue[400],
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        textStyle:
                            textStylePack.TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  )
                ],
              );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ListTile(
              leading: microSoftUserProfilePic != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.memory(microSoftUserProfilePic))
                  : Icon(
                      Icons.account_circle_sharp,
                      size: 50,
                    ),
              title: Text(microSoftUserDetails['givenName'] ?? ''),
              subtitle: Text(microSoftUserDetails['userPrincipalName'] ?? ''),
            ),
            const Text('Signed in successfully.'),

            ElevatedButton(
              onPressed: _handleMicrosoftSignOut,
              child: const Text('SIGN OUT'),
            ),
            // ElevatedButton(
            //   child: const Text('REFRESH'),
            //   onPressed: () => _handleGetContact(user),
            // ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LandingPage()
                //  HomeScreen(
                //       introDone: true,
                //     )
                ),
            (Route<dynamic> route) => false),
        child: Scaffold(
          body: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Search Your organisation",
                    style: textStylePack.TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
                  child: TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                        focusNode: typeAheadFocus,
                        cursorColor: AppColors.primaryAccentColor,
                        controller: this._typeAheadController,
                        decoration: InputDecoration(
                          labelStyle: typeAheadFocus.hasPrimaryFocus
                              ? textStylePack.TextStyle(
                                  color: AppColors.primaryAccentColor,
                                )
                              : textStylePack.TextStyle(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                            ),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                          ),
                          border: new OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                            ),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(30.0),
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: 'Search Your Organisation',
                          prefixIcon: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                            child: Icon(
                              Icons.search,
                              color: AppColors.primaryAccentColor,
                            ),
                          ),
                        )),
                    suggestionsCallback: (pattern) async {
                      return await getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion['company_name']),
                        // subtitle: Text(
                        //     '${suggestion['sign_in_option'] != "" ? suggestion['sign_in_option'] : '-'}'),
                        leading: Icon(
                          suggestion['sign_in_option'] == "microsoft"
                              ? FontAwesomeIcons.microsoft
                              : suggestion['sign_in_option'] == "google"
                                  ? FontAwesomeIcons.google
                                  : FontAwesomeIcons.exclamation,
                          //color: Colors.white,
                        ),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) async {
                      this._typeAheadController.text = suggestion['company_name'];
                      try {
                        setState(() {
                          signInType = suggestion['sign_in_option'];
                          companyName = suggestion['company_name'];
                        });
                      } catch (e) {}
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please type any letter to search';
                      }
                      return null;
                    },
                    noItemsFoundBuilder: (value) {
                      return (_typeAheadController.text == '' ||
                              _typeAheadController.text.length == 0 ||
                              _typeAheadController.text == null)
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'No Results Found',
                                    textAlign: TextAlign.center,
                                    style: textStylePack.TextStyle(
                                        color: AppColors.appTextColor, fontSize: 18.0),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<List> getSuggestions(String query) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    var aff = [];
    List<Map<String, dynamic>> matches = [];
    http.Client _client = http.Client(); //3gb
    final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/consult/list_of_aff_starts_with?search_string=' +
            query +
            '&ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        });
    if (response.statusCode == 200) {
      var text = parseFragment(response.body).text;
      text = parseFragment(text).text; //needed to be done twise to avoid html tags
      // var parse = response.body.replaceAll('&#160;', ' ');
      // var parse1 = parse.replaceAll('(6&quot;)', '');
      // var parse2 = parse1.replaceAll('&amp;', '');

      aff = jsonDecode(text);

      var value = aff;
    }
    print(aff);
    for (int i = 0; i < aff.length; i++) {
      matches.add(aff[i]);
    }
    return matches;
  }

  Future<void> getMicrosoftAccountDetail(String ssoToken) async {
    http.Client _client = http.Client(); //3gb
    final response = await _client.get(Uri.parse('https://graph.microsoft.com/v1.0/me'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + ssoToken,
    });
    if (response.statusCode == 200) {
      var text = parseFragment(response.body).text;
      text = parseFragment(text).text;

      setState(() {
        microSoftUserDetails = json.decode(text);
      });

      final response1 = await _client
          .get(Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + ssoToken,
      });
      if (response1.statusCode == 200) {
        setState(() {
          microSoftUserProfilePic = response1.bodyBytes;
          isFetching = false;
        });
      } else {
        setState(() {
          microSoftUserProfilePic = null;
        });
      }
    } else {
      setState(() {
        microSoftUserDetails = null;
        isFetching = false;
        microSoftUserProfilePic = null;
      });
    }
  }
}
