import 'dart:convert';
import 'dart:developer';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../widgets/ssoLoginChange.dart';
import '../../constants/api.dart';
import '../../constants/app_texts.dart';
import '../../constants/routes.dart';
import '../../constants/spKeys.dart';
import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../../repositories/api_register.dart';
import '../../utils/SpUtil.dart';
import '../../utils/app_colors.dart';
import '../../utils/screenutil.dart';
import '../../utils/sizeConfig.dart';
import 'signup_alternate_email.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';

class SsoStartScreen extends StatefulWidget {
  final bool login;

  const SsoStartScreen({Key key, @required this.login}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SsoStartScreenState();
}

class _SsoStartScreenState extends State<SsoStartScreen> {
  final String _authToken =
      "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA==";
  bool isEntered = true;
  bool isChecking = false;
  var _userId;
  bool _ssoLogin = false, _userAccVerify = false, _userAffliation = false;

  // bool isCheckingSso = false;
  final TextEditingController _typeAheadController = TextEditingController();
  String affiUniqName;
  final SuggestionsBoxController _suggsController = SuggestionsBoxController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = FocusNode();
  bool userExistR = false;
  final http.Client _client = http.Client(); //3gb
  GoogleSignInAccount _currentUser;
  final String _contactText = '';
  var _googleSignIn;
  var oauth;
  var microSoftUserDetails;
  var microSoftUserProfilePic;
  String signInType = "";
  String companyName = "";
  bool isFetching = false;
  bool hasOppend = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // _googleSignIn = GoogleSignIn(
    //   // Optional clientId
    //   //hostedDomain: 'indiahealthlink.com',
    //   //clientId: '409462954494-6ua123qfc2gspofj2hmeb69gm2a6d6g1.apps.googleusercontent.com',
    //   scopes: <String>[
    //     'email',
    //     'https://www.googleapis.com/auth/userinfo.email',
    //     'https://www.googleapis.com/auth/userinfo.profile'
    //   ],
    // );
    // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //   setState(() {
    //     _currentUser = account;
    //   });
    //   if (isEntered != true) {
    //     login_init();
    //   } else {
    //     _googleSignIn.disconnect();
    //   }
    // });
    //########## This Part is for SSO
    final Config config = Config(
      tenant: 'common',
      clientId: 'e61ccb73-be25-4f31-a708-0156bd0dda6d',
      scope: 'User.Read',
      redirectUri: 'https://dashboard.indiahealthlink.com/ssoload/',
      navigatorKey: navigatorKey,
    );
    oauth = AadOAuth(config);

    //_googleSignIn.signInSilently();
  }

  Future<void> _handleMicrosoftSignIn() async {
    hasOppend = true;
    setState(() {
      isFetching = true;
    });
    try {
      await oauth.logout();
      await oauth.login();
      var token = await oauth.getAccessToken();
      login(token);
    } catch (e) {
      setState(() {
        isFetching = false;
      });
      showMessageNotVerified();
    }
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
    } catch (e) {
      print(e);
      setState(() {
        isFetching = false;
      });

      showMessageNotVerified();
    }
  }

  Future signInWithGoogle({BuildContext context}) async {
    hasOppend = true;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    setState(() => isFetching = true);
    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showMessageNotVerified();
    }

    FirebaseAuth auth = FirebaseAuth.instance;
    User user;
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
        setState(() {
          isFetching = false;
        });

        showMessageNotVerified();
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        _currentUser = googleSignInAccount;
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential = await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            showMessageNotVerified();
          } else if (e.code == 'invalid-credential') {
            showMessageNotVerified();
          }
        } catch (e) {
          print(e);
          setState(() {
            isFetching = false;
          });

          showMessageNotVerified();
        }
      }
    }
    setState(() {
      _currentUser = _currentUser;
    });
    login_init(_currentUser);
    //return user;
  }

  Future signOutGoogle({BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showMessageNotVerified();
    }
  }

  login_init(userValue) async {
    if (userValue != null) {
      final GoogleSignInAccount userData = userValue;
      GoogleSignInAuthentication ad = await userData.authentication;
      String token = ad.idToken;
      await login(token);
      if (_ssoLogin) {
        Get.to(
          SignupAlternateEmailSso(
            loginSso: true,
            userId: _userId,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount user = _currentUser;
    if (signInType == "") {
      return const SizedBox(); //Text("Not Found");
    } else if (signInType == "google") {
      if (user != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Visibility(
              visible: isFetching,
              child: const ListTile(
                title: LinearProgressIndicator(
                  semanticsLabel: 'Loading...',
                ),
              ),
            ),

            // ListTile(
            //   leading: ClipRRect(
            //       borderRadius: BorderRadius.circular(50.0),
            //       child: Image.network(user.photoUrl)),
            //   title: Text(user.displayName ?? ''),
            //   subtitle: Text(user.email),
            // ),
            // const Text('Signed in successfully.'),
            SizedBox(
              height: ScUtil().setHeight(15),
            ),
            ElevatedButton.icon(
              onPressed: isFetching ? null : signInWithGoogle,
              icon: const Icon(Icons.change_circle_outlined),
              label: Text('Try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19a9e5),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
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
            SizedBox(
              height: ScUtil().setHeight(10),
            ),
            Text('You are not currently signed in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(16),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1)),
            SizedBox(
              height: ScUtil().setHeight(20),
            ),
            ElevatedButton.icon(
              onPressed: signInWithGoogle,
              //onPressed: _handleGoogleSignIn,
              icon: Image.asset(
                'assets/images/google.png',
                height: ScUtil().setHeight(20),
                width: ScUtil().setWidth(25),
                fit: BoxFit.cover,
              ),
              label: Text('Sign in using google',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19a9e5),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    } else if (signInType == "microsoft") {
      if (microSoftUserDetails == null || microSoftUserDetails == "") {
        return isFetching
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: ScUtil().setHeight(10),
                  ),
                  Text('You are not currently signed in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(16),
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.normal,
                          height: 1)),
                  SizedBox(
                    height: ScUtil().setHeight(20),
                  ),
                  ElevatedButton.icon(
                    onPressed: _handleMicrosoftSignIn,
                    icon: Image.asset(
                      'assets/images/microsoft.png',
                      height: ScUtil().setHeight(20),
                      width: ScUtil().setWidth(20),
                      fit: BoxFit.cover,
                    ),
                    label: Text('Sign in using microsoft',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(16),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.normal,
                            height: 1)),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        backgroundColor: const Color(0xFF19a9e5),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        textStyle:
                            TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
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
                  : const Icon(
                      Icons.account_circle_sharp,
                      size: 50,
                    ),
              title: Text(microSoftUserDetails['givenName'] ?? ''),
              subtitle: Text(microSoftUserDetails['userPrincipalName'] ?? ''),
            ),
            //const Text('Signed in successfully.'),
            SizedBox(
              height: ScUtil().setHeight(15),
            ),
            ElevatedButton.icon(
              onPressed: _handleMicrosoftSignOut,
              icon: const Icon(Icons.change_circle_outlined),
              label: Text('Try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19a9e5),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
            ),
            // ElevatedButton(
            //   child: const Text('REFRESH'),
            //   onPressed: () => _handleGetContact(user),
            // ),
          ],
        );
      }
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (isFetching && (hasOppend == false)) {
            Navigator.of(context).pushNamed(Routes.Welcome, arguments: false);
          } else {
            Navigator.pop(context);
          }
          return true;
          // isFetching ? null :
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const SizedBox(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: 0.125, // percent filled
                    backgroundColor: Color(0xffDBEEFC),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (isFetching && (hasOppend == false)) {
                  Navigator.of(context).pushNamed(Routes.Welcome, arguments: false);
                } else {
                  Navigator.pop(context);
                }
                // isFetching
                //     ? null
                //     : Navigator.of(context).pushNamed(Routes.Welcome, arguments: false);
              },
              color: Colors.black,
            ),
            actions: <Widget>[
              Visibility(
                visible: false,
                child: TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                      color: Color(0xFF19a9e5),
                    ),
                    shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
                  ),
                  child: const Text(AppTexts.next,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: ScUtil().setHeight(5)),
                Text(
                  widget.login ? 'STEP 2/2' : AppTexts.step1,
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
                Container(
                  padding: const EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                  child: Text("Select organisation",
                      style: TextStyle(
                          fontSize: ScUtil().setSp(23),
                          fontFamily: 'Poppins',
                          color: const Color.fromRGBO(109, 110, 113, 1),
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 3 * SizeConfig.heightMultiplier,
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                //   child: TypeAheadFormField(
                //     suggestionsBoxController: _suggsController,
                //     hideSuggestionsOnKeyboardHide: false,
                //     textFieldConfiguration: TextFieldConfiguration(
                //         onSubmitted: (value) {
                //           _suggsController.open();
                //         },
                //         focusNode: typeAheadFocus,
                //         cursorColor: AppColors.primaryAccentColor,
                //         controller: this._typeAheadController,
                //         decoration: InputDecoration(
                //           labelStyle: typeAheadFocus.hasPrimaryFocus
                //               ? TextStyle(
                //                   color: AppColors.primaryAccentColor,
                //                 )
                //               : TextStyle(),
                //           focusedBorder: OutlineInputBorder(
                //             borderSide: BorderSide(
                //               color: AppColors.primaryAccentColor,
                //             ),
                //             borderRadius: const BorderRadius.all(
                //               const Radius.circular(10.0),
                //             ),
                //           ),
                //           border: new OutlineInputBorder(
                //             borderSide: BorderSide(
                //               color: AppColors.primaryAccentColor,
                //             ),
                //             borderRadius: const BorderRadius.all(
                //               const Radius.circular(10.0),
                //             ),
                //           ),
                //           floatingLabelBehavior: FloatingLabelBehavior.never,
                //           hintText: 'Enter Your Organisation name',
                //           prefixIcon: Padding(
                //             padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                //             child: Icon(
                //               Icons.search,
                //               color: AppColors.primaryAccentColor,
                //             ),
                //           ),
                //         )),
                //     suggestionsCallback: (pattern) async {
                //       if (pattern == null || pattern == "") {
                //         signInType = "";
                //       } else {
                //         new Future.delayed(Duration(milliseconds: 1000), () {
                //           SystemChannels.textInput.invokeMethod('TextInput.hide');
                //         });
                //       }
                //       return await getSuggestions(pattern);
                //     },
                //     itemBuilder: (context, suggestion) {
                //       return ListTile(
                //         title: Text(suggestion['company_name']),
                //         // subtitle: Text(
                //         //     '${suggestion['sign_in_option'] != "" ? suggestion['sign_in_option'] : '-'}'),
                //         leading: Icon(
                //           suggestion['sign_in_option'] == "microsoft"
                //               ? FontAwesomeIcons.microsoft
                //               : suggestion['sign_in_option'] == "google"
                //                   ? FontAwesomeIcons.google
                //                   : FontAwesomeIcons.exclamation,
                //           //color: Colors.white,
                //         ),
                //       );
                //     },
                //     transitionBuilder: (context, suggestionsBox, controller) {
                //       return suggestionsBox;
                //     },
                //     onSuggestionSelected: (suggestion) async {
                //       this._typeAheadController.text = suggestion['company_name'];
                //       try {
                //         setState(() {
                //           signInType = suggestion['sign_in_option'];
                //           gType = signInType;
                //           companyName = suggestion['company_name'];
                //           isEntered = false;
                //         });
                //       } catch (e) {}
                //     },
                //     validator: (value) {
                //       if (value.isEmpty) {
                //         return 'Please type any letter to search';
                //       }
                //       return null;
                //     },
                //     noItemsFoundBuilder: (value) {
                //       signInType = "";

                //       return (_typeAheadController.text == '' ||
                //               _typeAheadController.text.length == 0 ||
                //               _typeAheadController.text == null)
                //           ? Container()
                //           : Padding(
                //               padding: const EdgeInsets.symmetric(vertical: 8.0),
                //               child: Column(
                //                 mainAxisSize: MainAxisSize.min,
                //                 children: [
                //                   Text(
                //                     'No Results Found!',
                //                     textAlign: TextAlign.center,
                //                     style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
                //                   ),
                //                   SizedBox(
                //                     height: 8 * SizeConfig.heightMultiplier,
                //                   ),
                //                 ],
                //               ),
                //             );
                //     },
                //   ),
                // ),
                // TextField(
                //   controller: searchController,
                //   onChanged: (query) {
                //     getSuggestions(query);
                //   },
                //   decoration: InputDecoration(
                //     hintText: 'Search',
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.only(left: 25.sp, right: 25.sp),
                  child: TextFormField(
                    // enabled: !suggestionSelected,
                    controller: _typeAheadController,
                    onChanged: (String query) async {
                      matche.clear();
                      if (_typeAheadController.text != '') {
                        await getSuggestions(query);
                        // Future.delayed(Duration(milliseconds: 1000), () {
                        //   if (mounted) setState(() {});
                        // });
                      }
                      //
                      // new Future.delayed(Duration(milliseconds: 1000), () {
                      //   SystemChannels.textInput.invokeMethod('TextInput.hide');
                      // });
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryAccentColor,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryAccentColor,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Enter Your Organisation name',
                    ),
                  ),
                ),
                Visibility(
                  visible: (suggestionsAreCreated != null && suggestionsAreCreated == false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No Results Found',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
                        ),
                        SizedBox(
                          height: 8 * SizeConfig.heightMultiplier,
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: !suggestionSelected && matche.isNotEmpty,
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.sp, right: 25.sp),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              // [
                              matche
                                  .map((Map<String, dynamic> e) => Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: InkWell(
                                          onTap: () async {
                                            _typeAheadController.text = e['company_name'];
                                            FocusScope.of(context).unfocus();
                                            try {
                                              affiUniqName = e["affiliation_unique_name"];
                                              UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
                                                "affiliation_unique_name": affiUniqName
                                              };
                                              signInType = e['sign_in_option'];
                                              gType = signInType;
                                              companyName = e['company_name'];
                                              isEntered = false;
                                              suggestionSelected = true;

                                              if (mounted) setState(() {});
                                            } catch (e) {
                                              print(e);
                                            }
                                            matche.clear();
                                          },
                                          child: ListTile(
                                            title: Text(e['company_name']),
                                            // subtitle: Text(
                                            //     '${suggestion['sign_in_option'] != "" ? suggestion['sign_in_option'] : '-'}'),
                                            leading: Icon(
                                              e['sign_in_option'] == "microsoft"
                                                  ? FontAwesomeIcons.microsoft
                                                  : e['sign_in_option'] == "google"
                                                      ? FontAwesomeIcons.google
                                                      : FontAwesomeIcons.exclamation,
                                              //color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                          // ListView.builder(
                          //   itemCount: matches.length,
                          //   itemBuilder: (context, index) {
                          //     return Padding(
                          //       padding: const EdgeInsets.all(20.0),
                          //       child: ListTile(
                          //         title: Text(matches[index]['company_name']),
                          //         // subtitle: Text(
                          //         //     '${suggestion['sign_in_option'] != "" ? suggestion['sign_in_option'] : '-'}'),
                          //         leading: Icon(
                          //           matches[index]['sign_in_option'] == "microsoft"
                          //               ? FontAwesomeIcons.microsoft
                          //               : matches[index]['sign_in_option'] == "google"
                          //                   ? FontAwesomeIcons.google
                          //                   : FontAwesomeIcons.exclamation,
                          //           //color: Colors.white,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                          // ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5 * SizeConfig.heightMultiplier,
                ),
                Visibility(visible: suggestionSelected, child: _buildBody())
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool searchLoad = true;
  List<Map<String, dynamic>> matche = [];
  bool suggestionsAreCreated;
  bool suggestionSelected = false;

  Future<List> getSuggestions(String query) async {
    List<Map<String, dynamic>> matches = [];

    matches = [];
    setState(() {});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    List aff = [];
    http.Client client = http.Client(); //3gb
    final http.Response response = await client.get(
        Uri.parse(
            '${API.iHLUrl}/consult/list_of_aff_starts_with?search_string=$query&ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        });
    if (response.statusCode == 200) {
      String text = parseFragment(response.body).text;
      text = parseFragment(text).text; //needed to be done twise to avoid html tags
      // var parse = response.body.replaceAll('&#160;', ' ');
      // var parse1 = parse.replaceAll('(6&quot;)', '');
      // var parse2 = parse1.replaceAll('&amp;', '');

      aff = jsonDecode(text);

      List value = aff;
    }
    print(aff);
    if (mounted) setState(() {});
    for (int i = 0; i < aff.length; i++) {
      if (aff[i]['sign_in_option'] == "microsoft" || aff[i]['sign_in_option'] == "google") {
        matches.add(aff[i]);
      }
    }
    if (matches.isNotEmpty) {
      suggestionsAreCreated = true;
    } else {
      suggestionsAreCreated = false;
    }
    suggestionSelected = false;
    if (_typeAheadController.text != "") matche = matches.toSet().toList();
    searchLoad = false;
    if (mounted) setState(() {});

    return matches;
  }

  Future<void> getMicrosoftAccountDetail(String ssoToken) async {
    http.Client client = http.Client(); //3gb
    final http.Response response =
        await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $ssoToken',
    });
    if (response.statusCode == 200) {
      String text = parseFragment(response.body).text;
      text = parseFragment(text).text;

      setState(() {
        microSoftUserDetails = json.decode(text);
      });

      final http.Response response1 = await client
          .get(Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $ssoToken',
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

  void logoutSso() async {
    await oauth.logout();
  }

  bool acountExist = true;

  Future login(String ssoToken) async {
    //await oauth.login();
    log('SSO Token$ssoToken');
    String accessToken = ssoToken;
    if (widget.login) {
      SpUtil.putString('sso_token', ssoToken);
      final http.Response response1 = await _client.post(
        Uri.parse('${API.iHLUrl}/sso/login_sso_user_account'),
        headers: {'Content-Type': 'application/json', 'ApiToken': ssoToken},
        body: jsonEncode(<String, String>{'sso_token': ssoToken, "sso_type": signInType}),
      );
      print(response1.body);

      if (response1.statusCode == 200) {
        var res = jsonDecode(response1.body);
        if (res['response'] == 'user_not_exist') {
          print(res['id']);
          SpUtil.putString(SPKeys.sso_token, accessToken);
          // SpUtil.putString(SPKeys.email, res['id']);
          SpUtil.putString(SPKeys.signInType, signInType);

          showMessageVerified();
        }
        if (res['response'] == 'user already has an primary account in this email') {
          _userId = res['id'];
          setState(() => _ssoLogin = true);
        } else if (response1.body == 'null') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', '');
          Get.back();
        } else if (res['response'] == 'exception') {
          showMessageNotVerifiedInLogin();
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', response1.body);
          prefs.setString(SPKeys.is_sso, "true");
          //prefs.setString('email', email);
          var decodedResponse = jsonDecode(response1.body);
          UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
            "affiliation_unique_name": affiUniqName
          };
          String iHLUserToken = decodedResponse['Token'];
          String iHLUserId = decodedResponse['User']['id'];
          localSotrage.write(LSKeys.ihlUserId, iHLUserId);
          String userEmail = decodedResponse['User']['email'];
          prefs.setString('email', userEmail);
          localSotrage.write(LSKeys.email, userEmail);
          bool introDone = decodedResponse['User']['introDone'] ?? false;
          API.headerr = {};
          prefs.setString('auth_token',
              "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA==");
          API.headerr['Token'] = iHLUserToken;
          API.headerr['ApiToken'] =
              "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA==";
          print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${API.headerr}");
          localSotrage.write(LSKeys.logged, true);
          await MyvitalsApi().vitalDatas(json.decode(response1.body));
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          prefs1.setString("ihlUserId", iHLUserId);
          final http.Response getPlatformData = await _client.post(
            Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: jsonEncode(<String, dynamic>{"ihl_id": iHLUserId, 'cache': "true"}),
          );
          if (getPlatformData.statusCode == 200) {
            final SharedPreferences platformData = await SharedPreferences.getInstance();
            platformData.setString(SPKeys.platformData, getPlatformData.body);
          }
          final http.Response vitalData = await _client.get(
            Uri.parse('${API.iHLUrl}/data/user/$iHLUserId/checkin'),
            headers: {
              'Content-Type': 'application/json',
              'Token': iHLUserToken,
              'ApiToken': _authToken
            },
          );
          Map<String, dynamic> userAffiliationDetail;

          Object userData = prefs.get(SPKeys.userData);
          Map userDecodeData = jsonDecode(userData);
          final http.Response affiliationDetails = await _client.post(
            Uri.parse("${API.iHLUrl}/sso/affiliation_details"),
            body: jsonEncode(<String, String>{'email': prefs.get(SPKeys.email)}),
          );
          if (affiliationDetails.statusCode == 200) {
            var tokenParse = jsonDecode(affiliationDetails.body);
            userAffiliationDetail = {
              "company_name": tokenParse['response']['company_name'],
              "affiliation_unique_name": tokenParse['response']['affiliation_unique_name']
            };
          }

          http.Response userAffiliationDetailCheck = await _client.post(
              Uri.parse(
                '${API.iHLUrl}/login/get_user_login',
              ),
              body: jsonEncode(
                <String, dynamic>{
                  "id": iHLUserId,
                },
              ),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    '69/G9PN0M1Y/ZxC9LMG4c+2qFCg+6Qfye8ci7XV53egWzXaBapR3LAVWzBX5+js5Q/Oy4CDOR/x24C/6gT5N/G98x8xd4GtBmbWNRE1YF1cBAA==',
              });
          if (userAffiliationDetailCheck.statusCode == 200) {
            var finalResponse = json.decode(userAffiliationDetailCheck.body);
            final vitalDatas = await SplashScreenApiCalls()
                .checkinData(ihlUID: iHLUserId, ihlUserToken: iHLUserToken);
            prefs1.setString(SPKeys.vitalsData, vitalDatas);
            await MyvitalsApi().vitalDatas(finalResponse);
            if (iHLUserId == finalResponse['User']['id']) {
              API.headerr['ApiToken'] =
                  '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
              API.headerr['Token'] = finalResponse['Token'];
              _userAccVerify = true;
              Map userMap = finalResponse['User'];
              bool affiliationAdded = false;
              if (userMap.containsKey('user_affiliate')) {
                Map userMapAffiliate = finalResponse['User']['user_affiliate'];

                for (int count = 1; count <= 9; count++) {
                  if (userMapAffiliate.containsKey('af_no$count')) {
                    var affiliateData = userMapAffiliate['af_no$count'];

                    if (affiliateData['affilate_unique_name'] == null ||
                        affiliateData['affilate_unique_name'] == '' &&
                            affiliateData['affilate_name'] == null ||
                        affiliateData['affilate_name'] == '') {
                      final http.Response updateProfile =
                          await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": iHLUserId,
                                "user_affiliate": {
                                  "af_no$count": {
                                    "affilate_unique_name":
                                        userAffiliationDetail['affiliation_unique_name'],
                                    "affilate_name": userAffiliationDetail['company_name'],
                                    "affilate_email": prefs.get(SPKeys.email),
                                    "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                    "affliate_identifier_id": "",
                                    "is_sso": true,
                                  }
                                }
                              }));
                      print(updateProfile.body);

                      if (updateProfile.statusCode == 200) {
                        final http.Response ssoCount = await _client.post(
                            Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, dynamic>{
                              "email": prefs.get(SPKeys.email),
                              "affiliation_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "mobileNumber": userDecodeData['User']['mobileNumber'],
                              "company_name": userAffiliationDetail['company_name'],
                              "firstName": userDecodeData['User']['firstName'],
                              "lastName": userDecodeData['User']['lastName'],
                              "ihl_user_id": iHLUserId,
                            }));
                        if (ssoCount.statusCode == 200) {
                          print('Count Added');
                        }
                        _userAffliation = true;

                        break;
                      } else {
                        _userAffliation = true;
                      }
                    } else {
                      if (affiliateData['affilate_unique_name'] ==
                              userAffiliationDetail['affiliation_unique_name'] &&
                          affiliateData['affilate_name'] == userAffiliationDetail['company_name']) {
                        if (affiliateData['affilate_email'] == prefs.get(SPKeys.email) &&
                            affiliateData['is_sso'] == true) {
                          break;
                        } else {
                          final http.Response updateProfile =
                              await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'ApiToken': API.headerr['ApiToken'],
                                    'Token': API.headerr['Token']
                                  },
                                  body: jsonEncode(<String, dynamic>{
                                    "id": iHLUserId,
                                    "user_affiliate": {
                                      "af_no$count": {
                                        "affilate_unique_name":
                                            userAffiliationDetail['affiliation_unique_name'],
                                        "affilate_name": userAffiliationDetail['company_name'],
                                        "affilate_email": prefs.get(SPKeys.email),
                                        "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                        "affliate_identifier_id": "",
                                        "is_sso": true,
                                      }
                                    }
                                  }));
                          print(updateProfile.body);

                          if (updateProfile.statusCode == 200) {
                            final http.Response ssoCount = await _client.post(
                                Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode(<String, dynamic>{
                                  "email": prefs.get(SPKeys.email),
                                  "affiliation_unique_name":
                                      userAffiliationDetail['affiliation_unique_name'],
                                  "mobileNumber": userDecodeData['User']['mobileNumber'],
                                  "company_name": userAffiliationDetail['company_name'],
                                  "firstName": userDecodeData['User']['firstName'],
                                  "lastName": userDecodeData['User']['lastName'],
                                  "ihl_user_id": iHLUserId,
                                }));
                            if (ssoCount.statusCode == 200) {
                              print('Count Added');
                            }
                            _userAffliation = true;

                            break;
                          } else {
                            _userAffliation = true;
                          }
                        }
                        print('Same');
                        break;
                      }
                    }
                  } else {
                    if (affiliationAdded == false) {
                      final http.Response updateProfile =
                          await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": iHLUserId,
                                "user_affiliate": {
                                  "af_no$count": {
                                    "affilate_unique_name":
                                        userAffiliationDetail['affiliation_unique_name'],
                                    "affilate_name": userAffiliationDetail['company_name'],
                                    "affilate_email": prefs.get(SPKeys.email),
                                    "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                    "affliate_identifier_id": "",
                                    "is_sso": true,
                                  }
                                }
                              }));
                      print(updateProfile.body);

                      if (updateProfile.statusCode == 200) {
                        final http.Response ssoCount = await _client.post(
                            Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, dynamic>{
                              "email": prefs.get(SPKeys.email),
                              "affiliation_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "mobileNumber": userDecodeData['User']['mobileNumber'],
                              "company_name": userAffiliationDetail['company_name'],
                              "firstName": userDecodeData['User']['firstName'],
                              "lastName": userDecodeData['User']['lastName'],
                              "ihl_user_id": iHLUserId,
                            }));
                        if (ssoCount.statusCode == 200) {
                          print('Count Added');
                        }
                        affiliationAdded = true;

                        print(updateProfile.body);
                        _userAffliation = true;
                      } else {
                        _userAffliation = true;
                      }
                    }
                    break;
                  }
                }

                print('Already');
              } else {
                final http.Response updateProfile =
                    await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                        headers: {
                          'Content-Type': 'application/json',
                          'ApiToken': API.headerr['ApiToken'],
                          'Token': API.headerr['Token']
                        },
                        body: jsonEncode(<String, dynamic>{
                          "id": iHLUserId,
                          "user_affiliate": {
                            "af_no1": {
                              "affilate_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "affilate_name": userAffiliationDetail['company_name'],
                              "affilate_email": prefs.get(SPKeys.email),
                              "affilate_mobile": userDecodeData['User']['mobileNumber'],
                              "affliate_identifier_id": "",
                              "is_sso": true,
                            }
                          }
                        }));
                print(updateProfile.body);

                if (updateProfile.statusCode == 200) {
                  final http.Response ssoCount =
                      await _client.post(Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                          headers: {
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(<String, dynamic>{
                            "email": prefs.get(SPKeys.email),
                            "affiliation_unique_name":
                                userAffiliationDetail['affiliation_unique_name'],
                            "mobileNumber": userDecodeData['User']['mobileNumber'],
                            "company_name": userAffiliationDetail['company_name'],
                            "firstName": userDecodeData['User']['firstName'],
                            "lastName": userDecodeData['User']['lastName'],
                            "ihl_user_id": iHLUserId,
                          }));
                  if (ssoCount.statusCode == 200) {
                    print('Count Added');
                  }
                  affiliationAdded = true;

                  print(updateProfile.body);
                  _userAffliation = true;
                } else {
                  _userAffliation = true;
                }
              }
            } else {
              _userAccVerify = false;
            }
          } else {
            _userAccVerify = false;
          }

          if (vitalData.statusCode == 200) {
            final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
            sharedUserVitalData.setString(SPKeys.vitalsData, vitalData.body);

            prefs.setString('disclaimer', 'no');
            prefs.setString('refund', 'no');
            prefs.setString('terms', 'no');
            prefs.setString('grievance', 'no');
            prefs.setString('privacy', 'no');
          }
          if (mounted) {
            setState(() {
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => HomeScreen(
              //               introDone: introDone,
              //             )),
              //     (Route<dynamic> route) => false);
              Get.offAll(LandingPage());
            });
          }
        }
      }
    } else {
      final http.Response response = await _client.post(
        Uri.parse('${API.iHLUrl}/sso/sso_user_details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"sso_token": accessToken, "sso_type": signInType}),
      );

      print(response.body);
      if (response.statusCode == 200) {
        var finalresponce = jsonDecode(response.body);
        var outResponce = finalresponce['response']['ihl_account_status'];
        if (outResponce == "emailNotExist") {
          //emailNotExist
          SpUtil.putString(SPKeys.sso_token, accessToken);
          SpUtil.putString(SPKeys.email, finalresponce['response']['email']);
          SpUtil.putString(SPKeys.signInType, signInType);

          showMessageVerified();
        } else if (outResponce == "emailExist") {
          //emailExist
          showMessageUserExist();
          setState(() {
            userExistR = true;
          });
        } else {
          showMessageNotVerified();
        }
      }
    }
  }

  void showMessageVerified() {
    //var succ=CupertinoAlertDialog()
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
            child: Column(
          children: [
            Lottie.network('https://assets10.lottiefiles.com/packages/lf20_drbxtbz4.json'),
            SizedBox(
              height: 1 * SizeConfig.heightMultiplier,
            ),
            Text(
              "Verified",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(25),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ],
        )),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                setState(() {
                  isFetching = false;
                });
                SpUtil.getString('sso_token');
                Get.to(const SignupAlternateEmailSso(
                  loginSso: false,
                ));
              },
              child: Text(
                'Ok',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedInLogin() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network('https://assets7.lottiefiles.com/packages/lf20_owg6bznj.json',
                  height: 18.h),
              Text(
                "It seems we couldn't find an account associated with the information provided. Would you like to try signing up instead ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(16),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                // logoutSso();
                setState(() {
                  isFetching = false;
                });

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const SsoStartScreen(
                              login: false,
                            )));
                // Get.off(SsoStartScreen(
                //   login: false,
                // ));

                // login();

                // setState(() => _ssoLogin = true);
                // showMessageNotVerifiedExtended();
                //negative flow
              },
              child: Text(
                'Sign Up',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                // logoutSso();
                setState(() {
                  isFetching = false;
                });
                Navigator.pop(context);

                // setState(() => _ssoLogin = true);
                // showMessageNotVerifiedExtended();
                //negative flow
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageUserExist() {
    //var succ=CupertinoAlertDialog()
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
            child: Column(
          children: [
            Lottie.network('https://assets2.lottiefiles.com/packages/lf20_3etadtp1.json'),
            Text(
              "Email ID already Registered",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(20),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ],
        )),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                logoutSso();
                setState(() {
                  isFetching = false;
                });
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerified() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network('https://assets7.lottiefiles.com/packages/lf20_owg6bznj.json'),
              Text(
                "Unable to Verify. \n Please try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                logoutSso();
                setState(() {
                  isFetching = false;
                });
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedExtended() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_ju8hin0q.json',
              ),
              Text(
                "Do you still work in this organisation?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              onPressed: () {
                Navigator.pop(context);
                showMessageNotVerifiedExtendedFlow(true);
              }),
          TextButton(
              child: Text(
                'No',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              onPressed: () {
                Navigator.pop(context);
                showMessageNotVerifiedExtendedFlow(false);
              })
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedExtendedFlow(bool isOrganisation) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                isOrganisation
                    ? "Please contact your organisation admin."
                    : "You can login with your alternate email.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: isOrganisation
                ? () {
                    Navigator.pop(context);
                  }
                : () {
                    Get.to(const SsoLoginConvertPage(deepLink: false));
                  },
            child: Text(
              'Okay',
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(20),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }
}
